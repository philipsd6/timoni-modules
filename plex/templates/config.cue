package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
	"list"
)

#Config: {
	// These fields are set by timoni at apply time
	kubeVersion!: string
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.20.0"}
	moduleVersion!: string

	// The Kubernetes metadata common to all resources.
	// The `metadata.name` and `metadata.namespace` fields are set from the user-supplied instance name and namespace.
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}

	// The labels/annotations allows adding `metadata.labels/annotations` to all resources.
	// The `app.kubernetes.io/name` and `app.kubernetes.io/version` labels are automatically generated and can't be overwritten.
	metadata: labels:       timoniv1.#Labels
	metadata: annotations?: timoniv1.#Annotations

	// The selector allows adding label selectors to Deployments and Services.
	// The `app.kubernetes.io/name` label selector is automatically generated from the instance name and can't be overwritten.
	selector: timoniv1.#Selector & {#Name: metadata.name}

	image: timoniv1.#Image & {
		repository: *"plexinc/pms-docker" | string
		tag:        *"latest" | string
		digest:     *"" | string
	}

	// certain features require privileged containers
	privileged: *false | true

	// these tags are self updating inside the container, so must be privileged
	if list.Contains(["public", "beta", "plexpass"], image.tag) {
		privileged: true
	}

	// The pod allows setting the Kubernetes Pod annotations, image pull secrets, affinity and anti-affinity rules. By default, pods are scheduled on Linux nodes.
	pod: {
		annotations?: timoniv1.#Annotations

		affinity: *{
			nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
				matchExpressions: [{
					key:      corev1.#LabelOSStable
					operator: "In"
					values: ["linux"]
				}]
			}]
		} | corev1.#Affinity

		imagePullSecrets?: [...timoniv1.#ObjectReference]

		automountServiceAccountToken:  *false | true
		setHostnameAsFQDN:             *false | true
		hostNetwork:                   *false | true
		dnsPolicy:                     *"ClusterFirst" | corev1.#enumDNSPolicy
		restartPolicy:                 "Always"
		terminationGracePeriodSeconds: *30 | int & >0
	}

	// The resources allows setting the container resource requirements.
	resources: timoniv1.#ResourceRequirements & {
		requests: {
			cpu:    *"10m" | timoniv1.#CPUQuantity
			memory: *"32Mi" | timoniv1.#MemoryQuantity
		}
	}

	// The number of pods replicas.
	replicas: *1 | int & >0

	// buffer time before pod is considered available after being ready
	minReadySeconds: *0 | int & >=0

	revisionHistoryLimit: *2 | int & >0
	// strategy for deployments
	strategy: type: *"Recreate" | "RollingUpdate"
	// strategy for statefulsets
	updateStrategy: type: *"RollingUpdate" | "OnDelete"

	// How long to wait for the deployment to finish rollout before reporting progress failure
	progressDeadlineSeconds: *600 | int & >0

	// The securityContext allows setting the container security context. By default, the container is denied privilege escalation.
	securityContext: corev1.#SecurityContext & {
		allowPrivilegeEscalation: *false | true
		privileged:               *false | true
		capabilities:
		{
			drop: *["ALL"] | [string]
			add: *["CHOWN", "NET_BIND_SERVICE", "SETGID", "SETUID"] | [string]
		}
	}

	// The service allows setting the Kubernetes Service annotations and port.
	service: {
		annotations?: timoniv1.#Annotations

		port: *32400 | int & >0 & <=65535
		type: *"ClusterIP" | corev1.#enumServiceType
	}

	ingress: {
		enabled:      *false | true
		annotations?: timoniv1.#Annotations
		className:    *"nginx" | string
		host:         *metadata.name | string
		path:         *"/" | string
		pathType:     *"Prefix" | string
		tls:          *true | bool
	}

	persistence: {
		enabled:      *true | false
		storageClass: *"standard" | string
		accessMode:   *"ReadWriteOnce" | corev1.#enumPersistentVolumeAccessMode
		// if hostPath is set, a PV will be created for the PVC
		config: {
			hostPath?: string
			size:      *"1Gi" | timoniv1.#MemoryQuantity
		}
		media: {
			hostPath?: string
			size:      *"1Gi" | timoniv1.#MemoryQuantity
		}
	}

	// additional environment variables to set in configmap
	env?: [=~"^[A-Z_]+$"]: string

	if env.CHANGE_CONFIG_DIR_OWNERSHIP != _|_ {
		if env.CHANGE_CONFIG_DIR_OWNERSHIP == "true" {
			privileged: true
		}
	}

	// app specific configuration here:
	timeZone: *"America/New_York" | string

	// PlexPass only feature; requires privileged pod
	useQuickSync: *false | true

	if useQuickSync {
		privileged: true
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		configmap: #ConfigMap & {#config: config}
		servicetcp: #ServiceTCP & {#config: config}
		serviceudp: #ServiceUDP & {#config: config}

		if config.persistence.enabled {
			if config.persistence.config.hostPath != _|_ {
				configpv: #PersistentVolume & {#config: config, #name: "config"}
			}
			if config.persistence.media.hostPath != _|_ {
				mediapv: #PersistentVolume & {#config: config, #name: "media"}
			}
			configpvc: #PersistentVolumeClaim & {#config: config, #name: "config"}
			mediapvc: #PersistentVolumeClaim & {#config: config, #name: "media"}
		}

		deployment: #Deployment & {
			#config: config
			#cmName: configmap.metadata.name
		}

		if config.ingress.enabled {
			ingress: #Ingress & {#config: config}
		}
	}
}

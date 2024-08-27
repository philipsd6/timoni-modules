package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
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
		repository: *"linuxserver/ddclient" | string
		tag:        *"latest" | string
		digest:     *"" | string
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

		automountServiceAccountToken: *false | true
		setHostnameAsFQDN:            *false | true
		hostNetwork:                  *false | true
		dnsPolicy:                    *"ClusterFirst" | corev1.#enumDNSPolicy
		restartPolicy:                "Always"
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

	persistence: {
		enabled:      *true | false
		storageClass: *"standard" | string
		// If there are multiple volumes needed, put the following under subkeys per mountPath.
		accessMode: *"ReadWriteOnce" | corev1.#enumPersistentVolumeAccessMode
		size:       *"1Gi" | timoniv1.#StorageQuantity
		// if hostPath is set, a PV will be created for the PVC
		hostPath?: string
	}

	#bitwarden: {
		// id is a uuid
		id: =~"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$"
		// the default source
		source: *"fields" | "note" | "attachments" | "login"
		// environment variables to get -- assumes field names are the same as the env var names
		variables?: [...=~"^[A-Z_]+$"]
		// a mapping of secretKey to remoteRef.property -- i.e. APP_USERNAME: username for login source
		mapping?: {[string]: string}
		// the full details for using multiple sources
		items?: [...{
			source:         "fields" | "note" | "attachments" | *"login"
			secretKey:      string
			remoteProperty: string
		}]
	}
	bitwarden?: [...#bitwarden]

	// additional environment variables to set in configmap
	env?: [=~"^[A-Z_]+$"]: string

	// job specific configuration:
	timeZone:          *"Etc/UTC" | string
	schedule:          *"0/3 * * * *" | string
	concurrencyPolicy: *"Allow" | "Forbid" | "Replace"
	ddclientConfig: *"""
		use=webv4
		webv4=dynamicdns.park-your-domain.com/getip
		protocol=namecheap
		server=dynamicdns.park-your-domain.com
		login_env=DOMAIN
		password_env=PROVIDER_PASSWORD
		example.com
		""" | string
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		configmap: #ConfigMap & {#config: config}
		secret: {
			if config.bitwarden != _|_ {
				#ExternalSecret & {#config: config}
			}
			if config.bitwarden == _|_ {
				#Secret & {#config: config}
			}
		}

		if config.persistence.enabled {
			if config.persistence.hostPath != _|_ {
				pv: #PersistentVolume & {#config: config}
			}
			pvc: #PersistentVolumeClaim & {#config: config}
		}

		job: #CronJob & {
			#config:  config
			#cmName:  configmap.metadata.name
			#secName: secret.metadata.name
		}
	}
}

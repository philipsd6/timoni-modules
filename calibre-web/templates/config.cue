package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// The kubeVersion is a required field, set at apply-time
	// via timoni.cue by querying the user's Kubernetes API.
	kubeVersion!: string
	// Using the kubeVersion you can enforce a minimum Kubernetes minor version.
	// By default, the minimum Kubernetes version is set to 1.20.
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.20.0"}

	// The moduleVersion is set from the user-supplied module version.
	// This field is used for the `app.kubernetes.io/version` label.
	moduleVersion!: string

	// The Kubernetes metadata common to all resources.
	// The `metadata.name` and `metadata.namespace` fields are
	// set from the user-supplied instance name and namespace.
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}

	// The labels allows adding `metadata.labels` to all resources.
	// The `app.kubernetes.io/name` and `app.kubernetes.io/version` labels
	// are automatically generated and can't be overwritten.
	metadata: labels: timoniv1.#Labels

	// The annotations allows adding `metadata.annotations` to all resources.
	metadata: annotations?: timoniv1.#Annotations

	// The selector allows adding label selectors to Deployments and Services.
	// The `app.kubernetes.io/name` label selector is automatically generated
	// from the instance name and can't be overwritten.
	selector: timoniv1.#Selector & {#Name: metadata.name}

	// The image allows setting the container image repository,
	// tag, digest and pull policy.
	image: timoniv1.#Image & {
		repository: *"lscr.io/linuxserver/calibre-web" | string
		tag:        *"latest" | string
		digest:     *"" | string
	}

	// The pod allows setting the Kubernetes Pod annotations, image pull secrets,
	// affinity and anti-affinity rules. By default, pods are scheduled on Linux nodes.
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
	}

	// The resources allows setting the container resource requirements.
	// By default, the container requests 10m CPU and 32Mi memory.
	resources: timoniv1.#ResourceRequirements & {
		requests: {
			cpu:    *"10m" | timoniv1.#CPUQuantity
			memory: *"32Mi" | timoniv1.#MemoryQuantity
		}
	}

	// The number of pods replicas.
	// By default, the number of replicas is 1.
	replicas: *1 | int & >0

	// The securityContext allows setting the container security context.
	// By default, the container is denined privilege escalation.
	securityContext: corev1.#SecurityContext & {
		allowPrivilegeEscalation: *false | true
		privileged:               *false | true
		capabilities:
		{
			drop: *["ALL"] | [string]
			add: *["CHOWN", "NET_BIND_SERVICE", "SETGID", "SETUID"] | [string]
		}
	}

	userId:          *1000 | int & >0 & <=4294967295
	groupId:         *1000 | int & >0 & <=4294967295
	timeZone:        *"Etc/UTC" | string
	ebookConversion: *false | bool
	relaxTokenScope: *false | bool

	// You will probably want to set up persistence for the books and webapp config.

	#persistence: {
		enabled:      *false | bool
		mountPath:    string
		hostPath?:    string
		storageClass: *"standard" | string
		size:         *"1Gi" | string
		accessModes: *["ReadWriteOnce"] | []
	}

	persistence: [Name=_]: #persistence & {
		mountPath:    *"/\(Name)" | string
	}
	persistence: config: {}
	persistence: books: {}

	// The service allows setting the Kubernetes Service annotations and port.
	// By default, the HTTP port is 80.
	service: {
		annotations?: timoniv1.#Annotations

		port: *80 | int & >0 & <=65535
		type: *"ClusterIP" | corev1.#enumServiceType
	}

	ingress?: {
		annotations?: timoniv1.#Annotations
		className:    *"nginx" | string
		host:         string
		path:         *"/" | string
		pathType:     *"Prefix" | string
		tls:          *false | bool
	}

	test: {
		enabled: *false | bool
		image: {
			repository: "docker.io/curlimages/curl"
			tag:        "latest"
		} | timoniv1.#Image
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		configmap: #ConfigMap & {#config: config}

		for k, v in config.persistence if v.enabled {
			"\(k)": #PersistentVolumeClaim & {
				#config: config
				#name:   k
				#data:   v
			}
			if v.hostPath != _|_ {
				"\(k)-pv": #PersistentVolume & {
					#config: config
					#name:   k
					#data:   v
				}
			}
		}

		deploy: #Deployment & {
			#config: config
			#cmName: configmap.metadata.name
		}
		service: #Service & {#config: config}
		if config.ingress != _|_ {
			ingress: #Ingress & {#config: config}
		}
	}
}

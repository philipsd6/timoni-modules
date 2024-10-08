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
		repository: *"docker.io/teslamate/teslamate" | string
		tag:        *"latest" | string
		digest:     *"" | string
	}

	grafana_image: timoniv1.#Image & {
		repository: *"docker.io/teslamate/grafana" | string
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

	// The service allows setting the Kubernetes Service annotations and port.
	// By default, the HTTP port is 80.
	service: {
		annotations?: timoniv1.#Annotations

		port: *80 | int & >0 & <=65535
		type: *"ClusterIP" | corev1.#enumServiceType
	}

	// persistence is for Grafana
	persistence: {
		enabled:      *true | bool
		storageClass: *"standard" | string
		accessMode:   *"ReadWriteOnce" | string
		size:         *"1Gi" | timoniv1.#Quantity
		hostPath?:    string
	}

	// ingress is for the app, Grafana will be added as a subpath
	ingress: {
		enabled:      *true | bool
		annotations?: timoniv1.#Annotations
		className:    *"nginx" | string
		host:         *"" | string
		path:         *"/" | string
	}

	timeZone: *"Etc/UTC" | string
	mqtt: {
		enabled: *true | bool
		host:    *"" | string
	}
	database: {
		enabled:       *true | bool
		host:          *"" | string
		port:          *5432 | int & >0 & <=65535
		superuser:     *true | bool
		name:          *"teslamate" | string
		user:          *"teslamate" | string
		password:      *"teslamate" | string // these should be provided by the user as injected secrets unless bitwarden is used
		encryptionKey: *"teslamate" | string
	}
	bitwarden?: {
		id:     string
		source: *"fields" | "note" | "attachments" | "login"
		variables: *["DATABASE_NAME", "DATABASE_USER", "DATABASE_PASS", "ENCRYPTION_KEY"] | [...=~"^[A-Z_]+$"]
	}
	env: [=~"^[A-Z_]+$"]: string // additional environment variables to set in configmap

	ingress?: {
		annotations?: timoniv1.#Annotations
		className:    *"nginx" | string
		host:         string
		path:         *"/" | string
		pathType:     *"Prefix" | string
		tls:          *false | bool
	}
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
		db: #PostgreSQLUser & {
			#config: config,
			#secName: secret.metadata.name
		}
		if config.persistence.enabled {
			pvc: #PersistentVolumeClaim & {#config: config, #name: "grafana"}
			if config.persistence.hostPath != _|_ {
				pv: #PersistentVolume & {#config: config, #name: "grafana"}
			}
		}
		deploy: #Deployment & {
			#config:  config
			#cmName:  configmap.metadata.name
			#secName: secret.metadata.name
		}
		service: #Service & {#config: config}
		if config.ingress != _|_ {
			ingress: #Ingress & {#config: config}
		}
	}
}

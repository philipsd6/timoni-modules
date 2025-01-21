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

	// The service allows setting the Kubernetes Service annotations and port.
	service: {
		annotations?: timoniv1.#Annotations

		type: *"ClusterIP" | corev1.#enumServiceType
		externalName: *metadata.name | string
	}

	ingress: {
		enabled:      *true | false
		annotations?: timoniv1.#Annotations
		className:    *"nginx" | string
		host:         *metadata.name | string
		path:         *"/" | string
		pathType:     *"Prefix" | string
		tls:          *true | bool
	}
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		service: #ExternalService & {#config: config}

		if config.ingress.enabled {
			ingress: #Ingress & {#config: config}
		}
	}
}

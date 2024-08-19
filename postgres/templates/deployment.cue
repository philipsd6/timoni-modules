package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	#config:     #Config
	#cmName:     string
	#secName: string
	apiVersion:  "apps/v1"
	kind:        "Deployment"
	metadata:    #config.metadata
	metadata: labels: "app.kubernetes.io/component": "user-operator"
	spec: appsv1.#DeploymentSpec & {
		replicas: #config.replicas
		selector: matchLabels: #config.selector.labels & {
			"app.kubernetes.io/component": "user-operator"
		}
		template: metadata: {
			labels: #config.selector.labels & {
				"app.kubernetes.io/component": "user-operator"
			}
			if #config.pod.annotations != _|_ {
				annotations: #config.pod.annotations
			}
		}
		template: spec: corev1.#PodSpec & {
			automountServiceAccountToken: true
			containers: [{
				name:            "\(#config.metadata.name)-user-operator"
				image:           #config.userOperator.image.reference
				imagePullPolicy: #config.userOperator.image.pullPolicy
				envFrom: [
					{configMapRef: name: #cmName},
					{secretRef: name: #secName},
				]
				env: [{
					name: "POSTGRES_NAMESPACE"
					valueFrom: fieldRef: fieldPath: "metadata.namespace"
				}]
				if #config.resources != _|_ {
					resources: #config.resources
				}
				if #config.securityContext != _|_ {
					securityContext: #config.securityContext
				}
			}]
			if #config.pod.affinity != _|_ {
				affinity: #config.pod.affinity
			}
			if #config.pod.imagePullSecrets != _|_ {
				imagePullSecrets: #config.pod.imagePullSecrets
			}
		}
	}
}

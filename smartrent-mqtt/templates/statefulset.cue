package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#StatefulSet: appsv1.#StatefulSet & {
	#config:    #Config
	#cmName:    string
	#secName:   string
	apiVersion: "apps/v1"
	kind:       "StatefulSet"
	metadata:   #config.metadata
	spec: appsv1.#StatefulSetSpec & {
		replicas: #config.replicas
		selector: matchLabels: #config.selector.labels
		serviceName: #config.metadata.name
		updateStrategy: {
			type: "RollingUpdate"
			rollingUpdate: partition: 0
		}
		template: metadata: {
			labels: #config.selector.labels
			if #config.pod.annotations != _|_ {
				annotations: #config.pod.annotations
			}
		}
		template: spec: corev1.#PodSpec & {
			automountServiceAccountToken: false
			containers: [{
				name:            #config.metadata.name
				image:           #config.image.reference
				imagePullPolicy: #config.image.pullPolicy
				envFrom: [
					{configMapRef: name: #cmName},
					{secretRef: name: #secName},
				]
				ports: [
					{
						name:          "http"
						containerPort: 8000
					},
				]
				volumeMounts: [
					if #config.persistence.enabled {
						{
							name:      "data"
							mountPath: "/data"
						}
					},
			]
				readinessProbe: {
					httpGet: {
						path: "/ready"
						port: "http"
					}
					initialDelaySeconds: 20
					periodSeconds: 15
					timeoutSeconds: 3
					failureThreshold: 2
				}
				livenessProbe: {
					httpGet: {
						path: "/healthz"
						port: "http"
					}
					initialDelaySeconds: 30
					periodSeconds:       30
					timeoutSeconds:      3
					failureThreshold:    3
				}
				if #config.resources != _|_ {
					resources: #config.resources
				}
				if #config.securityContext != _|_ {
					securityContext: #config.securityContext
				}
			}]
			volumes: [
				if #config.persistence.enabled {
					{
						name: "data"
						persistentVolumeClaim: claimName: "data"
					}
				},
			]
			terminationGracePeriodSeconds: 30
			if #config.pod.affinity != _|_ {
				affinity: #config.pod.affinity
			}
			if #config.pod.imagePullSecrets != _|_ {
				imagePullSecrets: #config.pod.imagePullSecrets
			}
		}
	}
}

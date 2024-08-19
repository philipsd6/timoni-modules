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
	metadata: labels: "app.kubernetes.io/component": "database"
	spec: appsv1.#StatefulSetSpec & {
		replicas: #config.replicas
		selector: matchLabels: #config.selector.labels & {
			"app.kubernetes.io/component": "database"
		}
		serviceName: #config.metadata.name
		updateStrategy: {
			type: "RollingUpdate"
			rollingUpdate: partition: 0
		}
		template: metadata: {
			labels: #config.selector.labels & {
				"app.kubernetes.io/component": "database"
			}
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
						name:          "tcp-postgresql"
						containerPort: 5432
						protocol:      "TCP"
					},
				]
				volumeMounts: [
					{
						name:      "dshm"
						mountPath: "/dev/shm"
					},
					if #config.persistence.enabled {
						{
							name:      "data"
							mountPath: "/var/lib/postgresql/data"
						}
					},
				]
				readinessProbe: {
					exec: command: ["pg_isready", "-h", "localhost", "-p", "5432", "-U", "postgres"]
					initialDelaySeconds: 10
					periodSeconds:       10
				}
				livenessProbe: {
					tcpSocket: {
						port: "tcp-postgresql"
					}
					initialDelaySeconds: 30
					periodSeconds:       5
				}
				if #config.resources != _|_ {
					resources: #config.resources
				}
				if #config.securityContext != _|_ {
					securityContext: #config.securityContext
				}
			}]
			volumes: [
				{
					name: "dshm"
					emptyDir: {medium: "Memory"}
				},
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

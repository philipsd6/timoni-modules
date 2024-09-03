package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	#config:    #Config
	#cmName?:   string
	#secName?:  string
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   #config.metadata
	spec: appsv1.#DeploymentSpec & {
		minReadySeconds:         #config.minReadySeconds
		progressDeadlineSeconds: #config.progressDeadlineSeconds
		replicas:                #config.replicas
		revisionHistoryLimit:    #config.revisionHistoryLimit
		selector: matchLabels: #config.selector.labels
		strategy: #config.strategy
		template: {
			metadata: {
				labels: #config.selector.labels
				if #config.pod.annotations != _|_ {
					annotations: #config.pod.annotations
				}
			}
			spec: corev1.#PodSpec & {
				automountServiceAccountToken:  #config.pod.automountServiceAccountToken
				setHostnameAsFQDN:             #config.pod.setHostnameAsFQDN
				hostNetwork:                   #config.pod.hostNetwork
				dnsPolicy:                     #config.pod.dnsPolicy
				restartPolicy:                 #config.pod.restartPolicy
				terminationGracePeriodSeconds: #config.pod.terminationGracePeriodSeconds
				containers: [
					{
						name:            #config.metadata.name
						image:           #config.image.reference
						imagePullPolicy: #config.image.pullPolicy
						envFrom: [
							if #cmName != _|_ {
								{configMapRef: name: #cmName}
							},
							if #secName != _|_ {
								{secretRef: name: #secName}
							},
						]
						ports: [
							{
								name:          "http"
								containerPort: 1880
								protocol:      "TCP"
							},
							if #config.additionalPorts != _|_
							for p in #config.additionalPorts {
								{
									name:          p.name
									containerPort: p.port
									protocol:      p.protocol
								}
							},
							if #config.listeners != _|_
							for n, p in #config.listeners {
								{
									name:          n
									containerPort: p
									protocol:      "TCP"
								}
							},
						]
						volumeMounts: [
							if #config.persistence.enabled {
								{
									name:      #config.metadata.name
									mountPath: "/data"
								}
							},
						]
						startupProbe: {
							tcpSocket: port: "http"
							initialDelaySeconds: 5
							periodSeconds:       5
							failureThreshold:    30
							timeoutSeconds:      1
						}
						readinessProbe: {
							httpGet: {
								path: "/admin/"
								port: "http"
							}
							initialDelaySeconds: 5
							periodSeconds:       10
							failureThreshold:    3
							timeoutSeconds:      1
						}
						livenessProbe: {
							tcpSocket: port: "http"
							initialDelaySeconds: 5
							periodSeconds:       10
							failureThreshold:    3
							timeoutSeconds:      1
						}
						if #config.resources != _|_ {
							resources: #config.resources
						}
						if #config.securityContext != _|_ {
							securityContext: #config.securityContext
						}
					},
				]
				volumes: [
					if #config.persistence.enabled {
						{
							name: #config.metadata.name
							persistentVolumeClaim: {
								claimName: #config.metadata.name
							}
						}
					},
				]
				if #config.pod.affinity != _|_ {
					affinity: #config.pod.affinity
				}
				if #config.pod.imagePullSecrets != _|_ {
					imagePullSecrets: #config.pod.imagePullSecrets
				}
			}
		}
	}
}

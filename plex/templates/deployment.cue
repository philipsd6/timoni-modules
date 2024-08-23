package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

#Deployment: appsv1.#Deployment & {
	#config:    #Config
	#cmName:   string
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
							{configMapRef: name: #cmName}
						]
						ports: [
							{
								name:          "plex"
								containerPort: 32400
								protocol:      "TCP"
							},
						]
						volumeMounts: [
							{name: "transcode", mountPath: "/transcode"},
							if #config.persistence.enabled
							for val in ["config", "media"] {
								{name: val, mountPath: "/\(val)"}
							},
							if #config.useQuickSync {
								{name: "dev-dri", mountPath: "/dev/dri"}
							},
						]
						startupProbe: {
							tcpSocket: port: "plex"
							initialDelaySeconds: 0
							periodSeconds:       5
							failureThreshold:    30
							timeoutSeconds:      1
						}
						readinessProbe: {
							tcpSocket: port: "plex"
							initialDelaySeconds: 0
							periodSeconds:       10
							failureThreshold:    3
							timeoutSeconds:      1
						}
						livenessProbe: {
							tcpSocket: port: "plex"
							initialDelaySeconds: 0
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
						if #config.privileged {
							securityContext: {
								privileged:               true
								allowPrivilegeEscalation: true
							}
						}
					},
				]
				volumes: [
					{name: "transcode", emptyDir: medium: "Memory"},
					if #config.persistence.enabled
					for val in ["config", "media"] {
						{name: val, persistentVolumeClaim: claimName: val}
					},
					if #config.useQuickSync {
						{name: "dev-dri", hostPath: path: "/dev/dri"}
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

package templates

import (
	batchv1 "k8s.io/api/batch/v1"
	corev1 "k8s.io/api/core/v1"
)

#CronJob: batchv1.#CronJob & {
	#config:    #Config
	#cmName?:   string
	#secName?:  string
	apiVersion: "batch/v1"
	kind:       "CronJob"
	metadata:   #config.metadata
	spec: batchv1.#CronJobSpec & {
		schedule:          #config.schedule
		timeZone:          #config.timeZone
		concurrencyPolicy: #config.concurrencyPolicy
		jobTemplate: batchv1.#JobTemplateSpec & {
			metadata: #config.metadata
			spec: batchv1.#JobSpec & {
				template: corev1.#PodTemplateSpec & {
					metadata: #config.metadata
					spec: corev1.#PodSpec & {
						restartPolicy: "OnFailure"
						containers: [
							{
								name:            #config.metadata.name
								image:           #config.image.reference
								imagePullPolicy: #config.image.pullPolicy
								envFrom: [
									if #secName != _|_ {
										{secretRef: name: #secName}
									},
								]
								volumeMounts: [{
									name:      #config.metadata.name
									mountPath: "/config"
								},
									if #config.persistence.enabled {
										{
											name:      "cache"
											mountPath: "/tmp/ddclient"
										}
									},
								]
								if #config.resources != _|_ {
									resources: #config.resources
								}
								if #config.securityContext != _|_ {
									securityContext: #config.securityContext
								}
							},
						]
						volumes: [{
							name: #config.metadata.name
							configMap: name: #cmName
						},
							if #config.persistence.enabled {
								{
									name: "cache"
									persistentVolumeClaim: claimName: #config.metadata.name
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
	}
}

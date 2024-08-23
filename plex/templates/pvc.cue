package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#PersistentVolumeClaim: corev1.#PersistentVolumeClaim & {
	#config:    #Config
	#name:      *#config.metadata.name | string
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {name: #name} & {
		for k, v in #config.metadata if k != "name" {
			"\(k)": v
		}
	}
	spec: corev1.#PersistentVolumeClaimSpec & {
		selector: matchLabels: #config.selector.labels
		if #name == "config" {
			resources: requests: storage: #config.persistence.config.size
		}
		if #name == "media" {
			resources: requests: storage: #config.persistence.media.size
		}
		accessModes: [#config.persistence.accessMode]
		storageClassName: #config.persistence.storageClass
		volumeName:       "\(#config.metadata.name)-\(#name)"
	}
}

package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#PersistentVolumeClaim: corev1.#PersistentVolumeClaim & {
	#config: #Config
	#name:   string
	#data:   #config.#persistence
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {name: #name} & {
		for k, v in #config.metadata if k != "name" {
			"\(k)": v
		}
	}
	spec: corev1.#PersistentVolumeClaimSpec & {
		selector: matchLabels: #config.selector.labels
		resources: requests: storage: #data.size
		accessModes:      #data.accessModes
		storageClassName: #data.storageClass
		volumeName:       "\(#config.metadata.name)-\(#name)"
	}
}

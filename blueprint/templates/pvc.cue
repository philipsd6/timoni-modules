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
		resources: requests: storage: #config.persistence.size
		accessModes: [#config.persistence.accessMode]
		storageClassName: #config.persistence.storageClass
		if #config.persistence.hostPath != _|_ {
			volumeName: "\(#config.metadata.name)-\(#name)"
		}
	}
}

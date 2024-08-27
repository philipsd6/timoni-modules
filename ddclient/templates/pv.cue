package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#PersistentVolume: corev1.#PersistentVolume & {
	#config:    #Config
	#name:      *#config.metadata.name | string
	apiVersion: "v1"
	kind:       "PersistentVolume"
	metadata: {name: "\(#config.metadata.name)-\(#name)"} & {
		for k, v in #config.metadata if k != "name" {
			"\(k)": v
		}
	}
	spec: corev1.#PersistentVolumeSpec & {
		accessModes: [#config.persistence.accessMode]
		capacity: storage: #config.persistence.size
		storageClassName: #config.persistence.storageClass
		hostPath: path: #config.persistence.hostPath
		claimRef: {
			apiVersion: "v1"
			name:       #name
			kind:       "PersistentVolumeClaim"
			namespace:  #config.metadata.namespace
		}
	}
}

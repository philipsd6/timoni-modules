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
		storageClassName: #config.persistence.storageClass
		if #name == "config" {
			capacity: storage: #config.persistence.config.size
			hostPath: path: #config.persistence.config.hostPath
		}
		if #name == "media" {
			capacity: storage: #config.persistence.media.size
			hostPath: path: #config.persistence.media.hostPath
		}
		claimRef: {
			apiVersion: "v1"
			name:       #name
			kind:       "PersistentVolumeClaim"
			namespace:  #config.metadata.namespace
		}
	}

}

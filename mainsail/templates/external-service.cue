package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ExternalService: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata:   #config.metadata
	if #config.service.annotations != _|_ {
		metadata: annotations: #config.service.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     corev1.#ServiceTypeExternalName
		externalName: #config.service.externalName
	}
}

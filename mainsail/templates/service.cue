package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#Service: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata:   #config.metadata
	if #config.service.annotations != _|_ {
		metadata: annotations: #config.service.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     #config.service.type
		selector: #config.selector.labels
		// I can't make this optional with externalName? otherwise it disappears.
		externalName: #config.service.externalName @if(type == "ExternalName")
		ports: [
			{
				port:       #config.service.port
				protocol:   "TCP"
				name:       "http"
				targetPort: name
			},
		]
	}
}

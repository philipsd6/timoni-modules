package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#HeadlessService: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata:   #config.metadata
	if #config.service.annotations != _|_ {
		metadata: annotations: #config.service.annotations
	}
	metadata: annotations: "service.alpha.kubernetes.io/tolerate-unready-endpoints": "true"

	spec: corev1.#ServiceSpec & {
		type:                     corev1.#ServiceTypeClusterIP
		selector:                 #config.selector.labels & {
			"app.kubernetes.io/component": "database"
		}
		publishNotReadyAddresses: true
		ports: [
			{
				port:       #config.service.port
				protocol:   "TCP"
				name:       "tcp-postgresql"
				targetPort: name
			},
		]
		clusterIP: "None"
	}
}

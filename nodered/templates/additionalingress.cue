package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
)

#AdditionalIngress: networkingv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: #config.metadata & {
		labels: #config.selector.labels
		if #config.ingress.annotations != _|_ {
			annotations: #config.ingress.annotations
		}
	}
	spec: networkingv1.#IngressSpec & {
		if #config.ingress.className != _|_ {
			ingressClassName: #config.ingress.className
		}
		rules: [{
			host: #config.ingress.host
			http: paths: [{
				path:     #config.ingress.path
				pathType: #config.ingress.pathType
				backend: service: {
					name: #config.metadata.name
					port: name: "http"
				}
			}]
		}]
		if #config.ingress.tls {
			tls: [{
				hosts: [#config.ingress.host]
				secretName: "\(#config.metadata.name)-tls"
			}]
		}
	}
}

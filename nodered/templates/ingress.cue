package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
)

#Ingress: networkingv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: #config.metadata & {
		labels: #config.selector.labels
		if #config.additionalIngress.annotations != _|_ {
			annotations: #config.additionalIngress.annotations
		}
	}
	spec: networkingv1.#IngressSpec & {
		if #config.additionalIngress.className != _|_ {
			ingressClassName: #config.additionalIngress.className
		}
		rules: [{
			host: #config.additionalIngress.host
			http: paths: [{
				path:     #config.additionalIngress.path
				pathType: #config.additionalIngress.pathType
				backend: service: {
					name: #config.metadata.name
					port: name: "http"
				}
			}]
		}]
		if #config.additionalIngress.tls {
			tls: [{
				hosts: [#config.additionalIngress.host]
				secretName: "\(#config.metadata.name)-tls"
			}]
		}
	}
}

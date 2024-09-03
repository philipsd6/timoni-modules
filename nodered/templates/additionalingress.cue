package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
)

#AdditionalIngress: networkingv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {name: "\(#config.metadata.name)-additional"} & {
		for k, v in #config.metadata if k != "name" {
			"\(k)": v
		}} & {
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

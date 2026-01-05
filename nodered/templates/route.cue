package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
)

#Route: networkingv1.#Ingress & {
	#config:    #Config
	#thisRoute: #config.#route
	#routeName: string
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {name: "\(#config.metadata.name)-\(#routeName)"} & {
		for k, v in #config.metadata if k != "name" {
			"\(k)": v
		}} & {
		labels: #config.selector.labels
		if #thisRoute.annotations != _|_ {
			annotations: #thisRoute.annotations
		}
	}
	spec: networkingv1.#IngressSpec & {
		if #thisRoute.className != _|_ {
			ingressClassName: #thisRoute.className
		}
		rules: [{
			host: #thisRoute.host
			http: paths: [{
				path:     #thisRoute.path
				pathType: #thisRoute.pathType
				backend: service: {
					name: #config.metadata.name
					port: name: "http"
				}
			}]
		}]
		if #thisRoute.tls {
			tls: [{
				hosts: [#thisRoute.host]
				secretName: "\(#config.metadata.name)-tls"
			}]
		}
	}
}

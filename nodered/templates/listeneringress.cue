package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
	"strings"
)

#ListenerIngress: networkingv1.#Ingress & {
	#config:    #Config
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {name: "\(#config.metadata.name)-listener"} & {
		for k, v in #config.metadata if k != "name" {
			"\(k)": v
		}} & {
		labels: #config.selector.labels
		if #config.ingress.annotations != _|_ {
			annotations: {
				for k, v in #config.ingress.annotations if !strings.Contains(k, "auth") && !strings.Contains(k, "configuration-snippet") {
					"\(k)": v
				}
			}
		}
	}
	spec: networkingv1.#IngressSpec & {
		if #config.ingress.className != _|_ {
			ingressClassName: #config.ingress.className
		}
		rules: [{
			host: "listener.\(#config.ingress.host)"
			http: paths: [
				for n, p in #config.listeners {
					path:     "/\(n)"
					pathType: "Prefix"
					backend: service: {
						name: #config.metadata.name
						port: name: n
					}
				}]
		}]
		if #config.ingress.tls {
			tls: [{
				hosts: ["listener.\(#config.ingress.host)"]
				secretName: "listener-\(#config.metadata.name)-tls"
			}]
		}
	}
}

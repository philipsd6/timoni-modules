package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceTCP: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {name: "\(#config.metadata.name)-tcp"} & {
		for key, val in #config.metadata if key != "name" {
			"\(key)": val
		}
	}
	if #config.service.annotations != _|_ {
		metadata: annotations: #config.service.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     #config.service.type
		if #config.service.loadBalancerIP != _|_ {
			loadBalancerIP: #config.service.loadBalancerIP
		}
		selector: #config.selector.labels
		ports: [{
			port:       #config.service.port
			protocol:   "TCP"
			name:       "plex"
			targetPort: name
		}, {
			port:       32469
			targetPort: "dlna-tcp"
			name:       "dlna-tcp"
			protocol:   "TCP"
		}]
	}
}

#ServiceUDP: corev1.#Service & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "Service"
	metadata: {name: "\(#config.metadata.name)-udp"} & {
		for key, val in #config.metadata if key != "name" {
			"\(key)": val
		}
	}
	if #config.service.annotations != _|_ {
		metadata: annotations: #config.service.annotations
	}
	spec: corev1.#ServiceSpec & {
		type:     #config.service.type
		if #config.service.loadBalancerIP != _|_ {
			loadBalancerIP: #config.service.loadBalancerIP
		}
		selector: #config.selector.labels
		ports: [{
			port:       1900
			targetPort: "dlna-udp"
			name:       "dlna-udp"
			protocol:   "UDP"
		}, {
			port:       5353
			targetPort: "discovery-udp"
			name:       "discovery-udp"
			protocol:   "UDP"
		}, {
			port:       32410
			targetPort: "gdm-32410"
			name:       "gdm-32410"
			protocol:   "UDP"
		}, {
			port:       32412
			targetPort: "gdm-32412"
			name:       "gdm-32412"
			protocol:   "UDP"
		}, {
			port:       32413
			targetPort: "gdm-32413"
			name:       "gdm-32413"
			protocol:   "UDP"
		}, {
			port:       32414
			targetPort: "gdm-32414"
			name:       "gdm-32414"
			protocol:   "UDP"
		}]
	}
}

package templates

import (
	es "external-secrets.io/externalsecret/v1beta1"
)

#ExternalSecret: es.#ExternalSecret & {
	#config:    #Config
	apiVersion: "external-secrets.io/v1beta1"
	kind:       "ExternalSecret"
	metadata:   #config.metadata
	spec: {
		refreshInterval: "1h"
		secretStoreRef: kind: "ClusterSecretStore"
		secretStoreRef: name: "bitwarden-login"
		target: {
			deletionPolicy: "Delete"
			template: type: "Opaque"
			for e in #config.bitwarden if e.variables != _|_ {
				template: data: {
					for var in e.variables {"\(var)": "{{ .\(var) }}"}
				}
			}

			for e in #config.bitwarden if e.mapping != _|_ {
				template: data: {
					for key, prop in e.mapping {"\(key)": "{{ .\(key) }}"}
				}
			}
			for e in #config.bitwarden if e.items != _|_ {
				template: data: {
					for item in e.items {
						"\(item.secretKey)": "{{ .\(item.secretKey) }}"
					}
				}
			}
		}

		data: [
			for e in #config.bitwarden
			if e.variables != _|_
			for var in e.variables {
				secretKey: var
				remoteRef: key:      e.id
				remoteRef: property: var
				sourceRef: storeRef: name: "bitwarden-\(e.source)"
				sourceRef: storeRef: kind: "ClusterSecretStore"
			}
			for e in #config.bitwarden
			if e.mapping != _|_
			for key, prop in e.mapping {
				secretKey: key
				remoteRef: key:      e.id
				remoteRef: property: prop
				sourceRef: storeRef: name: "bitwarden-\(e.source)"
				sourceRef: storeRef: kind: "ClusterSecretStore"
			}
			for e in #config.bitwarden
			if e.items != _|_
			for item in e.items {
				secretKey: item.secretKey
				remoteRef: key:      e.id
				remoteRef: property: item.remoteProperty
				sourceRef: storeRef: name: "bitwarden-\(item.source)"
				sourceRef: storeRef: kind: "ClusterSecretStore"
			}
		]
	}
}

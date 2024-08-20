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
		secretStoreRef: {
			name: "bitwarden-\(#config.bitwarden.source)"
			kind: "ClusterSecretStore"
		}
		target: {
			deletionPolicy: "Delete"
			template: type: "Opaque"
			if #config.bitwarden.variables != _|_ {
				template: data: {
					for key in #config.bitwarden.variables {"\(key)": "{{ .\(key) }}"}
				}
			}
			if #config.bitwarden.mapping != _|_ {
				template: data: {
					for key, prop in #config.bitwarden.mapping {"\(key)": "{{ .\(key) }}"}
				}
			}
			if #config.bitwarden.items != _|_ {
				template: data: {
					for item in #config.bitwarden.items {
						"\(item.secretKey)": "{{ .\(item.secretKey) }}"
					}
				}
			}
		}
		data: [
			if #config.bitwarden.variables != _|_
			for key in #config.bitwarden.variables {
				secretKey: key
				remoteRef: key:      #config.bitwarden.id
				remoteRef: property: key
			},
			if #config.bitwarden.mapping != _|_
			for key, prop in #config.bitwarden.mapping {
				secretKey: key
				remoteRef: key:      #config.bitwarden.id
				remoteRef: property: prop
			},
			if #config.bitwarden.items != _|_
			for item in #config.bitwarden.items {
				secretKey: item.secretKey
				remoteRef: key:      #config.bitwarden.id
				remoteRef: property: item.remoteProperty
				sourceRef: storeRef: name: "bitwarden-\(item.source)"
				sourceRef: storeRef: kind: "ClusterSecretStore"
			},
		]
	}
}

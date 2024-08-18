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
			template: data: {
				for v in #config.bitwarden.variables {"\(v)": "{{ .\(v) }}"}
			}
		}
		data: [for v in #config.bitwarden.variables {
			secretKey: v
			remoteRef: key:      #config.bitwarden.id
			remoteRef: property: v
		}]
	}
}

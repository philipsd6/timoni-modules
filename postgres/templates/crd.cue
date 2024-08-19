package templates

#CustomResourceDefinition: {
	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		// name must match the spec fields below, and be in the form: <plural>.<group>
		name: "postgresqlusers.philipdouglass.com"
	}
	spec: {
		// group name to use for REST API: /apis/<group>/<version>
		group: "philipdouglass.com"
		// list of versions supported by this CustomResourceDefinition
		versions: [{
			name: "v1"
			// Each version can be enabled/disabled by Served flag.
			served: true
			// One and only one version must be marked as the storage version.
			storage: true
			schema: openAPIV3Schema: {
				type: "object"
				required: ["spec"]
				properties: {
					spec: {
						type: "object"
						// The datatype must be unspecified; it could be either a string or an
						// object, and that's not structural.
						"x-kubernetes-preserve-unknown-fields": true
					}
					status: {
						type:                                   "object"
						"x-kubernetes-preserve-unknown-fields": true
					}
				}
			}
			additionalPrinterColumns: [{
				name:        "Status"
				type:        "string"
				description: "The status of the PostgreSQLUser"
				jsonPath:    ".status.phase"
			}, {
				name:        "Message"
				type:        "string"
				priority:    0
				jsonPath:    ".status.create.message"
				description: "As returned from the handler (sometimes)."
			}]
		}]
		// either Namespaced or Cluster
		scope: "Namespaced"
		names: {
			// plural name to be used in the URL: /apis/<group>/<version>/<plural>
			plural: "postgresqlusers"
			// singular name to be used as an alias on the CLI and for display
			singular: "postgresqluser"
			// kind is normally the CamelCased singular type. Your resource manifests use this.
			kind: "PostgreSQLUser"
			// shortNames allow shorter string to match your resource on the CLI
			shortNames: [
				"pguser",
				"pgusers",
			]
		}
	}
}

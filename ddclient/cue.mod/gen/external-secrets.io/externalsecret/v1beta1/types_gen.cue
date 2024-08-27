// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f /home/philipd/devel/argocd-apps/external-secrets/base/manifest.yaml

package v1beta1

import (
	"strings"
	"struct"
)

// ExternalSecret is the Schema for the external-secrets API.
#ExternalSecret: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "external-secrets.io/v1beta1"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "ExternalSecret"
	metadata!: {
		name!: strings.MaxRunes(253) & strings.MinRunes(1) & {
			string
		}
		namespace!: strings.MaxRunes(63) & strings.MinRunes(1) & {
			string
		}
		labels?: {
			[string]: string
		}
		annotations?: {
			[string]: string
		}
	}

	// ExternalSecretSpec defines the desired state of ExternalSecret.
	spec!: #ExternalSecretSpec
}

// ExternalSecretSpec defines the desired state of ExternalSecret.
#ExternalSecretSpec: {
	// Data defines the connection between the Kubernetes Secret keys
	// and the Provider data
	data?: [...{
		// RemoteRef points to the remote secret and defines
		// which secret (version/property/..) to fetch.
		remoteRef: {
			// Used to define a conversion Strategy
			conversionStrategy?: "Default" | "Unicode" | *"Default"

			// Used to define a decoding Strategy
			decodingStrategy?: "Auto" | "Base64" | "Base64URL" | "None" | *"None"

			// Key is the key used in the Provider, mandatory
			key: string

			// Policy for fetching tags/labels from provider secrets, possible
			// options are Fetch, None. Defaults to None
			metadataPolicy?: "None" | "Fetch" | *"None"

			// Used to select a specific property of the Provider value (if a
			// map), if supported
			property?: string

			// Used to select a specific version of the Provider value, if
			// supported
			version?: string
		}

		// SecretKey defines the key in which the controller stores
		// the value. This is the key in the Kind=Secret
		secretKey: string

		// SourceRef allows you to override the source
		// from which the value will pulled from.
		sourceRef?: struct.MaxFields(1) & {
			// GeneratorRef points to a generator custom resource.
			//
			//
			// Deprecated: The generatorRef is not implemented in .data[].
			// this will be removed with v1.
			generatorRef?: {
				// Specify the apiVersion of the generator resource
				apiVersion?: string | *"generators.external-secrets.io/v1alpha1"

				// Specify the Kind of the resource, e.g. Password, ACRAccessToken
				// etc.
				kind: string

				// Specify the name of the generator resource
				name: string
			}

			// SecretStoreRef defines which SecretStore to fetch the
			// ExternalSecret data.
			storeRef?: {
				// Kind of the SecretStore resource (SecretStore or
				// ClusterSecretStore)
				// Defaults to `SecretStore`
				kind?: string

				// Name of the SecretStore resource
				name: string
			}
		}
	}]

	// DataFrom is used to fetch all properties from a specific
	// Provider data
	// If multiple entries are specified, the Secret keys are merged
	// in the specified order
	dataFrom?: [...{
		// Used to extract multiple key/value pairs from one secret
		// Note: Extract does not support sourceRef.Generator or
		// sourceRef.GeneratorRef.
		extract?: {
			// Used to define a conversion Strategy
			conversionStrategy?: "Default" | "Unicode" | *"Default"

			// Used to define a decoding Strategy
			decodingStrategy?: "Auto" | "Base64" | "Base64URL" | "None" | *"None"

			// Key is the key used in the Provider, mandatory
			key: string

			// Policy for fetching tags/labels from provider secrets, possible
			// options are Fetch, None. Defaults to None
			metadataPolicy?: "None" | "Fetch" | *"None"

			// Used to select a specific property of the Provider value (if a
			// map), if supported
			property?: string

			// Used to select a specific version of the Provider value, if
			// supported
			version?: string
		}

		// Used to find secrets based on tags or regular expressions
		// Note: Find does not support sourceRef.Generator or
		// sourceRef.GeneratorRef.
		find?: {
			// Used to define a conversion Strategy
			conversionStrategy?: "Default" | "Unicode" | *"Default"

			// Used to define a decoding Strategy
			decodingStrategy?: "Auto" | "Base64" | "Base64URL" | "None" | *"None"
			name?: {
				// Finds secrets base
				regexp?: string
			}

			// A root path to start the find operations.
			path?: string

			// Find secrets based on tags.
			tags?: {
				[string]: string
			}
		}

		// Used to rewrite secret Keys after getting them from the secret
		// Provider
		// Multiple Rewrite operations can be provided. They are applied
		// in a layered order (first to last)
		rewrite?: [...{
			// Used to rewrite with regular expressions.
			// The resulting key will be the output of a regexp.ReplaceAll
			// operation.
			regexp?: {
				// Used to define the regular expression of a re.Compiler.
				source: string

				// Used to define the target pattern of a ReplaceAll operation.
				target: string
			}
			transform?: {
				// Used to define the template to apply on the secret name.
				// `.value ` will specify the secret name in the template.
				template: string
			}
		}]

		// SourceRef points to a store or generator
		// which contains secret values ready to use.
		// Use this in combination with Extract or Find pull values out of
		// a specific SecretStore.
		// When sourceRef points to a generator Extract or Find is not
		// supported.
		// The generator returns a static map of values
		sourceRef?: struct.MaxFields(1) & {
			// GeneratorRef points to a generator custom resource.
			generatorRef?: {
				// Specify the apiVersion of the generator resource
				apiVersion?: string | *"generators.external-secrets.io/v1alpha1"

				// Specify the Kind of the resource, e.g. Password, ACRAccessToken
				// etc.
				kind: string

				// Specify the name of the generator resource
				name: string
			}

			// SecretStoreRef defines which SecretStore to fetch the
			// ExternalSecret data.
			storeRef?: {
				// Kind of the SecretStore resource (SecretStore or
				// ClusterSecretStore)
				// Defaults to `SecretStore`
				kind?: string

				// Name of the SecretStore resource
				name: string
			}
		}
	}]

	// RefreshInterval is the amount of time before the values are
	// read again from the SecretStore provider
	// Valid time units are "ns", "us" (or "µs"), "ms", "s", "m", "h"
	// May be set to zero to fetch and create it once. Defaults to 1h.
	refreshInterval?: string | *"1h"

	// SecretStoreRef defines which SecretStore to fetch the
	// ExternalSecret data.
	secretStoreRef?: {
		// Kind of the SecretStore resource (SecretStore or
		// ClusterSecretStore)
		// Defaults to `SecretStore`
		kind?: string

		// Name of the SecretStore resource
		name: string
	}

	// ExternalSecretTarget defines the Kubernetes Secret to be
	// created
	// There can be only one target per ExternalSecret.
	target?: {
		// CreationPolicy defines rules on how to create the resulting
		// Secret
		// Defaults to 'Owner'
		creationPolicy?: "Owner" | "Orphan" | "Merge" | "None" | *"Owner"

		// DeletionPolicy defines rules on how to delete the resulting
		// Secret
		// Defaults to 'Retain'
		deletionPolicy?: "Delete" | "Merge" | "Retain" | *"Retain"

		// Immutable defines if the final secret will be immutable
		immutable?: bool

		// Name defines the name of the Secret resource to be managed
		// This field is immutable
		// Defaults to the .metadata.name of the ExternalSecret resource
		name?: string

		// Template defines a ddclient for the created Secret resource.
		template?: {
			data?: {
				[string]: string
			}

			// EngineVersion specifies the template engine version
			// that should be used to compile/execute the
			// template specified in .data and .templateFrom[].
			engineVersion?: "v1" | "v2" | *"v2"
			mergePolicy?:   "Replace" | "Merge" | *"Replace"

			// ExternalSecretTemplateMetadata defines metadata fields for the
			// Secret ddclient.
			metadata?: {
				annotations?: {
					[string]: string
				}
				labels?: {
					[string]: string
				}
			}
			templateFrom?: [...{
				configMap?: {
					items: [...{
						key:         string
						templateAs?: "Values" | "KeysAndValues" | *"Values"
					}]
					name: string
				}
				literal?: string
				secret?: {
					items: [...{
						key:         string
						templateAs?: "Values" | "KeysAndValues" | *"Values"
					}]
					name: string
				}
				target?: "Data" | "Annotations" | "Labels" | *"Data"
			}]
			type?: string
		}
	} | *{
		creationPolicy: "Owner"
		deletionPolicy: "Retain"
	}
}

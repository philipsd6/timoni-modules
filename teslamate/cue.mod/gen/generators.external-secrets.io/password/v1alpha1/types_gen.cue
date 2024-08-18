// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f /home/philipd/devel/argocd-apps/external-secrets/base/manifest.yaml

package v1alpha1

import "strings"

// Password generates a random password based on the
// configuration parameters in spec.
// You can specify the length, characterset and other attributes.
#Password: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "generators.external-secrets.io/v1alpha1"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "Password"
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

	// PasswordSpec controls the behavior of the password generator.
	spec!: #PasswordSpec
}

// PasswordSpec controls the behavior of the password generator.
#PasswordSpec: {
	// set AllowRepeat to true to allow repeating characters.
	allowRepeat: bool | *false

	// Digits specifies the number of digits in the generated
	// password. If omitted it defaults to 25% of the length of the
	// password
	digits?: int

	// Length of the password to be generated.
	// Defaults to 24
	length: int | *24

	// Set NoUpper to disable uppercase characters
	noUpper: bool | *false

	// SymbolCharacters specifies the special characters that should
	// be used
	// in the generated password.
	symbolCharacters?: string

	// Symbols specifies the number of symbol characters in the
	// generated
	// password. If omitted it defaults to 25% of the length of the
	// password
	symbols?: int
}

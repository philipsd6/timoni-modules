package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#ConfigMapKind
	#Meta:   #config.metadata
	#Data: {
		TZ: "\(#config.timeZone)"
	} & {if #config.env != _|_ {#config.env}}
}

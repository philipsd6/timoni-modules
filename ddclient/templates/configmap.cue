package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#ConfigMapKind
	#Meta:   #config.metadata
	#Data: {
		"ddclient.conf": """
			daemon=0
			debug=yes
			verbose=yes
			\(#config.ddclientConfig)
			"""
	}
	if #config.env != _|_ {
		#Data: #config.env
	}

}

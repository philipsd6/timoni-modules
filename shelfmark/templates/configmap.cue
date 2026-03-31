package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#ConfigMapKind
	#Meta:   #config.metadata
	#Data: {
		PUID: "\(#config.userId)"
		PGID: "\(#config.groupId)"
		TZ:   "\(#config.timeZone)"
	}
	if #config.env != _|_ {
		#Data: #config.env
	}
}

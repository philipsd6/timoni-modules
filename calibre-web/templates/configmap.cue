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
		if #config.ebookConversion {
			DOCKER_MODS: "linuxserver/mods:universal-calibre"
		}
		if #config.relaxTokenScope {
			OAUTHLIB_RELAX_TOKEN_SCOPE: "1"
		}
	}
}

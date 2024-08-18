package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Secret: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#SecretKind
	#Meta:   #config.metadata
	#Data: {
		DATABASE_NAME: "\(#config.database.name)"
		DATABASE_USER: "\(#config.database.user)"
		DATABASE_PASS: "\(#config.database.password)"
		ENCRYPTION_KEY: "\(#config.database.encryptionKey)"
	}
}

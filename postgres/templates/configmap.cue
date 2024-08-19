package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#ConfigMapKind
	#Meta:   #config.metadata
	#Data: {
		POSTGRES_HOST_AUTH_METHOD: #config.authMethod
		if #config.userOperator.enabled {
			OPERATOR_NAME: "postgres-user-operator"
		}
	}
}

package templates

import (
	corev1 "k8s.io/api/core/v1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	#config: #Config
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind: "ServiceAccount"
	metadata: #config.metadata
}

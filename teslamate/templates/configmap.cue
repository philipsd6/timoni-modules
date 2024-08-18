package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#ConfigMapKind
	#Meta:   #config.metadata
	#Data: {
		TZ:                            "\(#config.timeZone)"
		DISABLE_MQTT:                  "\(!#config.mqtt.enabled)"
		MQTT_HOST:                     "\(#config.mqtt.host)"
		DATABASE_HOST:                 "\(#config.database.host)"
		GF_SERVER_ROOT_URL:            "%(protocol)s://%(domain)s:%(http_port)s/grafana/"
		GF_SERVER_SERVE_FROM_SUB_PATH: "true"
	} & #config.env
}

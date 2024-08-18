package templates

import (
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: timoniv1.#ImmutableConfig & {
	#config: #Config
	#Kind:   timoniv1.#ConfigMapKind
	#Meta:   #config.metadata
	#Data: {
		TZ:            "\(#config.timeZone)"
		DISABLE_MQTT:  "\(!#config.mqtt.enabled)"
		MQTT_HOST:     "\(#config.mqtt.host)"
		DATABASE_HOST: "\(#config.database.host)"
	} & #config.env
}

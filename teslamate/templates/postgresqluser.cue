package templates

import (
	pguser "philipdouglass.com/postgresqluser/v1"
)

#PostgreSQLUser: pguser.#PostgreSQLUser & {
	#config:    #Config
	#secName:   string
	apiVersion: "philipdouglass.com/v1"
	kind:       "PostgreSQLUser"
	metadata:   #config.metadata
	spec: {
		superuser: #config.database.superuser
		db: valueFrom: secretKeyRef: {
			name: *#secName | string
			key:  *"DATABASE_NAME" | string
		}
		username: valueFrom: secretKeyRef: {
			name: *#secName | string
			key:  *"DATABASE_USER" | string
		}
		password: valueFrom: secretKeyRef: {
			name: *#secName | string
			key:  *"DATABASE_PASS" | string
		}
	}
}

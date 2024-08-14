package templates

import (
	"encoding/yaml"
	"uuid"

	corev1 "k8s.io/api/core/v1"
	batchv1 "k8s.io/api/batch/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#TestJob: batchv1.#Job & {
	#config:    #Config
	apiVersion: "batch/v1"
	kind:       "Job"
	metadata: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: "test"
	}
	metadata: annotations: timoniv1.Action.Force
	spec: batchv1.#JobSpec & {
		template: corev1.#PodTemplateSpec & {
			let checksum = uuid.SHA1(uuid.ns.DNS, yaml.Marshal(#config))
			metadata: annotations: "timoni.sh/checksum": checksum
			spec: {
				containers: [{
					name:            "curl"
					image:           #config.test.image.reference
					imagePullPolicy: #config.test.image.pullPolicy
					command: [
						"curl",
						"-v",
						"-m",
						"5",
						"\(#config.metadata.name):\(#config.service.port)",
					]
				}]
				restartPolicy: "Never"
			}
		}
		backoffLimit: 1
	}
}

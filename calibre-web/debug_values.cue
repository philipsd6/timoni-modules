@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	image: {
		repository: "lscr.io/linuxserver/calibre-web"
		tag:        "amd64-nightly"
		digest:     ""
	}

	test: image: {
		repository: "busybox"
		digest:     ""
		tag:        "latest"
	}

	timeZone:        "America/New_York"
	ebookConversion: true

	pod: {
		annotations: "cluster-autoscaler.kubernetes.io/safe-to-evict": "true"
		imagePullSecrets: [{
			name: "regcred"
		}]
	}

	resources: limits: {
		cpu:    "100m"
		memory: "128Mi"
	}

	service: type: "LoadBalancer"
}

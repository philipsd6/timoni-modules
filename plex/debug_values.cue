@if(debug)

package main

#Domain: "home.philipdouglass.com"

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	image: tag: "beta"
	resources: requests: {
		cpu:    "100m"
		memory: "128Mi"
	}

	persistence: {
		enabled:      true
		storageClass: "microk8s-hostpath"
		config: hostPath: "/srv/data/plex"
		media: hostPath:  "/srv/data/media"
	}

	service: type: "LoadBalancer"

	ingress: enabled: true
	ingress: annotations: "cert-manager.io/cluster-issuer": "letsencrypt"
	ingress: host: "plex.\(#Domain)"
	ingress: tls:  true

	env: {
		PLEX_UID: "1000"
		PLEX_GID: "1000"
		CHANGE_CONFIG_DIR_OWNERSHIP: "false"
	}

	timeZone: "America/New_York"
	useQuickSync: true
}

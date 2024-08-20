@if(debug)

package main

#Domain: "example.com"

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	resources: requests: {
		cpu:    "100m"
		memory: "128Mi"
	}

	persistence: {
		enabled:      true
		storageClass: "microk8s-hostpath"
		hostPath:     "/srv/data/blueprint"
	}

	service: type: "LoadBalancer"

	ingress: annotations: {
		"cert-manager.io/cluster-issuer":                    "letsencrypt"
		"nginx.ingress.kubernetes.io/auth-url":              "https://auth.\(#Domain)/oauth2/auth"
		"nginx.ingress.kubernetes.io/auth-response-headers": "X-Auth-Request-User,X-Auth-Request-Email"
		"nginx.ingress.kubernetes.io/auth-signin":           "https://auth.\(#Domain)/oauth2/start?rd=$scheme%3A%2F%2F$host$escaped_request_uri"
		"nginx.ingress.kubernetes.io/configuration-snippet": """
			auth_request_set $user   $upstream_http_x_auth_request_user;
			auth_request_set $email  $upstream_http_x_auth_request_email;
			proxy_set_header X-User  $user;
			proxy_set_header X-Email $email;
			"""
	}
	ingress: host: "blueprint.\(#Domain)"
	ingress: tls:  true

	env: {
		APP_ENV: "production"
	}

	bitwarden: id: "440287ac-5e59-11ef-92ef-17fc78cc48da"
	bitwarden: source: "fields" // default
	bitwarden: variables: ["BOGUS"] // only useful for 'fields' source
	bitwarden: mapping: { // useful for any source
		CERTIFICATE: "ssl-certicate"
	}
	bitwarden: items: [ // required for anything other than the primary source
		{source: "login", secretKey: "APP_USERNAME", remoteProperty: "username"},
		{source: "login", secretKey: "APP_PASSWORD", remoteProperty: "password"},
	]

	timeZone: "America/New_York"
}

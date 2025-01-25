# reverse-proxy

A [timoni.sh](http://timoni.sh) module for deploying a reverse-proxy any internal service via a Kubernetes ingress.

## Install

Create one or more `values.cue` files and apply them to the instance.

For example, create a file `my-values.cue` with the following content:

```cue
values: {
	name: rpi
	service: externalName: "raspberrypi.home.arpa"
	service: port: 80
	ingress: {
		annotations: {
			"cert-manager.io/cluster-issuer":                    "letsencrypt"
			"nginx.ingress.kubernetes.io/backend-protocol":      "HTTP"
		}
		host: "pi.mydomain.com"
		tls:  true
	}
}
```

And apply the values with:

```shell
timoni -n pi apply reverse-proxy oci://philipsd6/timoni-reverse-proxy --values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n pi delete reverse-proxy
```

## Configuration

| Key                                  | Type                             | Default               | Description                                                             |
|--------------------------------------|----------------------------------|-----------------------|-------------------------------------------------------------------------|
| `metadata: labels:`                  | `{[string]: string}`             | `{}`                  | Common labels for all resources                                         |
| `metadata: annotations:`             | `{[string]: string}`             | `{}`                  | Common annotations for all resources                                    |
| `service: annotations:`              | `{[string]: string}`             | `{}`                  | Annotations applied to the Kubernetes Service                           |
| `service: port:`                     | `int`                            | `80`                  | Kubernetes Service HTTP port                                            |
| `ingress: enabled:`                  | `bool`                           | `false`               | Create an Ingress resource for the service                              |
| `ingress: annotations:`              | `{[string]: string}`             | `{}`                  | Annotations applied to ingress                                          |
| `ingress: className:`                | `string`                         | `nginx`               | The className for the Ingress                                           |
| `ingress: host:`                     | `string`                         | `""`                  | Required: the FQDN endpoint for the Ingress                             |
| `ingress: path:`                     | `string`                         | `/`                   | The path for the service backend                                        |
| `ingress: pathType:`                 | `string`                         | `Prefix`              | The pathType for the path                                               |
| `ingress: tls:`                      | `bool`                           | `true`                | Enable tls support for the Ingress using a default secret               |

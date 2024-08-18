# teslamate

A [timoni.sh](http://timoni.sh) module for deploying teslamate to Kubernetes clusters.

## Install

To create an instance using the default values:

```shell
timoni -n default apply teslamate oci://ghcr.io/philipsd6/timoni-teslamate:latest
```

To change the [default configuration](#configuration),
create one or more `values.cue` files and apply them to the instance.

For example, create a file `my-values.cue` with the following content:

```cue
values: {
	resources: requests: {
		cpu:    "100m"
		memory: "128Mi"
	}
}
```

And apply the values with:

```shell
timoni -n default apply teslamate oci://ghcr.io/philipsd6/timoni-teslamate:latest \
--values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n default delete teslamate
```

## Configuration

| Key                          | Type                             | Default                         | Description                                                        |
|------------------------------|----------------------------------|---------------------------------|--------------------------------------------------------------------|
| `image: tag:`                | `string`                         | `<latest version>`              | Container image tag                                                |
| `image: digest:`             | `string`                         | `""`                            | Container image digest, takes precedence over `tag` when specified |
| `image: repository:`         | `string`                         | `docker.io/teslamate/teslamate` | Container image repository                                         |
| `image: pullPolicy:`         | `string`                         | `IfNotPresent`                  | [Kubernetes image pull policy][pull-policy]                        |
| `grafana_image: tag:`        | `string`                         | `<latest version>`              | Container image tag                                                |
| `grafana_image: digest:`     | `string`                         | `""`                            | Container image digest, takes precedence over `tag` when specified |
| `grafana_image: repository:` | `string`                         | `docker.io/teslamate/grafana`   | Container image repository                                         |
| `grafana_image: pullPolicy:` | `string`                         | `IfNotPresent`                  | [Kubernetes image pull policy][pull-policy]                        |
| `metadata: labels:`          | `{[ string]: string}`            | `{}`                            | Common labels for all resources                                    |
| `metadata: annotations:`     | `{[ string]: string}`            | `{}`                            | Common annotations for all resources                               |
| `pod: annotations:`          | `{[ string]: string}`            | `{}`                            | Annotations applied to pods                                        |
| `pod: affinity:`             | `corev1.#Affinity`               | `{}`                            | [Kubernetes affinity and anti-affinity][anti-affinity]             |
| `pod: imagePullSecrets:`     | `[...timoniv1.#ObjectReference]` | `[]`                            | [Kubernetes image pull secrets][pull-secrets]                      |
| `replicas:`                  | `int`                            | `1`                             | Kubernetes deployment replicas                                     |
| `resources:`                 | `timoniv1.#ResourceRequirements` | `{}`                            | [Kubernetes resource requests and limits][requests]                |
| `securityContext:`           | `corev1.#SecurityContext`        | `{}`                            | [Kubernetes container security context][security]                  |
| `service: annotations:`      | `{[ string]: string}`            | `{}`                            | Annotations applied to the Kubernetes Service                      |
| `service: port:`             | `int`                            | `80`                            | Kubernetes Service HTTP port                                       |
| `service: type:`             | `string`                         | `ClusterIP`                     | The Service type                                                   |
| `timeZone`                   | `string`                         | `Etc/UTC`                       | The timezone                                                       |
| `mqtt: enabled:`             | `bool`                           | `true`                          | Enable sending metrics to MQTT                                     |
| `mqtt: host:`                | `string`                         | `""`                            | The hostname for the MQTT server                                   |
| `database: host:`            | `string`                         | `""`                            | The hostname for the PostgreSQL server                             |
| `persistence: enabled:`      | `bool`                           | `true`                          | Use persistence (required for Grafana)                             |
| `persistence: storageClass:` | `string`                         | `"standard"`                    | The storageClass for Grafana data                                  |
| `persistence: accessMode:`   | `string`                         | `ReadWriteOnce`                 | The access mode for the storage                                    |
| `persistence: size:`         | `string`                         | `1Gi`                           | The amount of storage to request                                   |
| `persistence: hostPath:`     | `string`                         | `""`                            | Optionally, create a volume using this hostPath                    |
| `bitwarden: id:`             | `string`                         | `""`                            | Optionally, use a Bitwarden API ExternalSecret with this uuid      |
| `bitwarden: source:`         | `string`                         | `fields`                        | The source for the data in the Bitwarden item                      |
| `bitwarden: variables:`      | `[...string]`                    | `[]`                            | The environment variables to get from the item                     |
| `ingress: annotations:`      | `{[ string]: string}`            | `{}`                            | Annotations applied to ingress                                     |
| `ingress: className:`        | `string`                         | `nginx`                         | The className for the ingress                                      |
| `ingress: host:`             | `string`                         | `""`                            | The FQDN for the ingress                                           |
| `ingress: path:`             | `string`                         | `/`                             | The path to associate with the primary service                     |
| `ingress: pathType:`         | `string`                         | `Prefix`                        | The pathType. Don't change unless you know what you're doing.      |
| `ingress: tls:`              | `bool`                           | `true`                          | Enable TLS for the ingress                                         |

The following secret environment variables are required:
- `DATABASE_NAME`
- `DATABASE_USER`
- `DATABASE_PASS`
- `ENCRYPTION_KEY`
If you don't use the Bitwarden external secret feature, then you must ensure that you set up a secret with this data some other way.

[pull-policy]: https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy
[anti-affinity]: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity
[pull-secrets]: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
[requests]: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers
[security]: https://kubernetes.io/docs/tasks/configure-pod-container/security-context

# calibre-web

A [timoni.sh](http://timoni.sh) module for deploying calibre-web to Kubernetes clusters.

## Install

To create an instance using the default values:

```shell
timoni -n default apply calibre-web oci://ghcr.io/philipsd6/timoni-calibre-web:latest
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
timoni -n default apply calibre-web oci://ghcr.io/philipsd6/timoni-calibre-web:latest \
--values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n default delete calibre-web
```

## Configuration

| Key                      | Type                             | Default                           | Description                                                                                                                                  |
|--------------------------|----------------------------------|-----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `image: tag:`            | `string`                         | `<latest version>`                | Container image tag                                                                                                                          |
| `image: repository:`     | `string`                         | `lscr.io/linuxserver/calibre-web` | Container image repository                                                                                                                   |
| `image: pullPolicy:`     | `string`                         | `IfNotPresent`                    | [Kubernetes image pull policy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy)                                     |
| `metadata: labels:`      | `{[ string]: string}`            | `{}`                              | Common labels for all resources                                                                                                              |
| `metadata: annotations:` | `{[ string]: string}`            | `{}`                              | Common annotations for all resources                                                                                                         |
| `pod: annotations:`      | `{[ string]: string}`            | `{}`                              | Annotations applied to pods                                                                                                                  |
| `pod: affinity:`         | `corev1.#Affinity`               | `{}`                              | [Kubernetes affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| `pod: imagePullSecrets:` | `[...timoniv1.#ObjectReference]` | `[]`                              | [Kubernetes image pull secrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)                 |
| `replicas:`              | `int`                            | `1`                               | Kubernetes deployment replicas                                                                                                               |
| `resources:`             | `timoniv1.#ResourceRequirements` | `{}`                              | [Kubernetes resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers)                     |
| `securityContext:`       | `corev1.#SecurityContext`        | `{}`                              | [Kubernetes container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context)                           |
| `service: annotations:`  | `{[ string]: string}`            | `{}`                              | Annotations applied to the Kubernetes Service                                                                                                |
| `service: port:`         | `int`                            | `80`                              | Kubernetes Service HTTP port                                                                                                                 |
| `ingress: annotations:`  | `{[ string]: string}`            | `{}`                              | Annotations applied to the Kubernetes Ingress                                                                                                |
| `ingress: className`     | `string`                         | `nginx`                           | Ingress Class Name                                                                                                                           |
| `ingress: tls`           | `[...{}]`                        | `[]`                              | The TLS settings for the ingress                                                                                                             |
| `ingress: rules`         | `[...{}]`                        | `[]`                              | The routing rules for the ingress                                                                                                            |
| `test: enabled`          | `bool`                           | `false`                           | Run a test job to confirm it works                                                                                                           |
| `userId`                 | `int`                            | `1000`                            | The UserID to use                                                                                                                            |
| `groupId`                | `int`                            | `1000`                            | The GroupID to use                                                                                                                           |
| `timeZone`               | `string`                         | `Etc/UTC`                         | The timezone                                                                                                                                 |
| `ebookConversion`        | `bool`                           | `false`                           | Adds the ability to perform ebook conversion                                                                                                 |
| `relaxTokenScope`        | `bool`                           | `false`                           | Optionally set this to allow Google OAUTH to work                                                                                            |

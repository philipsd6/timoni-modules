# NodeRED

A [timoni.sh](http://timoni.sh) module for deploying NodeRED to Kubernetes clusters.

## Install

To create an instance using the default values:

```shell
timoni -n default apply nodered oci://philipsd6/timoni-nodered
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
timoni -n default apply nodered oci://philipsd6/timoni-nodered --values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n default delete nodered
```

## Configuration

| Key                                  | Type                             | Default               | Description                                                             |
|--------------------------------------|----------------------------------|-----------------------|-------------------------------------------------------------------------|
| `image: tag:`                        | `string`                         | `<latest version>`    | Container image tag                                                     |
| `image: digest:`                     | `string`                         | `""`                  | Container image digest, takes precedence over `tag` when specified      |
| `image: repository:`                 | `string`                         | `docker.io/nodered` | Container image repository                                              |
| `image: pullPolicy:`                 | `string`                         | `IfNotPresent`        | [Kubernetes image pull policy][pull-policy]                             |
| `metadata: labels:`                  | `{[string]: string}`             | `{}`                  | Common labels for all resources                                         |
| `metadata: annotations:`             | `{[string]: string}`             | `{}`                  | Common annotations for all resources                                    |
| `pod: annotations:`                  | `{[string]: string}`             | `{}`                  | Annotations applied to pods                                             |
| `pod: affinity:`                     | `corev1.#Affinity`               | `{}`                  | [Kubernetes affinity and anti-affinity][anti-affinity]                  |
| `pod: imagePullSecrets:`             | `[...timoniv1.#ObjectReference]` | `[]`                  | [Kubernetes image pull secrets][pull-secrets]                           |
| `pod: automountServiceAccountToken:` | `bool`                           | `false`               | Mount the service token in the pod                                      |
| `pod: setHostnameAsFQDN:`            | `bool`                           | `false`               | Use FQDN for the pod hostnames                                          |
| `pod: hostNetwork:`                  | `bool`                           | `false`               | Give access to the node host networking to the pod                      |
| `pod: dnsPolicy:`                    | `string`                         | `ClusterFirst`        | DNS policy to use for the pod                                           |
| `pod: restartPolicy:`                | `string`                         | `Always`              | Pod restart policy                                                      |
| `replicas:`                          | `int`                            | `1`                   | Kubernetes deployment replicas                                          |
| `resources:`                         | `timoniv1.#ResourceRequirements` | `{}`                  | [Kubernetes resource requests and limits][requests]                     |
| `securityContext:`                   | `corev1.#SecurityContext`        | `{}`                  | [Kubernetes container security context][security-context]               |
| `minReadySeconds:`                   | `int`                            | `0`                   | Buffer time before pod is considered available after being ready        |
| `progressDeadlineSeconds:`           | `int`                            | `600`                 | Seconds wait time before reporting rollout progress failure             |
| `revisionHistoryLimit:`              | `int`                            | `2`                   | Number of deployment or statefulset versions to keep                    |
| `strategy: type:`                    | `string`                         | `Recreate`            | Deployment strategy type to use                                         |
| `updateStrategy: type:`              | `string`                         | `RollingUpdate`       | StatefulSet strategy type to use                                        |
| `service: annotations:`              | `{[string]: string}`             | `{}`                  | Annotations applied to the Kubernetes Service                           |
| `service: port:`                     | `int`                            | `80`                  | Kubernetes Service HTTP port                                            |
| `ingress: enabled:`                  | `bool`                           | `false`               | Create an Ingress resource for the service                              |
| `ingress: annotations:`              | `{[string]: string}`             | `{}`                  | Annotations applied to ingress                                          |
| `ingress: className:`                | `string`                         | `nginx`               | The className for the Ingress                                           |
| `ingress: host:`                     | `string`                         | `""`                  | Required: the FQDN endpoint for the Ingress                             |
| `ingress: path:`                     | `string`                         | `/`                   | The path for the service backend                                        |
| `ingress: pathType:`                 | `string`                         | `Prefix`              | The pathType for the path                                               |
| `ingress: tls:`                      | `bool`                           | `true`                | Enable tls support for the Ingress using a default secret               |
| `persistence: enabled:`              | `bool`                           | `true`                | Enable persistence                                                      |
| `persistence: storageClass:`         | `string`                         | `standard`            | The storageClass to use                                                 |
| `persistence: accessMode:`           | `string`                         | `ReadWriteOnce`       | The accessMode to request for storage                                   |
| `persistence: size:`                 | `string`                         | `1Gi`                 | The amount of storage to request                                        |
| `persistence: hostPath:`             | `string`                         | `""`                  | If set, will create a PersistentVolume for that path on the host        |

### External Secrets
Instead of using standard secrets, if `external-secrets` is in use in the cluster, you can use a Bitwarden API provider to create an ExternalSecret referencing items in your Bitwarden Vault by setting the `bitwarden: [...]` parameter to a list of items consisting of these fields:

| `id:`         | `string`                                                           | `""`     | Bitwarden item UUID                                                     |
| `source:`     | `string`                                                           | `fields` | One of `fields`, `note`, `attachments`, `login`                         |
| `variables?:` | `[...string]`                                                      | `[]`     | If set, will set secretKey from remote property of the same name        |
| `mapping?:`   | `{[string]: string}`                                               | `{}`     | If set, will map secretKey to a remote property                         |
| `items?:`     | `[...{source: string, secretKey: string, remoteProperty: string}]` | `[]`     | If set, will set secretKey and remoteProperty from the specified source |

### NodeRED
| Key                | Type                                                             | Default            | Description                                                       |
|--------------------|------------------------------------------------------------------|--------------------|-------------------------------------------------------------------|
| `env:`             | `{[string]: string}`                                             | `{}`               | If set, will include this environment variables in the configMap  |
| `timeZone:`        | `string`                                                         | `America/New_York` | The preferred timezone                                            |
| `additionalPorts:` | `[...{expose: bool, name: string, port: int, protocol: string}]` | `[]`               | If set, include these ports, and optionally expose in the ingress |
|                    |                                                                  |                    |                                                                   |

[pull-policy]: https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy
[anti-affinity]: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity
[pull-secrets]: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
[requests]: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers
[security-context]: https://kubernetes.io/docs/tasks/configure-pod-container/security-context

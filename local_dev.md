# local-dev <!-- omit in toc -->

- [networking](#networking)
  - [kubefwd](#kubefwd)
  - [Telepresence](#telepresence)
    - [verify](#verify)
  - [cleanup](#cleanup)
- [java](#java)
  - [prerequisites](#prerequisites)
  - [set the project SDK](#set-the-project-sdk)
- [references](#references)

## networking

### [kubefwd](https://github.com/txn2/kubefwd)

```sh
brew install txn2/tap/kubefwd
```

forwarding all namespaces to the localhost

```sh
sudo kubefwd svc --all-namespaces
```

### [Telepresence](https://www.telepresence.io)

FIXME: for unknown reasons, telepresence does not work after 5 days of use...

```sh
brew install datawire/blackbird/telepresence-arm64
```

telepresence will enable to refer to the remote Service directly via its internal cluster name as if your development machine is inside the cluster

```sh
telepresence connect
```

#### verify

```sh
curl -ik https://kubernetes.default
```

```sh
HTTP/1.1 401 Unauthorized
Audit-Id: e9e47951-afe5-4033-ae72-89db82532d3d
Cache-Control: no-cache, private
Content-Type: application/json
Date: Sat, 30 Jul 2022 15:16:24 GMT
Content-Length: 165

{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}
```

### cleanup

```sh
telepresence quit -u
telepresence uninstall --everything
```

## java

### prerequisites

- Intellij IDEA
- [asdf-vm/asdf](https://github.com/asdf-vm/asdf)

```sh
brew install --cask intellij-idea-ce
brew install asdf
asdf plugin-add java https://github.com/halcyon/asdf-java.git
asdf install java corretto-18.0.2.9.1
```

### set the project SDK

open `kafka-programming/java-kafaka-beginners-cource` in the Intellij IDEA

`cmd + ;` to open the settings

![Intellij IDEA SDK setup](./assets/ide%20sdk%20setup.png "Intellij IDEA SDK setup")

## references

- [Develop Apache Kafka applications with Strimzi and Minikube](https://strimzi.io/blog/2020/04/15/develop-apache-kafka-applications-with-strimzi-and-minikube/)
- [Easily Debug Java Microservices Running on Kubernetes with IntelliJ IDEA](https://blog.jetbrains.com/idea/2021/05/easily-debug-java-microservices-running-on-kubernetes-with-intellij-idea/)
- [Using Telepresence 2 for Kubernetes debugging and local development](https://codefresh.io/blog/telepresence-2-local-development/)
- [conduktor/kafka-beginners-course](https://github.com/conduktor/kafka-beginners-course)
- [IntelliJ IDEA - Project configuration SDK](https://www.jetbrains.com/help/idea/sdk.html)

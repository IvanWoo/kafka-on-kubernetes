# kafka-on-kubernetes <!-- omit in toc -->

- [prerequisites](#prerequisites)
- [setup](#setup)
  - [namespace](#namespace)
  - [kafka](#kafka)
    - [install Strimzi](#install-strimzi)
    - [deploy the kafka cluster](#deploy-the-kafka-cluster)
    - [send some messages](#send-some-messages)
    - [receive some messages](#receive-some-messages)
- [cleanup](#cleanup)

## prerequisites

- [Rancher Desktop](https://github.com/rancher-sandbox/rancher-desktop): `1.4.1`
- Kubernetes: `v1.22.6`
- kubectl `v1.23.3`
- Helm: `v3.7.2`

## setup

tl;dr: `./scripts/up.sh`

### namespace

```sh
kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -
```

### kafka

#### install Strimzi

```sh
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
```

#### deploy the kafka cluster

```sh
kubectl apply -f kafka/values.yaml -n kafka
```

wait the cluster to be ready

```sh
kubectl wait kafka/my-kafka-cluster --for=condition=Ready --timeout=300s -n kafka
```

#### send some messages

```sh
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic
```

#### receive some messages

```sh
kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning
```

## cleanup

tl;dr: `./scripts/down.sh`

```sh
kubectl delete -f kafka/ -n kafka
kubectl delete -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
kubectl delete namespace kafka
```

# kafka-on-kubernetes <!-- omit in toc -->

- [prerequisites](#prerequisites)
- [setup](#setup)
  - [namespace](#namespace)
  - [kafka](#kafka)
    - [install Strimzi](#install-strimzi)
    - [deploy the kafka cluster](#deploy-the-kafka-cluster)
  - [operations](#operations)
    - [topics](#topics)
      - [create a topic](#create-a-topic)
      - [list topics](#list-topics)
      - [describe a topic](#describe-a-topic)
      - [delete a topic](#delete-a-topic)
    - [messages](#messages)
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

### operations

#### topics

##### create a topic

**attention**: the replication-factor <= number of kafka brokers

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --create --topic my-first-topic --partitions 1 --replication-factor 1
```

##### list topics

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --list
```

##### describe a topic

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --describe --topic my-first-topic
```

##### delete a topic

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --delete --topic my-first-topic
```

#### messages

##### send some messages

```sh
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic --property parse.key=true --property key.separator=:
```

##### receive some messages

```sh
kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning --formatter kafka.tools.DefaultMessageFormatter --property print.timestamp=true --property print.key=true --property print.value=true
```

## cleanup

tl;dr: `./scripts/down.sh`

```sh
kubectl delete -f kafka/ -n kafka
kubectl delete -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
kubectl delete namespace kafka
```

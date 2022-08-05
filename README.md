# kafka-on-kubernetes <!-- omit in toc -->

- [prerequisites](#prerequisites)
- [setup](#setup)
  - [namespace](#namespace)
  - [kafka](#kafka)
    - [install Strimzi](#install-strimzi)
    - [deploy the kafka cluster](#deploy-the-kafka-cluster)
    - [install Kafka-UI](#install-kafka-ui)
  - [opensearch](#opensearch)
- [operations](#operations)
  - [topics](#topics)
    - [create a topic](#create-a-topic)
    - [list topics](#list-topics)
    - [describe a topic](#describe-a-topic)
    - [delete a topic](#delete-a-topic)
  - [messages](#messages)
    - [send some messages](#send-some-messages)
    - [receive some messages](#receive-some-messages)
  - [consumer groups](#consumer-groups)
- [kafka-programming](#kafka-programming)
  - [create topics](#create-topics)
  - [java](#java)
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
kubectl create namespace opensearch --dry-run=client -o yaml | kubectl apply -f -
```

### kafka

#### install [Strimzi](https://strimzi.io)

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

#### install [Kafka-UI](https://github.com/provectus/kafka-ui)

```sh
helm repo add kafka-ui https://provectus.github.io/kafka-ui
```

```sh
helm upgrade --install my-kafka-ui kafka-ui/kafka-ui --namespace kafka -f kafka-ui/values.yaml
```

```sh
kubectl port-forward svc/my-kafka-ui -n kafka 8080:80
```

visit the [Kafka-UI](http://localhost:8080)

### opensearch

follow the [OpenSearch](https://opensearch.org/docs/latest/opensearch/install/helm/) guide to deploy the opensearch service

```sh
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update
```

```sh
helm upgrade --install my-opensearch opensearch/opensearch --namespace opensearch -f opensearch/values.yaml
helm upgrade --install my-opensearch-dashboards opensearch/opensearch-dashboards --namespace opensearch -f opensearch-dashboards/values.yaml
```

port-forward the opensearch dashboard service

```sh
kubectl port-forward svc/my-opensearch-dashboards -n opensearch 5601
```

and visit the [opensearch dashboard](http://localhost:5601) with the following credentials:

```sh
username: admin
password: admin
```

verify the opensearch service by testing [these operations](https://opensearch.org/docs/latest/#docker-quickstart) on the [opensearch dashboard](http://localhost:5601)

## operations

### topics

#### create a topic

**attention**: the replication-factor <= number of kafka brokers

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --create --topic my-first-topic --partitions 1 --replication-factor 1
```

#### list topics

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --list
```

#### describe a topic

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --describe --topic my-first-topic
```

#### delete a topic

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --delete --topic my-first-topic
```

### messages

#### send some messages

```sh
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-first-topic --property parse.key=true --property key.separator=:
```

#### receive some messages

```sh
kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-first-topic --from-beginning --formatter kafka.tools.DefaultMessageFormatter --property print.timestamp=true --property print.key=true --property print.value=true
```

### consumer groups

create the topic with multiple partitions

```sh
kubectl -n kafka run kafka-topic-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-topics.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --create --topic my-first-consumer-group-topic --partitions 3 --replication-factor 1
```

create the consumer group

```sh
kubectl -n kafka run kafka-consumer-group-0 -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-first-consumer-group-topic --group my-first-consumer-group --from-beginning
```

```sh
kubectl -n kafka run kafka-consumer-group-1 -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-first-consumer-group-topic --group my-first-consumer-group --from-beginning
```

send some messages

```sh
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-first-consumer-group-topic
```

**attention**: same group will share the message, but different group will receive same message when attaching to the same topic

list all consumer groups

```sh
kubectl -n kafka run kafka-consumer-group-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-consumer-groups.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --list
```

delete a consumer group

```sh
kubectl -n kafka run kafka-consumer-group-operator -ti --image=quay.io/strimzi/kafka:0.30.0-kafka-3.2.0 --rm=true --restart=Never -- bin/kafka-consumer-groups.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --delete --group my-first-consumer-group
```

## kafka-programming

**attention**: follow [local_dev doc](local_dev.md) to setup the prerequisites

### create topics

```sh
kubectl apply -f kafka/topics.yaml -n kafka
```

### java

- `StickyPartitioner` to improve the performance of batch producing at [ProducerDemoWithCallback.java](./kafka-programming/java-kafaka-beginners-cource/kafka-basics/src/main/java/org/example/kafka/ProducerDemoWithCallback.java)
- messages with the same key will be sent to the same partition at [ProducerDemoKey.java](./kafka-programming/java-kafaka-beginners-cource/kafka-basics/src/main/java/org/example/kafka/ProducerDemoKey.java)
- consumer groups and partition rebalance
  - moving partitions between consumers is called rebalance
  - eager rebalance: all consumers stop and rejoin
  - cooperative rebalance (incremental rebalance): reassign a small subset of the partitions
- auto offset commit
  - `.commitAsync()` called periodically between `.poll()` calls
- kafka topic availability
  - `acks=all(-1)` and `min.insync.replicas=2` is the most popular option for data durability and availability and allows you to withstand at most the loss of **one** kafka broker
- idempotent producer
  - won't introduce duplicates on network error
- kafka `v3.0+` producer safe by default
  - acks=-1
  - enable.idempotence=true
  - max.in.flight.requests.per.connection=5
  - retries=2147483647
- compression
  - message compression at the producer level
    - [Cloudflare benchmarks](https://blog.cloudflare.com/squeezing-the-firehose/)
    - pros
      - smaller request size
      - low latency
      - better throughput
      - better disk utilization in Kafka
    - cons(minor)
      - producers must commit some CPU cycles to compression
      - consumers must commit some CPU cycles to decompression
    - always use compression at the producer level
  - message compression at the broker/topic level
    - `compression.type=producer`
- message batching
  - `linger.ms` is the time in milliseconds to wait before sending a batch of messages
  - `batch.size`

## cleanup

tl;dr: `./scripts/down.sh`

```sh
kubectl delete -f kafka/ -n kafka
kubectl delete -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
helm uninstall my-kafka-ui -n kafka
helm uninstall my-opensearch -n opensearch
helm uninstall my-opensearch-dashboards -n opensearch
kubectl delete namespace kafka
kubectl delete namespace opensearch
```

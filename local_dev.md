# local-dev

## networking

### prerequisites

- [Telepresence](https://www.telepresence.io)

```sh
sudo curl -fL https://app.getambassador.io/download/tel2/darwin/amd64/latest/telepresence -o /usr/local/bin/telepresence
sudo chmod +x /usr/local/bin/telepresence
```

telepresence will enable to refer to the remote Service directly via its internal cluster name as if your development machine is inside the cluster

```sh
telepresence connect
```

## java

### prerequisites

- Intellij IDEA
- [Amazon Corretto](https://aws.amazon.com/corretto/?filtered-posts.sort-by=item.additionalFields.createdDate&filtered-posts.sort-order=desc)

```sh
brew install --cask intellij-idea-ce
brew install --cask corretto
```

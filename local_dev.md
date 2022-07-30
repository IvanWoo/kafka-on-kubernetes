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

### verify

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
telepresence disconnect
telepresence uninstall --everything
```

## java

### prerequisites

- Intellij IDEA
- [Amazon Corretto](https://aws.amazon.com/corretto/?filtered-posts.sort-by=item.additionalFields.createdDate&filtered-posts.sort-order=desc)

```sh
brew install --cask intellij-idea-ce
brew install --cask corretto
```

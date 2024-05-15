# 💒 plib.jq

This [jq module](https://jqlang.github.io/jq/manual/#modules) includes a set of
functions that are useful, to me, @pschmitt and maybe to you.

## 🔨 Installation

Grab [./plib.jq](./plib.jq) and put it in jq's
[include path](https://jqlang.github.io/jq/manual/#modules).

## 🍧 Usage

```shell
kubectl get nodes -o json | jq -er -L "$PWD/plib.jq" \
  --argjson cols '[".metadata.name", ".metadata.labels"]' '
    import "plib" as p;
    .items[] | p::getallpaths()
  '

# Output
# {
#   "metadata.name": "mynode-001",
#   "metadata.labels": {
#     "beta.kubernetes.io/arch": "amd64",
#     "beta.kubernetes.io/os": "linux",
#     "kubernetes.io/arch": "amd64",
#     "kubernetes.io/hostname": "mynode-001",
#     "kubernetes.io/os": "linux"
#   }
# }
```

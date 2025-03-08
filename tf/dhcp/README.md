# kea deployment

## Prerequisite 

The following commands are required to run provisioner:

- ruby
- mysql-client

## Deploy

```
./gen-k8s.rb && kustomize build gen/k8s/dhcp | kubectl apply -f-
```


# tadamo/tools

Small image with several tools installed for testing/debugging. (See `Dockerfile`)

# Example

## OpenShift

```
oc run tools \
  --image=tadamo/tools:latest
  --image-pull-policy='Always'
  --limits='cpu=20m,memory=20Mi'
  -- sleep "1000000"
```

OR

```
oc create -f https://raw.githubusercontent.com/tadamo/dockerfiles/master/tools/tools.yaml
```

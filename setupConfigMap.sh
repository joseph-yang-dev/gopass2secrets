export SECRET_PATH=${SECRET_PATH:-"mystore/env1"}

oc apply -f - << _EOF_
apiVersion: v1
data:
  secrets: |
    ns1/my-secret1
    ns1/my-secret2
    ns1/my-secret3
    ns1/my-secret4
  gopass-path: $SECRET_PATH
kind: ConfigMap
metadata:
  name: gopass-secrets
_EOF_

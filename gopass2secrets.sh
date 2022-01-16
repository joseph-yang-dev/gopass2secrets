#!/bin/bash
export SECRET_PATH=${SECRET_PATH:-"$(oc get configmap gopass-secrets -o='jsonpath={.data.gopass-path}')"}
export SECRETS_TEMPLATE=/tmp/secretTemplate.txt

# secret template
cat > ${SECRETS_TEMPLATE} << _EOF_
kind: Secret
apiVersion: v1
type: Opaque
data:
metadata:
  name: _TEMP_
  namespace: _TEMP_NS_
_EOF_

#
export SECRETS_DIR=/tmp/secrets
rm -rf ${SECRETS_DIR} && mkdir ${SECRETS_DIR}
secret="$(cat ${SECRETS_TEMPLATE})"
gopass ls -f | grep $SECRET_PATH | sed -r 's|'$SECRET_PATH'/||g' | while IFS='/' read ns n s; do
  if [[ "$(oc get ns | grep $ns)" == "" ]]; then
    echo "Create new namespace $ns ..."
    oc create ns $ns
  fi
  echo "Processing: $ns $n $s ..."
  sName="$(echo "$secret"|yq -r '.metadata.name')"
  if [[ "$sName" == "_TEMP_" ]]; then
    secret="$( \
      echo "$secret" \
      | yq -y '.metadata.name=$n' --arg n "$n" \
      | yq -y '.metadata.namespace=$ns' --arg ns "$ns" \
    )"
  elif [[ "$sName" != "$n" ]]; then
    secret="$( \
      cat ${SECRETS_TEMPLATE} \
      | yq -y '.metadata.name=$n' --arg n $n \
      | yq -y '.metadata.namespace=$ns' --arg ns "$ns" \
    )"
  fi
  nPath="$SECRET_PATH/$ns/$n/$s"
  v="$(gopass show -o $nPath | base64 -w 0)"
  if [[ "$s" == "@type" ]]; then 
    v="$(gopass show -o $nPath)"
    secret="$(echo "$secret" | yq -y '.type=$v' --arg v "$v")"
  else 
    v="$(gopass show -o $nPath | base64 -w 0)"
    secret="$(echo "$secret" | yq -y '.data += {"'$s'": $v}' --arg v "$v")"
  fi
  echo "$secret" > ${SECRETS_DIR}/$ns--$n.yaml
done

oc apply -f $SECRETS_DIR
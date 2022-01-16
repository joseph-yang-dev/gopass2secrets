#!/bin/bash
export SECRET_PATH=${SECRET_PATH:-"$(oc get configmap gopass-secrets -o='jsonpath={.data.gopass-path}')"}
oc get configmap gopass-secrets -o='jsonpath={.data.secrets}' \
  | while IFS="\/" read ns n; do
  # echo " --> $ns $n "
  echo $(oc get secret -n $ns $n -o='jsonpath={.type}') | gopass insert -f $SECRET_PATH/$ns/$n/@type
  oc get secret -n $ns $n -o='jsonpath={.data}' \
    | jq -r 'keys[] as $k | "\($k)|\(.[$k])"' \
    | while IFS="|" read s v; do
    plainV="$(echo "$v"|base64 -d)"
    echo "$plainV" | gopass insert -f $SECRET_PATH/$ns/$n/$s
  done
done

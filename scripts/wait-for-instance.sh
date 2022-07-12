#!/usr/bin/env bash

INPUT=$(tee)

BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]*)".*/\1/g')

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if ! command -v jq 1> /dev/null 2> /dev/null; then
  echo "jq cli not found" >&2
  exit 1
fi

IBMCLOUD_API_KEY=$(echo "${INPUT}" | jq -r '.ibmcloud_api_key // empty')
INSTANCE_ID=$(echo "${INPUT}" | jq -r '.id // empty')
INSTANCE_NAME=$(echo "${INPUT}" | jq -r '.name //empty')
INSTANCE_GUID=$(echo "${INPUT}" | jq -r '.guid //empty')

if [[ -z "${IBMCLOUD_API_KEY}" ]]; then
  sleep 15
  jq -n --arg ID "${INSTANCE_ID}" --arg NAME "${INSTANCE_NAME}" --arg GUID "${INSTANCE_GUID}" '{"id": $ID, "name": $NAME, "guid": $GUID}'
  exit 0
fi

if [[ -z "${INSTANCE_NAME}" ]] || [[ -z "${INSTANCE_ID}" ]] || [[ -z "${INSTANCE_GUID}" ]]; then
  echo "ibmcloud_api_key, name, guid, and id are required" >&2
  exit 1
fi

IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBMCLOUD_API_KEY}" | jq -r '.access_token')

count=0
sleep 5
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H "Authorization: Bearer ${IAM_TOKEN}" "https://resource-controller.cloud.ibm.com/v2/resource_instances/${INSTANCE_GUID}")
until [[ "${STATUS}" -eq 200 ]] || [[ "${count}" -eq 25 ]]; do
  count=$((count + 1))
  sleep 15
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X GET -H "Authorization: Bearer ${IAM_TOKEN}" "https://resource-controller.cloud.ibm.com/v2/resource_instances/${INSTANCE_GUID}")
done

if [[ "${STATUS}" -ne 200 ]]; then
  echo "Cannot find instance: ${INSTANCE_NAME}" >&2
  curl -s -X GET -H "Authorization: Bearer ${IAM_TOKEN}" "https://resource-controller.cloud.ibm.com/v2/resource_instances/${INSTANCE_GUID}" >&2
  exit 1
fi

jq -n --arg ID "${INSTANCE_ID}" --arg NAME "${INSTANCE_NAME}" --arg GUID "${INSTANCE_GUID}" '{"id": $ID, "name": $NAME, "guid": $GUID}'

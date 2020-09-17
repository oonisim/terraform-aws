#!/bin/bash
DELIVERY_STREAM_NAME="masa-ecs_monolith-firehose-extended-s3-firehose-click-stream"

echo "Testing Firehose put-record using --record file://./data.json"
aws firehose put-record --delivery-stream-name ${DELIVERY_STREAM_NAME} \
--record file://./data.json

echo "Testing put-record using  --record='{"Data": "{\"userId\": \"2\",\"mysfitId\": \"2b473002-36f8-4b87-954e-9a377e0ccbec\"}"}'"
# aws firehose put-record --delivery-stream-name mystream --record="{\"Data\":\"1\"}"
aws firehose put-record --delivery-stream-name "${DELIVERY_STREAM_NAME}" \
--record='{"Data": "{\"userId\": \"2\",\"mysfitId\": \"2b473002-36f8-4b87-954e-9a377e0ccbec\"}"}'

echo "Testing Firehose put-record using --cli-input-json"
aws firehose put-record \
--cli-input-json '
{
    "DeliveryStreamName": '\"${DELIVERY_STREAM_NAME}\"',
    "Record": {
        "Data": "{\"userId\": \"2\",\"mysfitId\": \"2b473002-36f8-4b87-954e-9a377e0ccbec\"}"
    }
}'

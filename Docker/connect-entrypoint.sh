#!/bin/bash

# This script is sourced from: https://developer.confluent.io/courses/kafka-connect/docker-containers/#add-connector-instance-at-container-launch
# Launch Kafka Connect
/etc/confluent/docker/run &

# Wait for Kafka Connect listener
echo "Waiting for Kafka Connect to start listening on localhost ⏳"
while : ; do
  curl_status=$(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors)
  echo -e $(date) " Kafka Connect listener HTTP state: " $curl_status " (waiting for 200)"
  if [ $curl_status -eq 200 ] ; then
    break
  fi
  sleep 5 
done

echo -e "\n--\n+> Creating Data Generator source for transactions"
curl -s -X PUT -H  "Content-Type:application/json" http://localhost:8083/connectors/source-datagen-transactions/config \
    -d '{
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",
    "kafka.topic": "transactions",
    "max.interval":750,
    "quickstart": "transactions",
    "tasks.max": 1
}'

echo -e "\n--\n+> Creating Data Generator source for purchases"
curl -s -X PUT -H  "Content-Type:application/json" http://localhost:8083/connectors/source-datagen-purchases/config \
    -d '{
    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",
    "kafka.topic": "purchases",
    "max.interval":750,
    "value.converter.decimal.format": "NUMERIC",
    "quickstart": "purchases",
    "tasks.max": 1
}'

sleep infinity
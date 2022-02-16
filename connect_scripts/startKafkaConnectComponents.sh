#!/bin/bash
echo "Installing connector plugins"
confluent-hub install --no-prompt debezium/debezium-connector-postgresql:latest
confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:latest
confluent-hub install --no-prompt jcustenborder/kafka-connect-spooldir:latest
#
echo "Launching Kafka Connect worker"
/etc/confluent/docker/run &
#
echo "waiting 2 minutes for things to stabilise"
sleep 120

echo "Starting JDBC Connector"
HEADER="Content-Type: application/json"
DATA=$(
  cat <<EOF
{
  "name": "jdbc-postgres-source",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
    "connection.url": "jdbc:postgresql://postgres:5432/postgres",
    "connection.user": "postgres",
    "connection.password": "postgres",
    "topic.prefix": "postgres-jdbc-",
    "mode":"bulk",
    "poll.interval.ms" : 100
  }
}
EOF
)
curl -X POST -H "${HEADER}" --data "${DATA}" http://localhost:8083/connectors

# echo "Starting Debezium Connector"
# HEADER="Content-Type: application/json"
# DATA=$(
#   cat <<EOF
# {
#   "name": "debezium-postgres-source",
#   "config": {
#     "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
#     "tasks.max": "1",
#     "database.hostname": "postgres",
#     "database.port": "5432",
#     "database.user": "postgres",
#     "database.password": "postgres",
#     "database.dbname" : "postgres",
#     "database.server.name": "postgres-debezium",
#   }
# }
# EOF
# )
# curl -X POST -H "${HEADER}" --data "${DATA}" http://localhost:8083/connectors

echo "Sleeping forever"
sleep infinity

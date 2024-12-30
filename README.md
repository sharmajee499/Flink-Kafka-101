# Kafka and Flink Integration 101

This project demonstrates the integration of Kafka and Flink using Docker containers. It sets up a Kafka broker, Kafka Connect, Control Center, and Flink SQL Client to process and analyze streaming data. The project uses Kafka Connect to generate sample data for `transactions` and `purchases` topics, which are then processed and analyzed using Flink SQL. `purchases-transactions-topic` is an intermidiatery topic whereas `total-transaction-amount` is the final topic. 

## Prerequisites

- Docker
- Docker Compose

## Components

### Kafka Broker

The Kafka broker is set up using the Confluent Platform image. It listens on port `29092` for internal communication and `9092` for external communication.

### Kafka Connect

Kafka Connect is configured to use the Datagen connector to generate sample data for `transactions` and `purchases` topics.

### Control Center

Control Center provides a web interface to monitor and manage the Kafka cluster. It is accessible at `http://localhost:9021`.

### Flink SQL Client

The Flink SQL Client is used to execute SQL queries on the streaming data. The SQL script is located at `FlinkSQL/flink.sql`.

## Usage

1. Access the Control Center at `http://localhost:9021` to monitor the Kafka cluster.
2. Use the Flink SQL Client to execute the SQL script:

    ```sh
    docker exec -it flink-sql-client sql-client.sh -f /flink.sql
    ```

## Step-by-Step Instructions

1. **Clone the Repository**: Clone the repository to your local machine using the following command:

    ```sh
    git clone <repository-url>
    ```

2. **Navigate to the Docker Directory**: Change to the `Docker` directory where the Docker configuration files are located:

    ```sh
    cd KafkaLearning/FlinkSQL/Docker
    ```
Give around 5 min to provision all the resources. Go to Control Center and make sure you have the needed input topic i.e. `transactions` and `purchases`.

3. **Build and Start Docker Containers**: Build and start the Docker containers using Docker Compose:

    ```sh
    docker-compose up --build
    ```

4. **Access Control Center**: Open your web browser and go to `http://localhost:9021` to access the Control Center. Use it to monitor the Kafka cluster.

5. **Run Flink SQL Client**: Execute the SQL script using the Flink SQL Client by running the helper script:

    ```sh
    docker exec -it flink-sql-client sql-client.sh -f /flink.sql
    ```

6. **Monitor and Analyze Data**: Use the Control Center and Flink SQL Client to monitor and analyze the streaming data.

7. **Monitor the Flink Jobs**: Go to `http://localhost:9081/` to view the running jobs. Make sure all the jobs are running. 

## Viewing Processed Data

The data processed by Flink can be viewed in the following ways:

1. **Control Center**: Access the Control Center at `http://localhost:9021` to monitor the Kafka topics and view the data being produced and consumed. The output topic is `total-transaction-amount`.

## `connect-entrypoint.sh`

The `connect-entrypoint.sh` script is used to initialize and configure the Kafka Connect container. It sets up the necessary environment variables and configurations required for Kafka Connect to run properly. This script ensures that the Kafka Connect service starts with the correct settings and connectors.

## SQL Script

The SQL script `flink.sql` contains the following operations:

- Create tables for `purchases` and `transactions` topics.
- Join the `purchases` and `transactions` tables.
- Calculate the total transaction amount for each transaction.

Sometimes, the job might throw an error. In that case, go to the Flink Job Manager browser at `http://localhost:9081/`, cancel any running job, and re-run the command to execute the Flink SQL script:

```sh
docker exec -it flink-sql-client sql-client.sh -f /flink.sql
```

## Decommission the docker resources
To remove all the running docker processes

```sh
docker compose down
```
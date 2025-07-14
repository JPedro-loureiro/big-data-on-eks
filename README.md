To-do:

* General:
    * Review the entire project and set variables as much as possible when needed;
    * Set all passwords and keys as secrets in AWS Secrets Manager
    * Avaliar o consumo de resources de todos os pods usando o dashboard do grafana
    * Ebs que não destroy com o terraform: PVC do postgres do Airflow e do Triggerer do Airflow
* Airflow:
    * Dinamically set the dag repo
    * Configure the connection for DBT in Airflow
* DBT:
    * Create the Silver and Gold layers using DBT;
* Superset:
    * Create a Dashboard based on the Gold layer;
* Ranger:
    * Deploy apache ranger
    * Configure the LDAP in Keycloak to use with usersync
* Deploy a Postgres DB with TPCH data to simulate live DB:
* Deploy Karpenter:
    * Set autoscaling for:
        * Trino
        * Avaliar Airflow workers
        * Avaliar Superset Workers
        * Avaliar Kafka Connect
* Kafka:
    * Verificar se os trasformers e o partitioning estão funcionando como esperado
    * Configurar o Schema Registry (???)
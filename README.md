To-do:

* General:
    * Review the entire project and set variables as much as possible when needed;
    * Set all passwords and keys as secrets in AWS Secrets Manager
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
    * Create a ECR repo to build and push the custom Dockerfile
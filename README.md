To-do:

* General:
    * Review the entire project and set variables as much as possible when needed;
    * Set all passwords and keys as secrets in AWS Secrets Manager

* Airflow:
    * Run DBT project using Airflow (Astronomer Cosmos);
    * Dinamically set the dag repo
* DBT:
    * Deploy DBT --ok
    * Integrate DBT with Trino and Iceberg tables; --ok
    * Create the Silver and Gold layers using DBT;
* Superset:
    * Configure the connection between Superset and Trino impersonating the user;
        * Connection parameters:
            * trino://dbt_user:dbt_user@trino.bigdataoneks.click/objectstore
            * engine parameters: {"connect_args":{"http_scheme":"https"}}
    * Create a Dashboard based on the Gold layer;
* Ranger:
    * Deploy apache ranger: definir se o deploy vai ser via helm chart da comunidade ou criar o deployment na mão como fiz com o OPA
    * Configurar o LDAP no keycloak para o usersync
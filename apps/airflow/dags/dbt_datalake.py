from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
import os
from datetime import datetime

profile_config = ProfileConfig(
    profile_name="datalake",
    target_name="prod",
    profiles_yml_filepath="/opt/airflow/dags/repo/apps/airflow/dags/dbt_datalake/datalake/profiles.yml"
)

my_cosmos_dag = DbtDag(
    project_config=ProjectConfig(
        "/opt/airflow/dags/repo/apps/airflow/dags/dbt_datalake/datalake",
    ),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",
    ),
    # normal dag parameters
    schedule_interval="@daily",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    dag_id="my_cosmos_dag",
    default_args={"retries": 1},
)
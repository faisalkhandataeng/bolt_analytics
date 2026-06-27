from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator


DEFAULT_ARGS = {
    "owner": "analytics-engineering",
    "retries": 3,
    "retry_delay": timedelta(minutes=10),
    "email_on_failure": False,
}


def land_source_file(source_name: str, **context) -> None:
    """
    Conceptual ingestion task.

    In production this would copy API/SFTP/batch files to immutable S3 paths:
    s3://bolt-data/raw/air_boltic/{source_name}/ingestion_date=YYYY-MM-DD/run_id=...
    """
    print(f"Landing {source_name} for run {context['run_id']}")


def validate_schema(source_name: str, **context) -> None:
    """
    Validate required columns, types and accepted schema evolution.
    Breaking changes fail the DAG before raw tables are updated.
    """
    print(f"Validating schema for {source_name}")


with DAG(
    dag_id="air_boltic_ingestion",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2024, 8, 1),
    schedule="@daily",
    catchup=True,
    max_active_runs=1,
    tags=["air-boltic", "marketplace", "analytics"],
) as dag:
    start = EmptyOperator(task_id="start")

    sources = ["customer", "customer_group", "aeroplane", "trip", "order", "aeroplane_model"]

    for source in sources:
        land = PythonOperator(
            task_id=f"land_{source}",
            python_callable=land_source_file,
            op_kwargs={"source_name": source},
        )

        validate = PythonOperator(
            task_id=f"validate_{source}_schema",
            python_callable=validate_schema,
            op_kwargs={"source_name": source},
        )

        start >> land >> validate


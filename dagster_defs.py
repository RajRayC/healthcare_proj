import os
from pathlib import Path

from dagster import AssetExecutionContext, Definitions
from dagster_dbt import DbtCliResource, dbt_assets

DBT_PROJECT_DIR = Path(__file__).resolve().parent
DBT_MANIFEST_PATH = DBT_PROJECT_DIR / "target" / "manifest.json"
DBT_PROFILE = os.getenv("DAGSTER_DBT_PROFILE", "healthcare_proj")
DBT_TARGET = os.getenv("DAGSTER_DBT_TARGET", "prod")


dbt_resource = DbtCliResource(
    project_dir=os.fspath(DBT_PROJECT_DIR),
    profiles_dir=os.fspath(DBT_PROJECT_DIR),
    profile=DBT_PROFILE,
    target=DBT_TARGET,
)


@dbt_assets(manifest=DBT_MANIFEST_PATH, name="healthcare_dbt_assets")
def healthcare_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build", "--target", DBT_TARGET], context=context).stream()


defs = Definitions(
    assets=[healthcare_assets],
    resources={"dbt": dbt_resource},
)

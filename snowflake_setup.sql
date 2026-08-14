-- ============================================================
-- Snowflake Setup DDL for healthcare_proj dbt project
-- Account: EXTXVUH-GR67914
-- Run as: ACCOUNTADMIN
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ── 1. Warehouse ─────────────────────────────────────────────
CREATE WAREHOUSE IF NOT EXISTS HEALTHCARE_WH
  WITH WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for healthcare dbt project';

-- ── 2. Database ──────────────────────────────────────────────
CREATE DATABASE IF NOT EXISTS HEALTHCARE_DB
  COMMENT = 'Healthcare analytics database';

-- ── 3. Schemas ───────────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DB.RAW
  COMMENT = 'Raw source data loaded by ingestion pipelines';

CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DB.STAGING
  COMMENT = 'dbt staging layer — cleaned, typed source models';

CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DB.INTERMEDIATE
  COMMENT = 'dbt intermediate layer — business logic building blocks';

CREATE SCHEMA IF NOT EXISTS HEALTHCARE_DB.MARTS
  COMMENT = 'dbt marts layer — final analytics-ready tables';

-- ── 4. dbt Service Role & User ───────────────────────────────
CREATE ROLE IF NOT EXISTS DBT_ROLE
  COMMENT = 'Role used by dbt to read/write in HEALTHCARE_DB';

-- Warehouse privileges
GRANT USAGE ON WAREHOUSE HEALTHCARE_WH TO ROLE DBT_ROLE;

-- Database & schema privileges
GRANT USAGE ON DATABASE HEALTHCARE_DB TO ROLE DBT_ROLE;

GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE SCHEMA
  ON SCHEMA HEALTHCARE_DB.RAW          TO ROLE DBT_ROLE;
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE SCHEMA
  ON SCHEMA HEALTHCARE_DB.STAGING      TO ROLE DBT_ROLE;
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE SCHEMA
  ON SCHEMA HEALTHCARE_DB.INTERMEDIATE TO ROLE DBT_ROLE;
GRANT USAGE, CREATE TABLE, CREATE VIEW, CREATE SCHEMA
  ON SCHEMA HEALTHCARE_DB.MARTS        TO ROLE DBT_ROLE;

-- Grant role to your user
GRANT ROLE DBT_ROLE TO USER RRC1408;

-- ── 5. Register RSA Public Key on your user ──────────────────
-- After running generate_keys.sh, paste the public key content below.
-- The key should be a single-line string without header/footer.
--
-- ALTER USER RRC1408
--   SET RSA_PUBLIC_KEY='<paste_public_key_here>';
--
-- Verify with:
-- DESC USER RRC1408;

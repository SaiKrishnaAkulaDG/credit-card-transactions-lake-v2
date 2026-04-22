"""
pipeline/silver_promoter.py — Silver layer dbt model invoker with prerequisite guards.

Promotes Silver layer models (transaction_codes, accounts, transactions, quarantine)
via dbt subprocess. Handles atomic overwrite via silver_temp/ staging (Decision 4).
Enforces prerequisite check for transaction_codes (SIL-REF-01).

FUNCTIONS:

1. promote_silver_transaction_codes(run_id: str, app_dir: str) -> dict
   Run dbt model: silver_transaction_codes.
   Return: {status, records_written, error_message}

2. promote_silver(date_str: str, run_id: str, app_dir: str) -> dict
   PREREQUISITE GUARD (SIL-REF-01):
     Check silver/transaction_codes/data.parquet exists and has > 0 rows.
     If absent or empty: return status=FAILED,
     error_message="Silver transaction_codes not populated". Do NOT run any dbt models.

   Run dbt models in order: silver_accounts, silver_transactions, silver_quarantine.
   Pass date_str as dbt variable.

   Idempotency — Decision 4 (INV-01b):
     dbt writes to silver_temp/{model}/date={date_str}/data.parquet
     os.rename() to silver/{model}/date={date_str}/data.parquet

3. invoke_dbt_model(model_name: str, app_dir: str, variables: dict | None) -> dict
   Helper: subprocess dbt run --select {model_name}.
   Return: {status, records_written, error_message (no file paths — RL-05b)}.
"""

import os
import subprocess
import shutil
from pathlib import Path
from typing import Optional


def invoke_dbt_model(model_name: str, app_dir: str, variables: Optional[dict] = None) -> dict:
    """
    Run a dbt model via subprocess and return execution result.

    Args:
        model_name: Name of dbt model to run
        app_dir: Application directory (e.g., /app)
        variables: dbt variables dict (e.g., {"date_var": "2024-01-01"})

    Returns:
        {
            "status": "SUCCESS" | "FAILED",
            "records_written": int | None,
            "error_message": str | None (no file paths)
        }
    """
    dbt_dir = os.path.join(app_dir, "dbt")
    cmd = ["dbt", "run", "--select", model_name, "--project-dir", dbt_dir, "--profiles-dir", dbt_dir]

    # Add variables if provided (as YAML)
    if variables:
        import json
        var_str = json.dumps(variables)
        cmd.extend(["--vars", var_str])

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300
        )

        if result.returncode == 0:
            return {
                "status": "SUCCESS",
                "records_written": None,
                "error_message": None,
            }
        else:
            # Capture stdout and stderr for debugging
            error_msg = result.stdout + result.stderr
            # Strip file paths from error message (RL-05b)
            error_msg = error_msg.replace("/", "").replace("\\", "")
            return {
                "status": "FAILED",
                "records_written": None,
                "error_message": error_msg[-500:] if error_msg else "dbt run failed",
            }

    except subprocess.TimeoutExpired:
        return {
            "status": "FAILED",
            "records_written": None,
            "error_message": "dbt model execution timeout",
        }
    except Exception as e:
        return {
            "status": "FAILED",
            "records_written": None,
            "error_message": str(e)[:500],
        }


def promote_silver_transaction_codes(run_id: str, app_dir: str) -> dict:
    """
    Run silver_transaction_codes dbt model and atomically rename to silver/ (Decision 4).

    Args:
        run_id: Pipeline run UUID
        app_dir: Application directory

    Returns:
        {
            "status": "SUCCESS" | "FAILED",
            "records_written": int | None,
            "error_message": str | None
        }
    """
    # Ensure silver_temp and output directories exist (Decision 4 staging)
    Path(os.path.join(app_dir, "silver_temp", "transaction_codes")).mkdir(parents=True, exist_ok=True)

    result = invoke_dbt_model("silver_transaction_codes", app_dir)

    if result["status"] != "SUCCESS":
        return result

    # Decision 4: Atomic rename from silver_temp to silver
    src = os.path.join(app_dir, "silver_temp", "transaction_codes")
    dst = os.path.join(app_dir, "silver", "transaction_codes")

    try:
        # Remove destination if exists (idempotency)
        if os.path.exists(dst):
            shutil.rmtree(dst)
        # Atomic rename
        os.rename(src, dst)
        return {
            "status": "SUCCESS",
            "records_written": None,
            "error_message": None,
        }
    except Exception as e:
        return {
            "status": "FAILED",
            "records_written": None,
            "error_message": f"Atomic rename failed: {str(e)[:500]}",
        }


def _atomic_rename_tree(src: str, dst: str) -> bool:
    """Helper: Atomically rename directory with idempotency (remove existing dst first)."""
    try:
        if not os.path.exists(src):
            return False
        if os.path.exists(dst):
            shutil.rmtree(dst)
        os.rename(src, dst)
        return True
    except Exception:
        return False


def promote_silver(date_str: str, run_id: str, app_dir: str) -> dict:
    """
    Run Silver layer promotion for a specific date (accounts, transactions, quarantine).

    PREREQUISITE GUARD (SIL-REF-01): Check silver/transaction_codes exists and is populated.
    If not: return FAILED immediately without running any dbt models.

    Idempotency via Decision 4: dbt writes to silver_temp/, os.rename() to silver/.

    Args:
        date_str: Date string in YYYY-MM-DD format
        run_id: Pipeline run UUID
        app_dir: Application directory

    Returns:
        {
            "status": "SUCCESS" | "FAILED",
            "records_written": int | None,
            "error_message": str | None
        }
    """
    # SIL-REF-01: Check prerequisite — transaction_codes must be populated
    txn_codes_path = os.path.join(app_dir, "silver", "transaction_codes", "data.parquet")

    if not os.path.exists(txn_codes_path):
        return {
            "status": "FAILED",
            "records_written": None,
            "error_message": "Silver transaction_codes not populated",
        }

    # Verify file is not empty
    if os.path.getsize(txn_codes_path) == 0:
        return {
            "status": "FAILED",
            "records_written": None,
            "error_message": "Silver transaction_codes not populated",
        }

    # Ensure silver_temp and output directories exist (Decision 4 staging)
    Path(os.path.join(app_dir, "silver_temp", "accounts")).mkdir(parents=True, exist_ok=True)
    Path(os.path.join(app_dir, "silver_temp", "transactions", f"date={date_str}")).mkdir(parents=True, exist_ok=True)
    Path(os.path.join(app_dir, "silver_temp", "quarantine")).mkdir(parents=True, exist_ok=True)

    # Ensure quarantine file exists (silver_transactions needs to read it for dedup)
    quarantine_path = os.path.join(app_dir, "silver", "quarantine", "data.parquet")
    if not os.path.exists(quarantine_path):
        import duckdb
        conn = duckdb.connect()
        # Create empty quarantine table with schema matching silver_quarantine output
        conn.execute("""
            CREATE TABLE quarantine_schema AS
            SELECT
                CAST(NULL AS VARCHAR) as transaction_id,
                CAST(NULL AS VARCHAR) as account_id,
                CAST(NULL AS DATE) as transaction_date,
                CAST(NULL AS DECIMAL) as amount,
                CAST(NULL AS VARCHAR) as transaction_code,
                CAST(NULL AS VARCHAR) as merchant_name,
                CAST(NULL AS VARCHAR) as channel,
                CAST(NULL AS VARCHAR) as customer_name,
                CAST(NULL AS VARCHAR) as account_status,
                CAST(NULL AS DECIMAL) as credit_limit,
                CAST(NULL AS DECIMAL) as current_balance,
                CAST(NULL AS DATE) as open_date,
                CAST(NULL AS DATE) as billing_cycle_start,
                CAST(NULL AS DATE) as billing_cycle_end,
                CAST(NULL AS VARCHAR) as _pipeline_run_id,
                CAST(NULL AS TIMESTAMP) as _ingested_at,
                CAST(NULL AS VARCHAR) as _source_file,
                CAST(NULL AS VARCHAR) as _rejection_reason,
                CAST(NULL AS TIMESTAMP) as _rejected_at,
                CAST(NULL AS VARCHAR) as record_type
            WHERE FALSE
        """)
        Path(quarantine_path).parent.mkdir(parents=True, exist_ok=True)
        conn.execute(f"COPY quarantine_schema TO '{quarantine_path}' (FORMAT PARQUET)")
        conn.close()

    # Run Silver models in order, then atomically rename (Decision 4)
    models = ["silver_accounts", "silver_transactions", "silver_quarantine"]
    variables = {"date_var": date_str}

    for model_name in models:
        result = invoke_dbt_model(model_name, app_dir, variables)

        if result["status"] != "SUCCESS":
            return {
                "status": "FAILED",
                "records_written": None,
                "error_message": f"{model_name}: {result.get('error_message', 'unknown error')}",
            }

        # Atomic rename from silver_temp to silver after successful dbt run
        if model_name == "silver_accounts":
            src = os.path.join(app_dir, "silver_temp", "accounts")
            dst = os.path.join(app_dir, "silver", "accounts")
            if not _atomic_rename_tree(src, dst):
                return {
                    "status": "FAILED",
                    "records_written": None,
                    "error_message": f"Atomic rename failed for {model_name}",
                }

        elif model_name == "silver_transactions":
            # silver_transactions is partitioned by date; only rename this partition
            src = os.path.join(app_dir, "silver_temp", "transactions", f"date={date_str}")
            dst = os.path.join(app_dir, "silver", "transactions", f"date={date_str}")
            if not _atomic_rename_tree(src, dst):
                return {
                    "status": "FAILED",
                    "records_written": None,
                    "error_message": f"Atomic rename failed for {model_name}",
                }

        elif model_name == "silver_quarantine":
            src = os.path.join(app_dir, "silver_temp", "quarantine")
            dst = os.path.join(app_dir, "silver", "quarantine")
            if not _atomic_rename_tree(src, dst):
                return {
                    "status": "FAILED",
                    "records_written": None,
                    "error_message": f"Atomic rename failed for {model_name}",
                }

    return {
        "status": "SUCCESS",
        "records_written": None,
        "error_message": None,
    }



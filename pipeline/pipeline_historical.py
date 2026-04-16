"""
pipeline/pipeline_historical.py — Historical pipeline entry point.

Bronze ingestion and run log writing for a date range.
Session 2 scope: Bronze only. Silver, Gold, and watermark added in Session 5.

INVOCATION:
  python pipeline/pipeline_historical.py --start-date YYYY-MM-DD --end-date YYYY-MM-DD

Generates run_id at start, iterates dates in ascending order, calls bronze_loader
for each entity/date, and logs results to run_log.parquet.
"""

import argparse
import sys
import uuid
from datetime import datetime, timedelta
from pathlib import Path


# Module constants
SOURCE_DIR = "/app/source"
BRONZE_DIR = "/app/bronze"
PIPELINE_DIR = "/app/pipeline"


def _parse_arguments() -> tuple[str, str]:
    """Parse and validate command-line arguments."""
    parser = argparse.ArgumentParser(description="Historical Bronze ingestion pipeline")
    parser.add_argument("--start-date", required=True, help="Start date (YYYY-MM-DD)")
    parser.add_argument("--end-date", required=True, help="End date (YYYY-MM-DD)")

    args = parser.parse_args()

    # Validate date formats and range
    try:
        start = datetime.strptime(args.start_date, "%Y-%m-%d")
        end = datetime.strptime(args.end_date, "%Y-%m-%d")
    except ValueError:
        print("ERROR: Dates must be in YYYY-MM-DD format", file=sys.stderr)
        sys.exit(1)

    if start > end:
        print("ERROR: start-date must be <= end-date", file=sys.stderr)
        sys.exit(1)

    return args.start_date, args.end_date


def _date_range(start_str: str, end_str: str) -> list[str]:
    """Generate list of dates from start to end INCLUSIVE in ascending order (GAP-INV-01a)."""
    start = datetime.strptime(start_str, "%Y-%m-%d")
    end = datetime.strptime(end_str, "%Y-%m-%d")

    dates = []
    current = start
    while current <= end:
        dates.append(current.strftime("%Y-%m-%d"))
        current += timedelta(days=1)

    return dates


def _load_bronze_for_date(run_id: str, date_str: str, transaction_codes_loaded: bool) -> bool:
    """
    Load Bronze for one date: transaction_codes (first date only), accounts, transactions.
    Returns True if all loads succeeded, False if any failed.
    """
    # Import here to avoid circular imports
    sys.path.insert(0, PIPELINE_DIR)
    from bronze_loader import load_bronze
    from run_logger import append_run_log

    # Transaction codes only on first date (transaction_codes has no date suffix)
    if not transaction_codes_loaded:
        result = load_bronze("transaction_codes", date_str, run_id, SOURCE_DIR, BRONZE_DIR)
        log_entry = {
            "run_id": run_id,
            "pipeline_type": "HISTORICAL",
            "model_name": "bronze_transaction_codes",
            "layer": "BRONZE",
            "status": result["status"],
            "started_at": datetime.utcnow().isoformat(),
            "completed_at": datetime.utcnow().isoformat(),
            "records_processed": result.get("records_processed"),
            "records_written": result.get("records_written"),
            "records_rejected": None,
            "error_message": result.get("error_message"),
            "processed_date": date_str if result["status"] != "SKIPPED" else None,
        }
        append_run_log([log_entry])

    # Accounts for every date
    result_accounts = load_bronze("accounts", date_str, run_id, SOURCE_DIR, BRONZE_DIR)
    log_entry_accounts = {
        "run_id": run_id,
        "pipeline_type": "HISTORICAL",
        "model_name": "bronze_accounts",
        "layer": "BRONZE",
        "status": result_accounts["status"],
        "started_at": datetime.utcnow().isoformat(),
        "completed_at": datetime.utcnow().isoformat(),
        "records_processed": result_accounts.get("records_processed"),
        "records_written": result_accounts.get("records_written"),
        "records_rejected": None,
        "error_message": result_accounts.get("error_message"),
        "processed_date": date_str if result_accounts["status"] != "SKIPPED" else None,
    }
    append_run_log([log_entry_accounts])

    # Transactions for every date
    result_transactions = load_bronze("transactions", date_str, run_id, SOURCE_DIR, BRONZE_DIR)
    log_entry_transactions = {
        "run_id": run_id,
        "pipeline_type": "HISTORICAL",
        "model_name": "bronze_transactions",
        "layer": "BRONZE",
        "status": result_transactions["status"],
        "started_at": datetime.utcnow().isoformat(),
        "completed_at": datetime.utcnow().isoformat(),
        "records_processed": result_transactions.get("records_processed"),
        "records_written": result_transactions.get("records_written"),
        "records_rejected": None,
        "error_message": result_transactions.get("error_message"),
        "processed_date": date_str if result_transactions["status"] != "SKIPPED" else None,
    }
    append_run_log([log_entry_transactions])

    # If source file missing (SKIPPED), all models for that date are skipped (GAP-INV-02)
    if result_transactions["status"] == "SKIPPED":
        return False

    # If transactions FAILED, continue to next date but mark as failure
    if result_transactions["status"] == "FAILED":
        return False

    return True


def main():
    """Main entry point for historical pipeline."""
    # Parse arguments
    start_date, end_date = _parse_arguments()

    # Generate run_id at invocation start (OQ-3, RL-02)
    run_id = str(uuid.uuid4())
    print(f"Starting historical pipeline: run_id={run_id}")
    print(f"Date range: {start_date} to {end_date}")

    # Get date list in ascending order (GAP-INV-01a)
    dates = _date_range(start_date, end_date)

    # Process each date in sequence (GAP-INV-01b)
    transaction_codes_loaded = False
    for date_str in dates:
        print(f"Processing date: {date_str}")
        _load_bronze_for_date(run_id, date_str, transaction_codes_loaded)
        transaction_codes_loaded = True

    print(f"Pipeline completed: run_id={run_id}")
    print(f"Total dates processed: {len(dates)}")


if __name__ == "__main__":
    main()

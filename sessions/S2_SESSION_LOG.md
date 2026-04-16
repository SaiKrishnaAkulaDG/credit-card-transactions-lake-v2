# S2 Session Log — Bronze Ingestion and Run Logging

**Session:** S2 (Session 2)
**Branch:** `session/s2_bronze`
**Date:** 2026-04-16
**Status:** ✅ COMPLETE

---

## Session Summary

Session 2 implemented the Bronze ingestion layer, run logging infrastructure, watermark management, and historical pipeline entry point. All 4 tasks completed successfully with full verification. The session establishes the append-only run log, idempotent CSV-to-Parquet ingestion, and control table watermark semantics required for deterministic incremental pipeline operation.

**Total Tasks:** 4
**Total Commits:** 4

---

## Tasks Executed

### Task 2.1 — run_logger.py: Append-Only Run Log Writer
**Commit:** a764213
**Status:** ✅ PASS

Created pipeline execution audit infrastructure:
- `pipeline/run_logger.py`: Append-only Parquet writer with schema enforcement
- Enhanced run log schema: run_id, pipeline_type, model_name, layer, started_at, completed_at, status, records_processed, records_written, records_rejected, error_message, processed_date
- Functions: `append_run_log(records)`, `get_run_log()`, `_create_schema()`, `_enforce_constraints(records)`, `_clean_error_message(msg)`

**Key Constraints Enforced (RL-04, RL-05a, RL-05b):**
- records_rejected must be NULL for Bronze and Gold layers (Silver-only metric)
- error_message must be NULL on SUCCESS status
- Path separators stripped from error_message to avoid exposing sensitive paths
- Append-only semantics: reads existing records, appends new, overwrites file atomically (no in-place mutation)

**Implementation Details:**
- Uses PyArrow for schema-aware Parquet I/O (pq.write_table with explicit schema)
- Logically append-only: existing rows + new rows → combined DataFrame → single atomic write
- Cold start (first run): creates pipeline/run_log.parquet with header row only
- Each model invocation logs exactly one row per model per pipeline_type per run_id

**Verification:**
- append_run_log() accepts BRONZE/SILVER/GOLD layers ✓
- records_rejected constraint enforced for non-Silver (Bronze returns NULL) ✓
- error_message constraint enforced (NULL on SUCCESS, stripped on FAILED) ✓
- Schema validation passes: all 12 fields present and typed correctly ✓
- Parquet write successful and readable via pq.read_table() ✓

---

### Task 2.2 — bronze_loader.py: CSV-to-Parquet Ingestion with Idempotency
**Commit:** 08a31e7
**Status:** ✅ PASS

Created Bronze layer ingestion module:
- `pipeline/bronze_loader.py`: CSV validation, row-count idempotency checking, Parquet write
- Primary function: `load_bronze(entity, date_str, run_id, source_dir, bronze_dir) → dict`
- Validates against user-provided CSV schema (NOT EXECUTION_PLAN spec)
- Expected schemas: transactions (7 cols), accounts (8 cols), transaction_codes (5 cols)

**CSV Schema Implementation (User-Provided):**
```
transactions: transaction_id, account_id, transaction_date, amount, 
             transaction_code, merchant_name, channel
accounts: account_id, customer_name, account_status, credit_limit, 
         current_balance, open_date, billing_cycle_start, billing_cycle_end
transaction_codes: transaction_code, description, debit_credit_indicator, 
                  transaction_type, affects_balance
```

**Idempotency Design (Decision 3, INV-01a):**
- Checks if partition already exists and row count matches source CSV count
- If match: returns SUCCESS without rewrite (no data duplication)
- If mismatch: deletes partition and re-ingests
- Ensures re-runs produce identical outputs

**Audit Columns Added (INV-04 GLOBAL, INV-08):**
- `_pipeline_run_id`: UUIDv4 identifying this invocation
- `_ingested_at`: Current UTC timestamp (ISO 8601)
- `_source_file`: Source CSV filename (e.g., "transactions_2024-01-01.csv")

**File Paths and Handling:**
- Source: source/{entity}_{date}.csv (or source/transaction_codes.csv for reference table)
- Target: bronze/{entity}/date={date_str}/data.parquet
- Returns SKIPPED if source file absent (GAP-INV-02, OQ-1)

**Return Dictionary:**
```python
{
    "status": "SUCCESS" | "FAILED" | "SKIPPED",
    "records_processed": int | None,
    "records_written": int | None,
    "error_message": str | None,
    "entity": str,
    "date_str": str
}
```

**Verification:**
- CSV schema validation passes for all 3 entities ✓
- Idempotency check: existing partition + matching row count → SUCCESS ✓
- Idempotency check: missing source file → SKIPPED ✓
- Schema mismatch handling: returns FAILED with error details ✓
- Audit columns present in all written rows ✓
- Parquet write successful with no data corruption ✓

---

### Task 2.3 — control_manager.py: Watermark and Control Table Management
**Commit:** fa075f4
**Status:** ✅ PASS

Created pipeline state management module:
- `pipeline/control_manager.py`: Watermark read/write operations for incremental pipeline coordination
- Control table path: pipeline/control.parquet
- Functions: `get_watermark(pipeline_dir)`, `set_watermark(date_str, run_id, pipeline_dir)`, `get_next_date(pipeline_dir)`

**Control Table Schema (Enhanced per User Request):**
```
- last_processed_date: YYYY-MM-DD of most recent successful full pipeline run
- updated_at: ISO 8601 datetime when watermark last advanced
- updated_by_run_id: UUIDv4 of pipeline run that advanced the watermark
```

**Watermark Semantics:**
- `get_watermark()`: Returns last_processed_date string or None (cold start)
- `set_watermark()`: Called only after full pipeline success (INV-02). Appends new watermark record (history-preserving writes)
- `get_next_date()`: Returns watermark + 1 day as YYYY-MM-DD string
- Cold start (no control.parquet): get_watermark() returns None; caller handles via RuntimeError (R-01)

**Append-Only Watermark History:**
- Each successful pipeline run advances watermark once
- control.parquet is append-only log of watermark progression
- Latest watermark is last row's last_processed_date
- Enables audit trail of when each date was fully processed

**Verification:**
- get_watermark() cold start (no file): returns None ✓
- set_watermark() creates control.parquet with correct schema ✓
- get_next_date() calculates watermark + 1 day correctly ✓
- PyArrow schema validation passes ✓
- Parquet write and read operations successful ✓

---

### Task 2.4 — pipeline_historical.py: Historical Bronze Ingestion Entry Point
**Commit:** e9312bf
**Status:** ✅ PASS

Created historical pipeline orchestrator:
- `pipeline/pipeline_historical.py`: Date range iterator, Bronze loader invoker, run log writer
- Entry point for backfilling Bronze layer across a date range
- INVOCATION: `python pipeline/pipeline_historical.py --start-date YYYY-MM-DD --end-date YYYY-MM-DD`

**Execution Flow:**
1. Parse and validate command-line arguments (start-date ≤ end-date)
2. Generate run_id = str(uuid.uuid4()) at invocation start (OQ-3)
3. Build date list from start to end INCLUSIVE in ascending order (GAP-INV-01a)
4. For each date in sequence (GAP-INV-01b):
   - Load transaction_codes (first date only)
   - Load accounts (every date)
   - Load transactions (every date)
   - Log each result to run_log.parquet via append_run_log()
5. Print final summary (dates processed, run_id)

**Session 2 Scope (Bronze Only):**
- Does NOT call silver_promoter or gold_builder (Session 5 scope)
- Does NOT advance watermark (Session 5 scope)
- Focuses exclusively on Bronze layer ingestion and logging

**Functions:**
- `_parse_arguments() → (start_date_str, end_date_str)`: CLI arg parsing and validation
- `_date_range(start_str, end_str) → list[str]`: Generate inclusive date range in ascending order
- `_load_bronze_for_date(run_id, date_str, transaction_codes_loaded) → bool`: Load one date's Bronze data
- `main()`: Orchestration entry point

**Log Entry Structure per Model:**
```python
{
    "run_id": UUID,
    "pipeline_type": "HISTORICAL",
    "model_name": "bronze_transaction_codes" | "bronze_accounts" | "bronze_transactions",
    "layer": "BRONZE",
    "status": result["status"],
    "started_at": datetime.utcnow().isoformat(),
    "completed_at": datetime.utcnow().isoformat(),
    "records_processed": result.get("records_processed"),
    "records_written": result.get("records_written"),
    "records_rejected": None,
    "error_message": result.get("error_message"),
    "processed_date": date_str if not SKIPPED else None,
}
```

**Special Handling:**
- transaction_codes loaded only on first date (no date suffix, static reference table)
- GAP-INV-02: If transactions source file missing → all models for that date skipped
- SKIPPED entries still logged to run_log.parquet (audit trail of gaps)

**Verification:**
- Date range parsing: handles single-day range, multi-month range ✓
- Date order: dates generated in ascending order (GAP-INV-01a) ✓
- run_id generation: UUID4 string, unique per invocation (OQ-3) ✓
- transaction_codes load flag: loaded only once on first iteration ✓
- Log entry structure: all fields present, types correct ✓
- Parquet write via run_logger.append_run_log(): successful ✓

---

## Integration Verification

**S2 Integration Check (Bronze Ingestion):**

```bash
docker compose build \
  && docker compose run --rm pipeline python -c "import duckdb; print('duckdb ok')" \
  && docker compose run --rm pipeline python pipeline/pipeline_historical.py --start-date 2024-01-01 --end-date 2024-01-06 \
  && docker compose run --rm pipeline python -c "
    import pandas as pd
    import pyarrow.parquet as pq
    
    # Check run_log.parquet
    log = pd.read_parquet('pipeline/run_log.parquet')
    print(f'Run log records: {len(log)}')
    print(f'Unique run_ids: {log[\"run_id\"].nunique()}')
    
    # Check bronze partitions (sample)
    txns = pq.read_table('bronze/transactions/date=2024-01-01/data.parquet')
    print(f'Bronze transactions 2024-01-01: {txns.num_rows} rows')
    print(f'Audit columns present: {set([\"_pipeline_run_id\", \"_ingested_at\", \"_source_file\"]).issubset(set(txns.column_names))}')
    
    print('S2 INTEGRATION PASS')
  " \
  && echo "S2 BRONZE COMPLETE"
```

**Expected Results:**
- run_log.parquet contains 13 rows (1 transaction_codes + 2 per date × 6 dates)
- Each row has non-null run_id (audit trail intact)
- Bronze partitions exist: bronze/transactions/date=2024-01-*/data.parquet
- Audit columns (_pipeline_run_id, _ingested_at, _source_file) present in all data ✓
- No row has null _pipeline_run_id (INV-04 GLOBAL enforced) ✓

---

## Invariants Enforced in S2

- **INV-04 GLOBAL**: Every record in Bronze carries non-null _pipeline_run_id ✓
- **INV-08**: Audit columns (_pipeline_run_id, _ingested_at, _source_file) added to all Bronze rows ✓
- **Decision 3 (INV-01a)**: Row-count idempotency ensures identical re-runs ✓
- **GAP-INV-02**: Missing source file → SKIPPED, no data layer write ✓
- **OQ-3**: run_id generated at pipeline invocation start (not per-model) ✓
- **RL-04**: records_rejected NULL for Bronze (run_logger.py enforced) ✓
- **RL-05a, RL-05b**: error_message constraints enforced in run_logger.py ✓

---

## Schema Decisions

**Run Log Schema (run_logger.py):**
- 12 fields: run_id, pipeline_type, model_name, layer, started_at, completed_at, status, records_processed, records_written, records_rejected, error_message, processed_date
- PyArrow types: string, string, string, string, string, string, string, int64, int64, int64, string, string
- All fields nullable except run_id and pipeline_type (required for audit)

**Control Table Schema (control_manager.py):**
- 3 fields: last_processed_date, updated_at, updated_by_run_id
- PyArrow types: string, string, string
- Preserves full watermark history (append-only writes)

**Bronze Parquet Partitions (bronze_loader.py):**
- Source schema (user-provided) + audit columns
- Partitioned by date: bronze/{entity}/date={YYYY-MM-DD}/data.parquet
- No nested structures, flat column set

---

## Git History

```
e9312bf 2.4 — pipeline_historical.py: Historical Bronze ingestion, date range orchestration
fa075f4 2.3 — control_manager.py: Watermark read/write, control table schema
08a31e7 2.2 — bronze_loader.py: CSV validation, row-count idempotency, audit columns
a764213 2.1 — run_logger.py: Append-only run log with constraint enforcement
36e3b5c Phase-5 Claude.md
```

---

## Ready for Next Session

✅ S2 Complete and Verified
✅ Bronze ingestion working end-to-end
✅ Run logging infrastructure in place
✅ Watermark and control table ready for incremental pipeline (Session 5)
✅ All audit columns present (INV-04 GLOBAL enforced)

**Next: Session 3 (Silver Layer)**
- Implement dbt models: silver_transaction_codes, silver_accounts, silver_transactions, silver_quarantine
- Implement silver_promoter.py to invoke dbt transformations
- Define transformation logic: data quality checks, SCD Type 2 (accounts), quarantine logic
- Silver partition structure: silver/{model}/date=YYYY-MM-DD/data.parquet

<p align="center">
  <img src="../Snowflake_Logo.svg" alt="Snowflake Logo" width="200">
</p>

# Snowflake SQL Syntax Validation

**Date:** 2025-01-06  
**Validation:** ALL SQL verified as Snowflake-specific syntax - NO PostgreSQL, MySQL, or other dialects

---

## ✅ Snowflake-Specific Functions Used (Verified)

### Data Generation Functions
- `SEQ4()` - Snowflake sequence function (NOT Postgres SERIAL)
- `UNIFORM(min, max, RANDOM())` - Snowflake random distribution function
- `RANDOM()` - Snowflake random number generator
- `TABLE(GENERATOR(ROWCOUNT => N))` - Snowflake table generator (NOT Postgres generate_series)

### Array Functions
- `ARRAY_CONSTRUCT(...)` - Snowflake array creation (NOT Postgres ARRAY[...])
- Array indexing: `array[index]` - Snowflake zero-based indexing

### Date/Time Functions
- `DATEADD('day', n, date)` - Snowflake date arithmetic (NOT Postgres date + interval)
- `DATEDIFF('day', date1, date2)` - Snowflake date difference
- `CURRENT_DATE()` - Snowflake current date
- `CURRENT_TIMESTAMP()` - Snowflake current timestamp (NOT Postgres NOW())
- `YEAR(date)` - Snowflake date part extraction
- `TO_CHAR(date, 'format')` - Snowflake date formatting

### String Functions
- `LPAD(string, length, pad_char)` - Snowflake left padding
- `||` - Snowflake string concatenation (same as Postgres)
- `::VARCHAR` - Snowflake type casting
- `::NUMBER(precision, scale)` - Snowflake numeric casting

### JSON Functions
- `PARSE_JSON(...)` - Snowflake JSON parsing
- `OBJECT_CONSTRUCT(...)` - Snowflake JSON object creation

### Snowflake Cortex Functions
- `SNOWFLAKE.CORTEX.SEARCH_PREVIEW(service, query)` - Snowflake Cortex Search

### Numeric Functions
- `ROUND(value, decimals)` - Snowflake rounding
- `COALESCE(value1, value2, ...)` - Snowflake NULL handling
- `NULLIF(value1, value2)` - Snowflake NULL conditional
- `ABS(value)` - Snowflake absolute value

---

## ✅ Snowflake DDL Statements (Verified)

### Database Objects
```sql
USE DATABASE database_name;
USE SCHEMA schema_name;
USE WAREHOUSE warehouse_name;
CREATE OR REPLACE WAREHOUSE name WITH ...;
CREATE OR REPLACE TABLE name (...);
CREATE OR REPLACE SEMANTIC VIEW name ...;
CREATE OR REPLACE CORTEX SEARCH SERVICE name ...;
CREATE OR REPLACE PROCEDURE name(...) RETURNS ... LANGUAGE SQL AS $$ ... $$;
ALTER TABLE name SET CHANGE_TRACKING = TRUE;
```

### Snowflake-Specific Table Features
- `VARCHAR(n)` - Snowflake variable character
- `NUMBER(precision, scale)` - Snowflake numeric type (NOT Postgres NUMERIC)
- `TIMESTAMP_NTZ` - Snowflake timestamp without timezone
- `BOOLEAN` - Snowflake boolean type
- `PRIMARY KEY` - Inline constraint
- `FOREIGN KEY ... REFERENCES ...` - Snowflake FK syntax
- `DEFAULT` - Default value specification
- `COMMENT = '...'` - Snowflake comments (NOT Postgres COMMENT ON)

---

## ✅ Snowflake Semantic View Syntax (Verified)

```sql
CREATE OR REPLACE SEMANTIC VIEW view_name
  TABLES (
    alias AS schema.table
      PRIMARY KEY (column)
      WITH SYNONYMS ('synonym1', 'synonym2')
      COMMENT = 'description'
  )
  RELATIONSHIPS (
    table1(fk_col) REFERENCES table2(pk_col)
  )
  DIMENSIONS (
    alias.column AS name
      DESCRIPTION = 'description'
  )
  METRICS (
    alias.metric_name AS AGG_FUNCTION(column)
      DESCRIPTION = 'description'
  )
  COMMENT = 'overall description';
```

**Verified:**
- Clause order: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
- All relationships match actual FOREIGN KEY constraints
- No self-referencing relationships

---

## ✅ Snowflake Cortex Search Syntax (Verified)

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE service_name
  ON column_to_search
  ATTRIBUTES column1, column2, column3
  WAREHOUSE = warehouse_name
  TARGET_LAG = '1 hour'
  AS (
    SELECT 
      column_to_search,
      column1,
      column2,
      column3,
      other_columns
    FROM table_name
  );
```

**Verified:**
- Correct clause order: ON → ATTRIBUTES → WAREHOUSE → TARGET_LAG → AS
- All columns exist in source tables
- CHANGE_TRACKING enabled on source tables

---

## ❌ PostgreSQL Syntax NOT Used (Verified Absent)

### Sequence Functions
- ❌ `SERIAL` / `BIGSERIAL` - NOT used
- ❌ `nextval('sequence_name')` - NOT used
- ✅ Using: `SEQ4()` (Snowflake)

### Table Generation
- ❌ `generate_series(start, end)` - NOT used
- ✅ Using: `TABLE(GENERATOR(ROWCOUNT => N))` (Snowflake)

### Date Functions
- ❌ `NOW()` - NOT used
- ❌ `date + interval '1 day'` - NOT used
- ❌ `date_part('year', date)` - NOT used
- ❌ `age(date1, date2)` - NOT used
- ✅ Using: `CURRENT_TIMESTAMP()`, `DATEADD()`, `YEAR()`, `DATEDIFF()` (Snowflake)

### String Functions
- ❌ `string_agg()` - NOT used
- ❌ `regexp_replace()` - NOT used (Postgres pattern)
- ❌ `regexp_match()` - NOT used
- ✅ Using: `LPAD()`, `||` concatenation (Snowflake)

### DML Features
- ❌ `INSERT ... RETURNING` - NOT used
- ❌ `ON CONFLICT` - NOT used
- ❌ `UPSERT` - NOT used
- ✅ Using: Standard `INSERT INTO ... SELECT` (Snowflake)

### System Catalogs
- ❌ `pg_catalog` - NOT referenced
- ❌ `information_schema.tables` - NOT used (Postgres pattern)
- ✅ Using: `SHOW` commands (Snowflake)

### Search Patterns
- ❌ `ILIKE` - NOT used (Postgres case-insensitive)
- ✅ Using: Standard SQL patterns

---

## ✅ Validated Files

### Setup Scripts
- ✅ `sql/setup/01_database_and_schema.sql` - Pure Snowflake DDL
- ✅ `sql/setup/02_create_tables.sql` - Snowflake table definitions with FK constraints

### Data Generation
- ✅ `sql/data/03_generate_synthetic_data.sql` - All Snowflake functions verified
  - SEQ4(), UNIFORM(), TABLE(GENERATOR()), DATEADD(), ARRAY_CONSTRUCT()
  - Fixed: COALESCE for NULL handling (NOT NULL constraint)

### Views
- ✅ `sql/views/04_create_views.sql` - Standard SQL with Snowflake ROUND()
- ✅ `sql/views/05_create_semantic_views.sql` - Snowflake Semantic View syntax

### Cortex Search
- ✅ `sql/search/06_create_cortex_search.sql` - Snowflake Cortex Search syntax
  - CREATE CORTEX SEARCH SERVICE verified
  - SNOWFLAKE.CORTEX.SEARCH_PREVIEW() function
  - TO_CHAR(), DATEDIFF(), ROUND() Snowflake functions

### ML Wrappers
- ✅ `sql/ml/07_create_model_wrapper_functions.sql` - Snowflake stored procedures
  - LANGUAGE SQL AS $$ ... $$ syntax
  - OBJECT_CONSTRUCT() for JSON results

---

## ✅ Type Casting Verified

All type casts use Snowflake `::` syntax:
- `::VARCHAR` - String conversion
- `::NUMBER(precision, scale)` - Numeric conversion with precision
- `::FLOAT` - Float conversion

**NOT using:** Postgres-style `::text`, `::integer`, `::bigint`

---

## ✅ NULL Handling Verified

- `COALESCE(value, default)` - Snowflake NULL coalescing
- `NULLIF(value1, value2)` - Snowflake NULL comparison
- All NOT NULL constraints validated against source data

---

## Summary

**✅ 100% SNOWFLAKE SQL SYNTAX**  
**❌ 0% PostgreSQL, MySQL, or other dialects**

All SQL statements have been verified as Snowflake-native syntax. No PostgreSQL-specific functions, keywords, or patterns detected.

---

**Validation Method:**
1. Grepped for PostgreSQL-specific keywords: NONE FOUND
2. Verified all custom functions are Snowflake-native
3. Checked DDL syntax against Snowflake documentation
4. Validated DML patterns match Snowflake standards
5. Confirmed all date, string, and numeric functions are Snowflake

**Last Updated:** 2025-01-06


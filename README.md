# Azure_Dbt_Snowflake
An end-to-end data engineering project that ingests data from **Azure Storage** into **Snowflake** and transforms it using **dbt**, following the **Medallion Architecture** (Bronze → Silver → Gold) with dimensional modelling (Fact + Dims + OBT) and SCD Type 2 history tracking via dbt Snapshots.

---

# Architecture

## Data Flow

```

Azure Storage ──► Snowflake  ──► Bronze Layer ──►  Silver Layer   ──► Gold Layer

```
## Technology

| Tool | Purpose |
|---|---|
| **Snowflake** | Cloud data warehouse |
| **Azure Blob Storage** | Raw CSV file storage |
| **dbt Core** | Data transformation and orchestration |
| **dbt Snapshots** | SCD Type 2 history tracking |
| **Jinja2** | Templating for dynamic SQL (loops, macros, conditionals) |

---

## Prerequisites
1. Azure Account
2. Snowflake Account
3. Python Environment (3.12)
4. Git

---
## Project Structure
```
│
├── models/
│   ├── bronze/
│   │   ├── bronze_customers.sql
│   │   ├── bronze_drivers.sql
│   │   ├── bronze_locations.sql
│   │   └── bronze_trips.sql
│   │
│   ├── silver/
│   │   ├── silver_customers.sql
│   │   ├── silver_drivers.sql
│   │   ├── silver_locations.sql
│   │   └── silver_trips.sql
│   │
│   └── gold/
│       ├── dims/
│       │   ├── customers.sql       ← ephemeral (feeds snapshot)
│       │   ├── drivers.sql         ← ephemeral (feeds snapshot)
│       │   └── locations.sql       ← ephemeral (feeds snapshot)
│       ├── obt.sql
│       └── fact.sql
│
├── snapshots/
│   ├── dim_customers.yml
│   ├── dim_drivers.yml
│   └── dim_locations.yml
│
├── macros/
│   ├── clean_string.sql
│   └── clean_phone_numbers.sql
│
└── sources.yml

```
---

# Architecture — Medallion Layers

```
Source (Snowflake: PUBLIC schema)
        ↓
    BRONZE  — Raw incremental load, SELECT * only
        ↓
    SILVER  — Cleansed, typed, enriched, deduplicated
        ↓               ↓
       OBT          Ephemeral Dims
        ↓           drivers.sql
       Fact         locations.sql
                    locations.sql                      
                       ↓
                   Snapshots (SCD2)
                   dim_customers
                   dim_drivers
                   dim_locations
```
--- 
## Bronze Layer
**Purpose:** Raw ingestion only. `SELECT *` from source tables with incremental watermark on `LAST_UPDATED_TIMESTAMP`.

**Materialisation:** `incremental`

**Models:**

| Model | Source Table | Watermark Column |
|---|---|---|
| `bronze_customers` | `PUBLIC.Customers` | `LAST_UPDATED_TIMESTAMP` |
| `bronze_drivers` | `PUBLIC.Drivers` | `LAST_UPDATED_TIMESTAMP` |
| `bronze_locations` | `PUBLIC.Location` | `LAST_UPDATED_TIMESTAMP` |
| `bronze_trips` | `PUBLIC.Trips` | `LAST_UPDATED_TIMESTAMP` |

> **Note:** Bronze uses `LAST_UPDATED_TIMESTAMP` so it captures both new inserts and updates from the source. First run always does a full load.

---

## Silver Layer

**Purpose:** Cleansed, typed, deduplicated, and enriched records. One row per entity. Business logic and derived columns applied here.

**Materialisation:** `incremental` with `unique_key` (merge/upsert)

**Models and Key Transformations:**

| Model | unique_key | Key Transformations |
|---|---|---|
| `silver_customers` | `CUSTOMER_ID` | `CONCAT` full name, clean email/phone, extract signup year/month, email validation |
| `silver_drivers` | `DRIVER_ID` | `CONCAT` full name, cast rating, derive `RATING_TIER` band |
| `silver_locations` | `LOCATION_ID` | Clean city/state/country, derive `HEMISPHERE` from latitude |
| `silver_trips` | `TRIP_ID` | Cast types, derive `DISTANCE_CATEGORY`, `DURATION_MINUTES`, `FARE_TIER` |

---

## Gold Layer

### OBT — One Big Table
**Purpose:** Fully denormalised wide table joining all four silver tables into a single model. One row per trip. Used for analytics and as the source for the fact table.

**Joins:**
```
silver_trips
    LEFT JOIN silver_customers  ON trips.CUSTOMER_ID = customers.CUSTOMER_ID
    LEFT JOIN silver_drivers    ON trips.DRIVER_ID   = drivers.DRIVER_ID
    LEFT JOIN silver_locations  ON trips.LOCATION_ID = locations.LOCATION_ID
```
### Fact Table

**Purpose:** Transaction-level fact table for analytical queries. Reads from OBT.

> ⚠️ **Note on contextual columns in fact tables:**
> 1. **Foreign Keys** (`CUSTOMER_ID`, `DRIVER_ID`, `LOCATION_ID`, `VEHICLE_ID`) — integers that join to dimension tables
> 2. **Timestamps** (`TRIP_START_TIME`, `TRIP_END_TIME`) — record *when* the transaction happened, essential for date filtering in visualizations
> 3. **Degenerate Dimensions** (`TRIP_STATUS`, `TRIP_PAYMENT_METHOD`, `TRIP_FARE_TIER`, `TRIP_DISTANCE_CATEGORY`) — short string codes with no separate dimension table, used for `GROUP BY` in visualizations queries

---

### Dimension Tables — SCD Type 2 Snapshots

**Purpose:** Track historical changes to entity attributes over time using dbt Snapshots (Slowly Changing Dimension Type 2).

**Strategy:** `timestamp` on `LAST_UPDATED` column

**dbt_valid_to_current:** `to_date('9999-12-31')` — open-ended current records use this sentinel value instead of NULL

**Flow:**
```
silver_customers → customers.sql (ephemeral) → dim_customers (snapshot SCD2)
silver_drivers   → drivers.sql   (ephemeral) → dim_drivers   (snapshot SCD2)
silver_locations → locations.sql (ephemeral) → dim_locations (snapshot SCD2)
```

**SCD2 columns added by dbt:**

| Column | Description |
|---|---|
| `DBT_SCD_ID` | Unique ID for each version |
| `DBT_VALID_FROM` | When this version became active |
| `DBT_VALID_TO` | When this version expired (`9999-12-31` = current) |
| `DBT_UPDATED_AT` | When dbt last updated this row |
---

**Macros:**

| Macro | Purpose |
|---|---|
| `clean_string()` | `lower(trim(column))` — normalises strings |
| `clean_phone_numbers()` | Standardises phone number format |

---
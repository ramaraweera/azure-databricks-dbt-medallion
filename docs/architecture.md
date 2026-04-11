# Architecture — Gaming Product Marketing Analytics

## Medallion Layers

| Layer | Table | Tool | Purpose |
|---|---|---|---|
| Bronze | `gaming_bronze.vg_sales_raw` | Databricks PySpark | Raw CSV as Delta, plus ingestion metadata |
| Silver | `gaming_silver.vg_sales_clean` | Databricks PySpark | Typed, cleaned, enriched, partitioned by Genre |
| Gold | `gaming_gold.fct_game_sales` + dims | dbt Cloud | Star schema for marketing analytics |

## Star Schema (Gold)

```
                    ┌─────────────┐
                    │  dim_game   │
                    │  game_id PK │
                    └──────┬──────┘
                           │
┌──────────────┐    ┌──────┴──────────────┐    ┌───────────────┐
│  dim_genre   │    │  fct_game_sales     │    │ dim_publisher │
│  genre_id PK ├────┤  sales_id PK        ├────┤ publisher_id  │
│  genre_cat   │    │  genre_id FK        │    └───────────────┘
└──────────────┘    │  publisher_id FK    │
                    │  platform_id FK     │    ┌───────────────┐
                    │  game_id FK         ├────┤ dim_platform  │
                    │  global_sales_M     │    │ platform_id PK│
                    │  na/eu/jp_sales_M   │    └───────────────┘
                    │  sales_tier         │
                    │  is_global_hit      │
                    └─────────────────────┘
```

## Data Flow

```
Kaggle vgsales.csv
    ↓ (manual upload)
ADLS Gen2: gaming-data/raw/vgsales.csv
    ↓ Notebook 00 (mounts ADLS, creates DBs)
    ↓ Notebook 01 (reads CSV → Bronze Delta)
gaming_bronze.vg_sales_raw
    ↓ Notebook 02 (cleans, types, enriches)
gaming_silver.vg_sales_clean   ← partitioned by Genre
    ↓ dbt Cloud (staging view)
dbt: stg_vg_sales (VIEW on Silver)
    ↓ dbt Cloud (mart models)
gaming_gold.fct_game_sales
gaming_gold.dim_game
gaming_gold.dim_genre           ← enriched from genre_categories seed
gaming_gold.dim_publisher
gaming_gold.dim_platform
    ↓ Notebook 03 (SQL validation)
Marketing Analytics Queries
```

## Key Design Decisions

- **Partitioned by Genre (Silver)** — genre is the most common filter in marketing queries, so partitioning reduces scan cost significantly
- **Delta Lake throughout** — ACID transactions, time travel, and OPTIMIZE/VACUUM support
- **dbt surrogate keys via dbt_utils** — deterministic MD5 keys enable idempotent incremental loads in future
- **genre_categories seed** — separates marketing taxonomy from raw data, making it easy to update labels without reprocessing Bronze/Silver
- **generate_schema_name macro** — ensures dbt models land in `gaming_silver` and `gaming_gold` instead of `<target>_gaming_silver`

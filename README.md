# 🎮 Gaming Product Marketing Analytics
## Azure Databricks + dbt Cloud | Medallion Architecture Portfolio Project

![Azure Databricks](https://img.shields.io/badge/Azure%20Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Delta Lake](https://img.shields.io/badge/Delta%20Lake-003366?style=for-the-badge)

## Architecture

```
Kaggle vgsales.csv → ADLS Gen2 raw/
  → BRONZE: gaming_bronze.vg_sales_raw     (Delta, raw + metadata)
  → SILVER: gaming_silver.vg_sales_clean   (Delta, typed + enriched, partitioned by Genre)
  → GOLD:   fct_game_sales + dim_* tables  (Delta star schema via dbt Cloud)
```

## Run Order

1. Azure Portal — Databricks workspace + ADLS Gen2 + Service Principal
2. Upload vgsales.csv to gaming-data/raw/
3. Databricks — run 00_setup_and_config.ipynb
4. Databricks — run 01_bronze_ingestion.ipynb
5. Databricks — run 02_silver_transform.ipynb
6. dbt Cloud — dbt deps → dbt seed → dbt run → dbt test
7. Databricks — run 03_gold_exploration.ipynb

## Dataset
Kaggle Video Game Sales: https://www.kaggle.com/datasets/gregorut/videogamesales
16,500+ games, platforms, genres, publishers, regional sales 1980–2016.

## Stack
Azure Databricks | ADLS Gen2 | Delta Lake | dbt Cloud | GitHub | Medallion Architecture

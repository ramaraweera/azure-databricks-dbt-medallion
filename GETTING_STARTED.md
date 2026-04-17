# 🎮 Gaming Product Marketing Analytics

Azure Databricks + dbt Cloud | Medallion Architecture Portfolio Project  

This repo is a **beginner‑friendly, end‑to‑end project** that walks you through building a **Medallion lakehouse** on **Azure Databricks** using **ADLS Gen2**, **Delta Lake**, and **dbt**.[file:1] It takes you from an empty workspace to **BI‑ready Gold tables** with clear, reproducible steps.[file:1]

---

## 🚀 What You’ll Build

You will:

- Land raw **Kaggle video game sales data** in ADLS Gen2.  
- Build **Bronze → Silver → Gold** Delta tables following the Medallion pattern.[file:1]  
- Orchestrate transformation logic with **Databricks notebooks** and **dbt models**.[file:1]  
- Connect a **Databricks SQL Warehouse** and run analytics/BI queries on the Gold layer.[file:1]

---

## 🧱 Architecture

**Data flow**

`Kaggle vgsales.csv` → `ADLS Gen2` raw → Delta **Bronze** → **Silver** → **Gold** → Databricks SQL Warehouse → BI tool

- **Bronze** – Raw ingested data (schema aligned, minimal transformation).[file:1]  
- **Silver** – Cleaned and standardized tables (types fixed, nulls handled, columns renamed).[file:1]  
- **Gold** – Business‑ready fact and dimension tables for reporting and dashboards.[file:1]  

Typical layout:

- **Catalog**: `ws_taxi_pipeline` (or similar)[file:1]  
- **Schemas**:  
  - `gaming_bronze` – raw Delta tables from `01_bronze_ingestion.ipynb`  
  - `gaming_silver` – cleaned, analytics‑ready tables used by dbt  
  - `gaming_gold` – final BI tables (dbt + notebooks)  

Example Gold tables:

- `gaming_gold.fact_sales`  
- `gaming_gold.dim_game`  
- `gaming_gold.dim_genre`[file:1]  

---

## 📂 Repo Structure

```text
.
├── notebooks/
│   ├── 00_setup_and_config.ipynb
│   ├── 01_bronze_ingestion.ipynb
│   ├── 02_silver_transform.ipynb
│   └── 03_gold_exploration.ipynb
└── dbt/
    ├── models/
    │   ├── bronze/
    │   ├── silver/
    │   └── gold/
    ├── seeds/
    ├── tests/
    └── dbt_project.yml
```

### 🔍 Notebooks (`notebooks/`)

1. `00_setup_and_config.ipynb`  
   - Mounts **ADLS Gen2**.  
   - Creates **Bronze, Silver, Gold** databases or Unity Catalog schemas.  
   - Sets shared config used by the other notebooks.[file:1]

2. `01_bronze_ingestion.ipynb`  
   - Reads raw source files from ADLS Gen2.  
   - Writes **Bronze Delta tables** (raw but structured).[file:1]

3. `02_silver_transform.ipynb`  
   - Cleans and transforms Bronze data (types, nulls, standard columns).  
   - Writes **Silver Delta tables** ready for analytics and dbt models.[file:1]

4. `03_gold_exploration.ipynb`  
   - Explores Silver data.  
   - Builds **Gold tables** and demonstrates example queries/visualizations.[file:1]

Each notebook is heavily commented with **beginner‑level explanations** so you can follow the logic step by step.[file:1]

### 🧱 dbt project (`dbt/`)

The dbt project contains:

- `models/bronze/` – models exposing or lightly organizing Bronze tables.  
- `models/silver/` – models that clean, standardize, and join Bronze data.  
- `models/gold/` – models that build final fact/dimension tables for BI.  
- `seeds/` – small CSV lookup tables (for example `genre_categories.csv`) loaded with `dbt seed`.  
- `tests/` – data quality tests (uniqueness, not null, accepted values, etc.).  
- `dbt_project.yml` – project configuration and model materializations.[file:1]  

---

## 📊 Dataset

**Kaggle Video Game Sales**  
https://www.kaggle.com/datasets/gregorut/videogamesales

- 16,500+ games across platforms, genres, and publishers  
- Regional sales: NA, EU, JP, Other, Global  
- Years covered: 1980–2016  
- Key columns: `Name`, `Platform`, `Year`, `Genre`, `Publisher`, `NA_Sales`, `EU_Sales`, `JP_Sales`, `Global_Sales`  

The notebooks handle ingesting this file into Bronze and transforming it through to Gold.

---

## ✅ Prerequisites

You’ll need:

- An **Azure subscription**  
- An **Azure Databricks workspace**  
- An **ADLS Gen2 storage account** (containers for Bronze/Silver/Gold)  
- A **Databricks SQL Warehouse** (for dbt + BI tools)[file:1]  
- A **GitHub account** (this repo is cloned into Databricks Repos)[file:1]  
- **dbt Core** (with `dbt-databricks` adapter) or **dbt Cloud**[file:1]  

---

## ⚡ Quick Start (End‑to‑End)

### 1. Clone into Databricks Repos

1. In Databricks, open **Repos**.  
2. Click **Add Repo** or **Git folder**.  
3. Use this Git URL:

   ```text
   https://github.com/ramaraweera/azure-databricks-dbt-medallion.git
   ```

4. Select the `main` branch.[file:1]

### 2. Configure Secrets (never hard‑code)

1. In Azure Databricks, create a **secret scope** (for example `gaming-scope`).  
2. Add secrets like:  

   - `storage-account-name`  
   - `service-principal-client-id`  
   - `service-principal-client-secret`  
   - `tenant-id`  

3. Use them in `00_setup_and_config.ipynb` via `dbutils.secrets.get(...)`.[file:1]

### 3. Run the notebooks in order

1. `00_setup_and_config.ipynb` – fill in config values and run all cells.  
2. `01_bronze_ingestion.ipynb` – load raw data into **Bronze** Delta tables.  
3. `02_silver_transform.ipynb` – build **Silver** Delta tables.  
4. `03_gold_exploration.ipynb` – create **Gold** tables and explore results.[file:1]  

At this point your **Bronze/Silver/Gold Delta tables** exist in your Databricks workspace.[file:1]

---

## 🔐 Security — Keep Secrets Out of Code

GitHub will **block your push** if it finds a real secret (client secret, passwords) in a notebook. Use Databricks secret scopes instead.

```python
# In any notebook — use this pattern, never paste real values
STORAGE_ACCOUNT = dbutils.secrets.get("gaming-scope", "storage-account-name")
CLIENT_ID       = dbutils.secrets.get("gaming-scope", "service-principal-client-id")
CLIENT_SECRET   = dbutils.secrets.get("gaming-scope", "service-principal-client-secret")
TENANT_ID       = dbutils.secrets.get("gaming-scope", "tenant-id")
```

To create the secret scope: Databricks → **Settings → Secrets → Create Scope**.

---

## ⚙️ dbt profiles.yml (dbt Core)

Add this to `~/.dbt/profiles.yml` on your local machine (or configure equivalent settings in dbt Cloud):

```yaml
azure_databricks_dbt_medallion:
  target: dev
  outputs:
    dev:
      type: databricks
      method: token
      host: <your-workspace>.azuredatabricks.net
      http_path: /sql/1.0/warehouses/<warehouse-id>
      token: <your-personal-access-token>
      catalog: ws_taxi_pipeline
      schema: gaming_silver
```

The `catalog` / `schema` should match the Silver/Gold layout created by `00_setup_and_config.ipynb`. Never commit real tokens; prefer environment variables or dbt Cloud secrets.[file:1]

---

## 🛠️ Stack

| Tool               | Purpose                                                           |
|--------------------|-------------------------------------------------------------------|
| **Azure Databricks** | Unified analytics workspace, notebook execution, Spark          |
| **ADLS Gen2**        | Cloud storage for raw and Delta files                           |
| **Delta Lake**       | Open table format with ACID transactions on Parquet             |
| **dbt Core/Cloud**   | SQL‑based data modeling, testing, and documentation             |
| **GitHub**           | Version control, connected to Databricks via Repos              |
| **Medallion Architecture** | Bronze → Silver → Gold data‑quality pattern              |

---

## 🐛 Common Errors & Quick Fixes

| Error                                  | Likely cause                            | Fix                                                     |
|----------------------------------------|-----------------------------------------|---------------------------------------------------------|
| `UC_HIVE_METASTORE_DISABLED_EXCEPTION` | Workspace uses Unity Catalog, not Hive  | Use `catalog.schema.table` format in SQL               |
| `TABLE_OR_VIEW_NOT_FOUND`             | Notebook ran out of order               | Run notebooks `00` → `01` → `02` first                 |
| `GH013: Push protection — secret found` | Real secret committed in a notebook     | Replace with `dbutils.secrets.get(...)` and re‑push    |
| `GIT_REMOTE_REF_UPDATE_REJECTED`      | Local branch behind GitHub              | Pull latest changes, then Commit & Push                |
| `dbt: could not find relation`        | Silver table not built yet              | Run Databricks notebooks before `dbt run`              |

---

## 📚 Learning Resources

- [dbt + Databricks quickstart](https://docs.getdbt.com/guides/databricks)  
- [Azure Databricks Medallion Architecture](https://learn.microsoft.com/en-us/azure/databricks/lakehouse/medallion)  
- [Connect dbt Core to Azure Databricks](https://learn.microsoft.com/en-us/azure/databricks/partners/prep/dbt)  
- [Databricks Secret Scopes](https://docs.databricks.com/en/security/secrets/secret-scopes.html)  

---

## 🙋‍♀️ How to Use This as a Portfolio Project

- Fork the repo into your own GitHub account.  
- Customize names (catalog/schema), comments, and dbt models to reflect your own story.  
- Add a short section describing how you would extend this (e.g., incremental loads, orchestration, monitoring).  

*Built as a beginner‑to‑intermediate portfolio project. Open an Issue or PR if anything is unclear or you’d like to improve it further.*

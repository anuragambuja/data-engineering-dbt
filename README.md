## DBT (data built tool) Overview 

dbt stands for data build tool. It's a transformation tool: it allows us to transform process raw data in our Data Warehouse to transformed data which can be later used by Business Intelligence tools and any other data consumers.

![image](https://user-images.githubusercontent.com/19702456/216638815-6eefbc27-9312-42c8-9821-806bd91df725.png)

dbt works by defining a modeling layer that sits on top of our Data Warehouse. The modeling layer will turn tables into models which we will then transform into derived models, which can be then stored into the Data Warehouse for persistence.

![image](https://user-images.githubusercontent.com/19702456/219943607-e8392151-b25b-4966-9cb4-596775e578fc.png)

dbt has 2 main components: _dbt Core_ and _dbt Cloud_:
* ***dbt Core***: open-source project that allows the data transformation.
    * Builds and runs a dbt project (.sql and .yaml files).
    * Includes SQL compilation logic, macros and database adapters.
    * Includes a CLI interface to run dbt commands locally.
    * Open-source and free to use.
* ***dbt Cloud***: SaaS application to develop and manage dbt projects. In order to use dbt Cloud you will need to create a user account. Got to the [dbt homepage](https://www.getdbt.com/) and sign up.
    * Web-based IDE to develop, run and test a dbt project.
    * Jobs orchestration.
    * Logging and alerting.
    * Intregrated documentation.
    * Free for individuals (one developer seat).

>  Models Overview

:point_right: Models Overview

- Models are the basic building block of your business logic
- Materialized as tables, views, etc…
- They live in SQL files in the `models` folder
- Models can reference each other and use templates and macros

Here's an example dbt model:
```sql
{{
    config(materialized='table')
}}

SELECT *
FROM staging.source_table
WHERE record_state = 'ACTIVE'
```

:point_right: Materializations Overview
 * The `table` strategy means that the model will be rebuilt as a table on each run.
 * We could use a `view` strategy instead, which would rebuild the model on each run as a SQL view.
 * The `incremental` strategy is essentially a `table` strategy but it allows us to add or update records incrementally rather than rebuilding the complete table on each run.
 * The `ephemeral` strategy creates a _[Common Table Expression](https://www.essentialsql.com/introduction-common-table-expressions-ctes/)_ (CTE).
 * You can learn more about materialization strategies with dbt [in this link](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/materializations). Besides the 4 common `table`, `view`, `incremental` and `ephemeral` strategies, custom strategies can be defined for advanced cases.

![image](https://user-images.githubusercontent.com/19702456/219865450-6061d1c7-cff2-4075-b201-dc411f5bee03.png)

:point_right: Sources and Seeds Overview
- Seeds are local files that you upload to the data warehouse from dbt
- Sources is an abstraction layer on the top of your input tables
- Source freshness can be checked automatically

* ***Sources***: The data loaded within our Data Warehouse.
    * We can access this data with the `source()` function.
    * The `sources` key in our YAML file contains the details of the databases that the `source()` function can access and translate into proper SQL-valid names.
        * Additionally, we can define "source freshness" to each source so that we can check whether a source is "fresh" or "stale", which can be useful to check whether our data pipelines are working properly.
    * More info about sources [in this link](https://docs.getdbt.com/docs/building-a-dbt-project/using-sources).
* ***Seeds***: CSV files which can be stored in our repo under the `seeds` folder.
    * The repo gives us version controlling along with all of its benefits.
    * Seeds are best suited to static data which changes infrequently.
    * Seed usage:
        1. Add a CSV file to your `seeds` folder.
        1. Run the [`dbt seed` command](https://docs.getdbt.com/reference/commands/seed) to create a table in our Data Warehouse.
            * If you update the content of a seed, running `dbt seed` will append the updated values to the table rather than substituing them. Running `dbt seed --full-refresh` instead will drop the old table and create a new one.
        1. Refer to the seed in your model with the `ref()` function.
    * More info about seeds [in this link](https://docs.getdbt.com/docs/building-a-dbt-project/seeds).

Here's an example of how you would declare a source in a `.yml` file:

```yaml
sources:
    - name: staging
      database: production
      schema: trips_data_all

      loaded_at_field: record_loaded_at
      tables:
        - name: green_tripdata
        - name: yellow_tripdata
          freshness:
            error_after: {count: 6, period: hour}
```

And here's how you would reference a source in a `FROM` clause:

```sql
FROM {{ source('staging','yellow_tripdata') }}
```
* The first argument of the `source()` function is the source name, and the second is the table name.

In the case of seeds, assuming you've got a `taxi_zone_lookup.csv` file in your `seeds` folder which contains `locationid`, `borough`, `zone` and `service_zone`:

```sql
SELECT
    locationid,
    borough,
    zone,
    replace(service_zone, 'Boro', 'Green') as service_zone
FROM {{ ref('taxi_zone_lookup) }}
```

The `ref()` function references underlying tables and views in the Data Warehouse. When compiled, it will automatically build the dependencies and resolve the correct schema fo us. So, if BigQuery contains a schema/dataset called `dbt_dev` inside the `my_project` database which we're using for development and it contains a table called `stg_green_tripdata`, then the following code...

```sql
WITH green_data AS (
    SELECT *,
        'Green' AS service_type
    FROM {{ ref('stg_green_tripdata') }}
),
```

...will compile to this:

```sql
WITH green_data AS (
    SELECT *,
        'Green' AS service_type
    FROM "my_project"."dbt_dev"."stg_green_tripdata"
),
```
* The `ref()` function translates our references table into the full reference, using the `database.schema.table` structure.

The advantage of having the properties in a separate file is that we can easily modify the schema.yml file to change the database details and write to different databases without having to modify our sgt_green_tripdata.sql file.

:point_right: Snapshots
- Timestamp: A unique key and an updated_at field is defined on the source model. These columns are used for determining changes.
- Check: Any change in a set of columns (or all columns) will be picked up as an update.

:point_right: Tests Overview
There are two types of tests: singular and generic
- Singular tests are SQL queries stored in tests which are expected to return an empty resultset
- Generic Tests are pre defined tests which can be added to a yml file. There are four built-in generic tests:
    - unique
    - not_null
    - accepted_values
    - Relationships
- You can define your own custom generic tests or import tests from dbt packages

:point_right: Macros
- Macros are jinja templates created in the macros folder
- There are many built-in macros in DBT
- You can use macros in model definitions and tests
- A special macro, called test, can be used for implementing your own generic tests
- dbt packages can be installed easily to get access to a plethora of macros and tests

***Macros*** are pieces of code in Jinja that can be reused, similar to functions in other languages.

dbt already includes a series of macros like `config()`, `source()` and `ref()`, but custom macros can also be defined.

Macros allow us to add features to SQL that aren't otherwise available, such as:
* Use control structures such as `if` statements or `for` loops.
* Use environment variables in our dbt project for production.
* Operate on the results of one query to generate another query.
* Abstract snippets of SQL into reusable macros.

Macros are defined in separate `.sql` files which are typically stored in a `macros` directory.

There are 3 kinds of Jinja _delimiters_:
* `{% ... %}` for ***statements*** (control blocks, macro definitions)
* `{{ ... }}` for ***expressions*** (literals, math, comparisons, logic, macro calls...)
* `{# ... #}` for comments.

Here's a macro definition example:

```sql
{# This macro returns the description of the payment_type #}

{% macro get_payment_type_description(payment_type) %}

    case {{ payment_type }}
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
    end

{% endmacro %}
```
* The `macro` keyword states that the line is a macro definition. It includes the name of the macro as well as the parameters.
* The code of the macro itself goes between 2 statement delimiters. The second statement delimiter contains an `endmacro` keyword.
* In the code, we can access the macro parameters using expression delimiters.
* The macro returns the ***code*** we've defined rather than a specific value.

Here's how we use the macro:
```sql
select
    {{ get_payment_type_description('payment-type') }} as payment_type_description,
    congestion_surcharge::double precision
from {{ source('staging','green_tripdata') }}
where vendorid is not null
```
* We pass a `payment-type` variable which may be an integer from 1 to 6.

And this is what it would compile to:
```sql
select
    case payment_type
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        when 5 then 'Unknown'
        when 6 then 'Voided trip'
    end as payment_type_description,
    congestion_surcharge::double precision
from {{ source('staging','green_tripdata') }}
where vendorid is not null
```
* The macro is replaced by the code contained within the macro definition as well as any variables that we may have passed to the macro parameters.

:point_right: Documentation Overview
- Documentations can be defined two ways:
    - In yaml files (like schema.yml)
    - In standalone markdown files
- Dbt ships with a lightweight documentation web server
- For customizing the landing page, a special file, overview.md is used
- You can add your own assets (like images) to a special project folder 

The dbt generated docs will include the following:
* Information about the project:
    * Model code (both from the .sql files and compiled code)
    * Model dependencies
    * Sources
    * Auto generated DAGs from the `ref()` and `source()` macros
    * Descriptions from the .yml files and tests
* Information about the Data Warehouse (`information_schema`):
    * Column names and data types
    * Table stats like size and rows

dbt docs can be generated on the cloud or locally with `dbt docs generate`, and can be hosted in dbt Cloud as well or on any other webserver with `dbt docs serve`.

:point_right: Hooks Overview
- Hooks are SQLs that are executed at predefined times
- Hooks can be configured on the project, subfolder, or model level
- Hook types:
    - on_run_start: executed at the start of dbt {run, seed, snapshot}
    - on_run_end: executed at the end of dbt {run, seed, snapshot}
    - pre-hook: executed before a model/seed/snapshot is built
    - post-hook: executed after a model/seed/snapshot is built

:point_right: Packages

Macros can be exported to ***packages***, similarly to how classes and functions can be exported to libraries in other languages. Packages contain standalone dbt projects with models and macros that tackle a specific problem area.

When you add a package to your project, the package's models and macros become part of your own project. A list of useful packages can be found in the [dbt package hub](https://hub.getdbt.com/).

To use a package, you must first create a `packages.yml` file in the root of your work directory. Here's an example:
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 0.8.0
```

After declaring your packages, you need to install them by running the `dbt deps` command either locally or on dbt Cloud.

You may access macros inside a package in a similar way to how Python access class methods:
```sql
select
    {{ dbt_utils.surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    cast(vendorid as integer) as vendorid,
    -- ...
```

:point_right: Variables

Like most other programming languages, ***variables*** can be defined and used across our project.

Variables can be defined in 2 different ways:
* Under the `vars` keyword inside `dbt_project.yml`.
    ```yaml
    vars:
        payment_type_values: [1, 2, 3, 4, 5, 6]
    ```
* As arguments when building or running your project.
    ```sh
    dbt build --m <your-model.sql> --var 'is_test_run: false'
    ```

Variables can be used with the `var()` macro. For example:
```sql
{% if var('is_test_run', default=true) %}

    limit 100

{% endif %}
```
* In this example, the default value for `is_test_run` is `true`; in the absence of a variable definition either on the `dbt_project.yml` file or when running the project, then `is_test_run` would be `true`.
* Since we passed the value `false` when runnning `dbt build`, then the `if` statement would evaluate to `false` and the code within would not run.


> ### dbt installation

```
pip install dbt-snowflake==1.2.0
dbt
```

> ### dbt commands
```bash
  dbt init <project name>
  dbt debug # run from the project directory 
  dbt run --full-refresh
  dbt seed [-s filename] # upload seed
  dbt compile 
  dbt source freshness
  dbt snapshot # implements SCD type 2
  dbt test [--select <test_name>] #  verify if tests are passing
  dbt deps  # install dependencies from packages.yml
  
  dbt docs generate # generate docs files 
  dbt docs serve # light weight server 
 
Project configurations: dbt_project.yml
Profile configurations: ~/.dbt/profiles.yml
```

> ### VS Code Extension: 
- [dbt Power User](https://marketplace.visualstudio.com/items?itemName=innoverio.vscode-dbt-power-user)

> ### References

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction).
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers.
- Join the [community](https://community.getdbt.com/) on Slack for live discussions and support.
- Find [dbt events](https://events.getdbt.com) near you.
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices.

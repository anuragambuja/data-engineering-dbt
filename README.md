# What is dbt (Data Built Tool) ?

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

> ## dbt installation

```
pip install dbt-snowflake==1.2.0
dbt
```

> ##  Models

- Models are .sql files that live in the `models` folder and are simply written as select statements - there is no DDL/DML that needs to be written around this. 
- Models can reference each other and use templates and macros
- After constructing a model, `dbt run` in the command line will actually materialize the models into the data warehouse. The default materialization is a view.
- The materialization can be configured as a table with the following configuration block at the top of the model file:
- When dbt run is executing, dbt is wrapping the select statement in the correct DDL/DML to build that model as a table/view. If that model already exists in the data warehouse, dbt will automatically drop that table or view before building the new database object. *Note: If you are on BigQuery, you may need to run dbt run --full-refresh for this to take effect.
- The DDL/DML that is being run to build each model can be viewed in the logs through the cloud interface or the target folder.

Here's an example dbt model:
```sql
{{
    config(materialized='table')
}}

with customers as (

    select
        id as customer_id
        ...
)
```

`Model Naming Conventions`
- **Sources**(src): The raw data that has already been loaded
- **Staging**(stg): These have a one-to-one relationship with sources tables.These models are used to clean and standardize the data before transforming data downstream like renaming columns.These are typically materialized as views.
- **Intermediate**(int): Models between staging and final models. These should be built on staging models rather than directly on sources to leverage the data cleaning that was done in staging.
- **Fact**(fct): Model refers to the data that represent things that are occurring or have ocurred like events, clicks, votes, orders, transactions etc. 
- **Dimention**(dim): refers to data that represents a person, place or thing. Examples include customers, products, candidates, buildings, employees.

![image](https://user-images.githubusercontent.com/19702456/221659290-f5dd8eee-355f-479c-b6cc-88bb2cc5c95e.png)

*Note: You will see logs and target if after you run dbt run for the first time. You will not see dbt_modules if you have not imported a package yet

`Materializations`

 * The `table` strategy means that the model will be rebuilt as a table on each run.
 * We could use a `view` strategy instead, which would rebuild the model on each run as a SQL view.
 * The `incremental` strategy is essentially a `table` strategy but it allows us to add or update records incrementally rather than rebuilding the complete table on each run.
 * The `ephemeral` strategy creates a _[Common Table Expression](https://www.essentialsql.com/introduction-common-table-expressions-ctes/)_ (CTE). It does not exist in the database and are imported as CTE into downstream models. It increases build time of downstream models and you cannot query directly.
 * The `incrementa` strategy builds the entire table on the first run but only appends records on subsequent runs. It is faster to build because you are only adding new records and does not capture 100% of the data all the time.
 You can learn more about materialization strategies with dbt [in this link](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/materializations). 
 Besides the 4 common `table`, `view`, `incremental` and `ephemeral` strategies, custom strategies can be defined for advanced cases.

![image](https://user-images.githubusercontent.com/19702456/219865450-6061d1c7-cff2-4075-b201-dc411f5bee03.png)

Other than defining at the top inside model files, the default materilization can also be defined inside `dbt_project.yml`
```yml 
models:
  jaffle_shop: # project name
  ...
    marts: # model folder 
      +materialized: table
```

`ref` 

- The ref function allows us to build dependencies between models in a flexible way that can be shared in a common code base. The ref function compiles to the name of the database object as it has been created on the most recent execution of dbt run in the particular development environment. Example: _{{ ref('stg_customers') }}_ compiles to _analytics.dbt_anurag.stg_customers_.
- The ref function also builds a lineage graph. dbt is able to determine dependencies between models and takes those into account to build models in the correct order.

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

`Sources`

The FROM clause within a SELECT statement defines the sources of the data to be used. Sources represent the raw data that is loaded into the data warehouse.
- Sources are configured in YML files in the models directory. The `sources` key in our YAML file contains the details of the databases that the `source()` function can access and translate into proper SQL-valid names.
     * Additionally, we can define "source freshness" to each source so that we can check whether a source is "fresh" or "stale", which can be useful to check whether our data pipelines are working properly.
- Multiple tables from a single source can be configured in one place.
- Sources are easily identified as green nodes in the Lineage Graph.
- We can access this data with the `source()` function.
- You can use `dbt source freshness` to check the freshness of raw tables.
- The `ref` function is used to build dependencies between models. The `source` function is used to build the dependency of one model to a source.

Here's an example of how you would declare a source in a `.yml` file:

```yaml
sources:
    - name: jaffle_shop
      database: raw
      schema: data_science
      tables:
        - name: customers
        - name: orders
          loaded_at_field: record_loaded_at  # column used to check freshness of the table
          freshness:
            warn_after: {count: 12, period: hour}
            error_after: {count: 24, period: hour}
```

And here's how you would reference a source in a `FROM` clause:

```sql
FROM {{ source('name','table_name') }}
```
- The first argument of the `source()` function is the source name, and the second is the table name.

> ## Seeds
CSV files which can be stored in our repo under the `seeds` folder.
    * The repo gives us version controlling along with all of its benefits.
    * Seeds are best suited to static data which changes infrequently.
    * Seed usage:
        1. Add a CSV file to your `seeds` folder.
        1. Run the [`dbt seed` command](https://docs.getdbt.com/reference/commands/seed) to create a table in our Data Warehouse.
            * If you update the content of a seed, running `dbt seed` will append the updated values to the table rather than substituing them. Running `dbt seed --full-refresh` instead will drop the old table and create a new one.
        1. Refer to the seed in your model with the `ref()` function.
    * More info about seeds [in this link](https://docs.getdbt.com/docs/building-a-dbt-project/seeds).


In the case of seeds, assuming you've got a `taxi_zone_lookup.csv` file in your `seeds` folder which contains `locationid`, `borough`, `zone` and `service_zone`:

```sql
SELECT
    locationid,
    borough,
    zone,
    replace(service_zone, 'Boro', 'Green') as service_zone
FROM {{ ref('taxi_zone_lookup) }}
```

> ## Snapshots 
- Built as a table in the database, usually in a dedicated schema.
- On the first run, builds entire table and adds four columns: dbt_scd_id, dbt_updated_at, dbt_valid_from, and dbt_valid_to
- In future runs, dbt will scan the underlying data and append new records based on the configuration that is made.
- This allows you to capture historical data
- Timestamp: A unique key and an updated_at field is defined on the source model. These columns are used for determining changes.
- Check: Any change in a set of columns (or all columns) will be picked up as an update.
- [Snapshots Documentation](https://docs.getdbt.com/docs/building-a-dbt-project/snapshots)

> ## Tests
In dbt, tests are written as select statements. These select statements are run against your materialized models to ensure they meet your assertions.
There are two types of tests: singular and generic
- Singular tests are SQL queries stored in `tests` folder which are expected to return an empty resultset. You associate a singular test with a particular dbt model or source using the `ref` or `source` macro in the SQL query in the singular test file
- Generic tests are written in YAML and return the number of records that do not meet your assertions. These are run on specific columns in a model. There are four built-in generic tests:
   - **Unique** tests to see if every value in a column is unique
   - **Not_null** tests to see if every value in a column is not null
   - **Accepted_values** tests to make sure every value in a column is equal to a value in a provided list
   - **Relationships** tests to ensure that every value in a column exists in a column in another model
- You can define your own custom generic tests or import tests from dbt packages

```yaml
models:
  - name: stg_customers
    columns: 
      - name: customer_id
        tests:
          - unique
               severity: warn
          - not_null
               severity: warn

  - name: stg_orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values:
                - completed
                - shipped
                - returned
                - return_pending
                - placed                
```
```bash 
dbt test --select stg_customers
``
```yml
sources:
  - name: jaffle_shop
    database: raw
    schema: jaffle_shop
    tables:
      - name: customers
        columns:
          - name: id
            tests:
              - unique
              - not_null
          - name: customer_id
            tests:
               - relationships:
                    to: ref('stg_customers')
                    field: customer_id
            
      - name: orders
        columns:
          - name: id
            tests:
              - unique              
              - not_null
        loaded_at_field: _etl_loaded_at
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}

```
```bash
dbt test --select source:jaffle_shop
```
```bash
dbt test runs all tests in the dbt project
dbt test --select test_type:generic
dbt test --select test_type:singular
dbt test --select one_specific_model
```

> ## Macros
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


```sql
# Based on your environment, grant select to your role or user (depending on your data platform)
{% macro grant_select(schema=target.schema, role=target.role) %}

  {% set sql %} # set the name 
  grant usage on schema {{ schema }} to role {{ role }};
  grant select on all tables in schema {{ schema }} to role {{ role }};
  grant select on all views in schema {{ schema }} to role {{ role }};
  {% endset %}

  {{ log('Granting select on all tables and views in schema ' ~ target.schema ~ ' to role ' ~ role, info=True) }}
  {% do run_query(sql) %}
  {{ log('Privileges granted', info=True) }}

{% endmacro %}
```

`dbt run-operation grant_select`


```sql
# union_tables_by_prefix macro code:
{%- macro union_tables_by_prefix(database, schema, prefix) -%}

  {%- set tables = dbt_utils.get_relations_by_prefix(database=database, schema=schema, prefix=prefix) -%}

  {% for table in tables %}

      {%- if not loop.first -%}
      union all 
      {%- endif %}
        
      select * from {{ table.database }}.{{ table.schema }}.{{ table.name }}
      
  {% endfor -%}
  
{%- endmacro -%}


# union_tables_by_orders_prefix model code:
{{ union_tables_by_prefix(
      database='raw',
      schema='dbt_learn_jinja', 
      prefix='orders__'
      )
}}
```

```sql
# clean_stale_models macro code:
{#  
    -- let's develop a macro that 
    1. queries the information schema of a database
    2. finds objects that are > 1 week old (no longer maintained)
    3. generates automated drop statements
    4. has the ability to execute those drop statements

#}

{% macro clean_stale_models(database=target.database, schema=target.schema, days=7, dry_run=True) %}
    
    {% set get_drop_commands_query %}
        select
            case 
                when table_type = 'VIEW'
                    then table_type
                else 
                    'TABLE'
            end as drop_type, 
            'DROP ' || drop_type || ' {{ database | upper }}.' || table_schema || '.' || table_name || ';'
        from {{ database }}.information_schema.tables 
        where table_schema = upper('{{ schema }}')
        and last_altered <= current_date - {{ days }} 
    {% endset %}

    {{ log('\nGenerating cleanup queries...\n', info=True) }}
    {% set drop_queries = run_query(get_drop_commands_query).columns[1].values() %}

    {% for query in drop_queries %}
        {% if dry_run %}
            {{ log(query, info=True) }}
        {% else %}
            {{ log('Dropping object with command: ' ~ query, info=True) }}
            {% do run_query(query) %} 
        {% endif %}       
    {% endfor %}
    
{% endmacro %} 
```


> ## Documentation
- Documentations can be defined two ways:
    - In yaml files (like schema.yml)
    - In standalone markdown files
- For models, descriptions can happen at the model, source, or column level.
- If a longer form, more styled version of text would provide a strong description, doc blocks can be used to render markdown in the generated documentation.
- Dbt ships with a lightweight documentation web server
- For customizing the landing page, a special file, `overview.md` is used
- You can add your own assets (like images) to a special project folder 

```yml
models:
  - name: stg_customers
    description: Staged customer data from our jaffle shop app.
    columns: 
      - name: customer_id
        description: The primary key for customers.
        tests:
          - unique
          - not_null

  - name: stg_orders
    description: Staged order data from our jaffle shop app.
    columns: 
      - name: order_id
        description: Primary key for orders.
        tests:
          - unique
          - not_null
      - name: status
        description: "{{ doc('order_status') }}"
        tests:
          - accepted_values:
              values:
                - completed
                - shipped
                - returned
                - placed
                - return_pending
      - name: customer_id
        description: Foreign key to stg_customers.customer_id.
        tests:
          - relationships:
              to: ref('stg_customers')
              field: customer_id
```
```
{% docs order_status %}
	
One of the following values: 

| status         | definition                                       |
|----------------|--------------------------------------------------|
| placed         | Order placed, not yet shipped                    |
| shipped        | Order has been shipped, not yet been delivered   |
| completed      | Order has been received by customers             |
| return pending | Customer indicated they want to return this item |
| returned       | Item has been returned                           |

{% enddocs %}
```

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

> ## Hooks
- Hooks are SQLs that are executed at predefined times
- Hooks can be configured on the project, subfolder, or model level
- Hook types:
    - on_run_start: executed at the start of dbt {run, seed, snapshot}
    - on_run_end: executed at the end of dbt {run, seed, snapshot}
    - pre-hook: executed before a model/seed/snapshot is built
    - post-hook: executed after a model/seed/snapshot is built

> ## Packages

Macros can be exported to ***packages***, similarly to how classes and functions can be exported to libraries in other languages. Packages contain standalone dbt projects with models and macros that tackle a specific problem area. Fishtown Analytics maintains a site called hub.getdbt.com for sharing open-source packages that you can install in your project. Packages can also be imported directly from GitHub, GitLab, or another site or from a subfolder in your dbt project.

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

> ## Variables

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


> ## Deployment

Deployment in dbt (or running dbt in production) is the process of running dbt on a schedule in a deployment environment. The deployment environment will typically run from the default branch (i.e., main, master) and use a dedicated deployment schema (e.g., dbt_prod). The models built in deployment are then used to power dashboards, reporting, and other key business decision-making processes.

dbt projects are usually deployed in the form of ***jobs***:
* A ***job*** is a collection of _commands_ such as `build` or `test`. A job may contain one or more commands.
* Jobs can be triggered manually or on schedule.
    * dbt Cloud has a scheduler which can run jobs for us, but other tools such as Airflow or cron can be used as well.
* Each job will keep a log of the runs over time, and each run will keep the logs for each command.
* A job may also be used to generate documentation, which may be viewed under the run information.
* If the `dbt source freshness` command was run, the results can also be viewed at the end of a job.

In dbt Cloud, you might have noticed that after the first commit, the `main` branch becomes read-only and forces us to create a new branch if we want to keep developing. dbt Cloud does this to enforce us to open PRs for CI purposes rather than allowing merging to `main` straight away.

In order to properly establish a deployment workflow, we must define ***environments*** within dbt Cloud. In the sidebar, under _Environments_, you will see that a default _Development_ environment is already generated, which is the one we've been using so far.

We will create a new _Production_ environment of type _Deployment_ using the latest stable dbt version (`v1.0` at the time of writing these notes). By default, the environment will use the `main` branch of the repo but you may change it for more complex workflows. If you used the JSON credentials when setting up dbt Cloud then most of the deployment credentials should already be set up except for the dataset. For this example, we will use the `production` dataset (make sure that the `production` dataset/schema exists in your BigQuery project).

The dbt Cloud scheduler is available in the _Jobs_ menu in the sidebar. We will create a new job with name `dbt build` using the _Production_ environment, we will check the _Generate docs?_ checkbox. Add the following commands:

1. `dbt seed`
1. `dbt run`
1. `dbt test`

In the _Schedule_ tab at the bottom we will check the _Run on schedule?_ checkbox with a timing of _Every day_ and _every 6 hours_. Save the job. You will be shown the job's run history screen which contains a _Run now_ buttom that allows us to trigger the job manually; do so to check that the job runs successfully.

You can access the run and check the current state of it as well as the logs. After the run is finished, you will see a _View Documentation_ button at the top; clicking on it will open a new browser window/tab with the generated docs.

Under _Account settings_ > _Projects_, you may edit the project in order to modify the _Documentation_ field under _Artifacts_; you should see a drop down menu which should contain the job we created which generates the docs. After saving the changes and reloading the dbt Cloud website, you should now have a _Documentation_ section in the sidebar.

#### Deployment using dbt Core (local)

In dbt Core, environments are defined in the `profiles.yml` file. Assuming you've defined a ***target*** (an environment) called `prod`, you may build your project agains it using the `dbt build -t prod` command.

> ## Visualization

Google Data Studio

Metabase

Preset

> ## dbt commands
```bash
  dbt init <project name>
  dbt debug # run from the project directory 
  

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
```bash
$ dbt run --select my_dbt_project_name   # runs all models in your project
$ dbt run --select my_dbt_model          # runs a specific model
$ dbt run --select path.to.my.models     # runs all models in a specific directory
$ dbt run --select my_package.some_model # run a specific model in a specific package
$ dbt run --select tag:nightly           # run models with the "nightly" tag
$ dbt run --select path/to/models        # run models contained in path/to/models
$ dbt run --select path/to/my_model.sql  # run a specific model by its path
$ dbt run --select my_first_model my_second_model # multiple arguments can be provided to --select
$ dbt run --select tag:nightly my_model finance.base.* # these arguments can be projects, models, directory paths, tags, or sources
$ dbt run --select path:marts/finance,tag:nightly,config.materialized:table # use methods and intersections for more complex selectors
$ dbt run --select country_codes+ # run all models downstream of country_codes
$ dbt run --full-refresh # dbt will treat incremental models as table models. This is useful when there is schema or logic change in the incremental model.
```

> ## VS Code Extension: 
- [dbt Power User](https://marketplace.visualstudio.com/items?itemName=innoverio.vscode-dbt-power-user)

> ## References

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction).
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers.
- Join the [community](https://community.getdbt.com/) on Slack for live discussions and support.
- Find [dbt events](https://events.getdbt.com) near you.
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices.

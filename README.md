## DBT Overview 

![image](https://user-images.githubusercontent.com/19702456/216638815-6eefbc27-9312-42c8-9821-806bd91df725.png)


:point_right: Models Overview
- Models are the basic building block of your business logic
- Materialized as tables, views, etc…
- They live in SQL files in the `models` folder
- Models can reference each other and use templates and macros


:point_right: Materializations Overview

![image](https://user-images.githubusercontent.com/19702456/219865450-6061d1c7-cff2-4075-b201-dc411f5bee03.png)

:point_right: Sources and Seeds Overview
- Seeds are local files that you upload to the data warehouse from dbt
- Sources is an abstraction layer on the top of your input tables
- Source freshness can be checked automatically

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

:point_right: Documentation Overview
- Documentations can be defined two ways:
    - In yaml files (like schema.yml)
    - In standalone markdown files
- Dbt ships with a lightweight documentation web server
- For customizing the landing page, a special file, overview.md is used
- You can add your own assets (like images) to a special project folder 

:point_right: Hooks Overview
- Hooks are SQLs that are executed at predefined times
- Hooks can be configured on the project, subfolder, or model level
- Hook types:
    - on_run_start: executed at the start of dbt {run, seed, snapshot}
    - on_run_end: executed at the end of dbt {run, seed, snapshot}
    - pre-hook: executed before a model/seed/snapshot is built
    - post-hook: executed after a model/seed/snapshot is built

:point_right: 


:point_right: 


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
  dbt seed # upload seed
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

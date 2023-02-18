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
- There are four built-in generic tests. Keep the schema file in models/schema.yml
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
  dbt test #  verify if tests are passing

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

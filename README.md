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

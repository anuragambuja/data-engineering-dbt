## Data Engineering - DBT

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction).
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers.
- Join the [community](https://community.getdbt.com/) on Slack for live discussions and support.
- Find [dbt events](https://events.getdbt.com) near you.
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices.

### Git

We use Git to version control all of our work and peer review any new changes. A standard workflow is as follows:

1. Checkout and pull the latest changes on main:
    - `git checkout main`
    - `git pull origin main`
2. Create a new branch to work from:
    - `git checkout -b <branch_name>`
3. Once you've made your changes, stage them with:
    - `git add -A`
4. Commit your changes:
    - `git commit -m 'Added X, Y and Z'`
5. Push your changes:
    - `git push origin <branch_name>`
6. Open the link shown in the terminal under `Create a pull request...`, and create a pull request to the main branch.

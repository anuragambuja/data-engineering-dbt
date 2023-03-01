# Jinja 

Jinja a templating language written in the python programming language. Jinja is used in dbt to write functional SQL. For example, we can write a dynamic pivot model using Jinja.

>Jinja Basics

The best place to learn about leveraging Jinja is the Jinja Template Designer documentation.

There are three Jinja delimiters to be aware of in Jinja.

- {% … %} is used for statements. These perform any function programming such as setting a variable or starting a for loop.
- {{ … }} is used for expressions. These will print text to the rendered file. In most cases in dbt, this will compile your Jinja to pure SQL.
- {# … #} is used for comments. This allows us to document our code inline. This will not be rendered in the pure SQL that you create when you run dbt compile or dbt run.

A few helpful features of Jinja include dictionaries, lists, if/else statements, for loops, and macros.

Dictionaries are data structures composed of key-value pairs. 
```jinja
{% set person = {
    'name': 'me',
    'number': 3
} %}

{{ person.name }}  # me
{{ person['number'] }} # 3
```
Lists are data structures that are ordered and indexed by integers. 
```jinja
{% set self = ['me', 'myself'] %}

{{ self[0] }} # me
```
If/else statements are control statements that make it possible to provide instructions for a computer to make decisions based on clear criteria. 
```jinja
{% set temperature = 80.0 %}
On a day like this, I especially like

{% if temperature > 70.0 %}
a refreshing mango sorbet.

{% else %}
A decadent chocolate ice cream.

{% endif %}

On a day like this, I especially like
a refreshing mango sorbet
```
For loops make it possible to repeat a code block while passing different values for each iteration through the loop.
```jinja
{% set flavors = ['chocolate', 'vanilla', 'strawberry'] %}

{% for flavor in flavors %}
Today I want {{ flavor }} ice cream!

{% endfor %}
Today I want chocolate ice cream!

Today I want vanilla ice cream!
Today I want strawberry ice cream!
```
Macros are a way of writing functions in Jinja. This allows us to write a set of statements once and then reference those statements throughout your code base.
```jinja
{% macro hoyquiero(flavor, dessert = 'ice cream') %}
Today I want {{ flavor }} {{ dessert }}!
{% endmacro %}

{{ hoyquiero(flavor = ‘chocolate’) }}
Today I want chocolate ice cream!

{{ hoyquiero(mango, sorbet) }}
Today I want mango sorbet!
```
We can control for whitespace by adding a single dash on either side of the Jinja delimiter. This will trim the whitespace between the Jinja delimiter on that side of the expression.






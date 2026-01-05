# Principles of Data Management

Projects from my Principles of Data Management course at Rutgers.

## Project 3 – LLM to SQL pipeline

Folder: `project3_llm-sql`

This project connects a local LLM to a PostgreSQL database running on the Rutgers iLab server.

- `schema_mini.sql`  
  Defines a small PostgreSQL schema (tables like `location`, `agency`, `action_taken`, etc.) that the LLM is allowed to use.

- `ilab_script.py`  
  Reads a SELECT query, connects to the iLab PostgreSQL instance over SSH, runs the query, and prints the results in a table format.

- `database_llm.py`  
  Builds a prompt from the schema and a natural language question, sends it to a local LLM to get a SQL query, checks that the SQL only uses the allowed schema, and then forwards the query to the database.

- `mini_part2.py`  
  A minimal version of the LLM prompt logic used for testing.

### Skills shown

- Writing and running SQL on a real PostgreSQL server
- Basic schema design and working with `.sql` files
- Python scripting for database access (SSH, subprocesses)
- Prompting a local LLM to generate safe SQL from natural language
- Validating and sanitizing LLM output before sending it to the database

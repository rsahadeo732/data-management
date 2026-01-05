import os
import sys
import getpass
import shlex

import requests      
import paramiko      



def build_prompt(schema_text: str, user_question: str) -> str:
    """
    Build the prompt that we send to the local LLM.
    """
    return f"""
You are a PostgreSQL SQL generator.

Rules:
- Use ONLY tables/columns that appear in the schema.
- If you reference a column in SELECT, it must come from a table that actually contains it.
- If you use GROUP BY, do NOT ORDER BY an unrelated non-aggregated column (like an id). Order by an aggregate or a grouped column.
- Output ONLY ONE SQL query.
- The query must be SELECT (or WITH ... SELECT).
- No explanations, no backticks, no markdown.
- End the SQL with a semicolon.

SCHEMA:
{schema_text}

USER QUESTION:
{user_question}

SQL:
""".strip()

def run_with_ollama(prompt: str, model: str = "qwen2.5:3b-instruct") -> str:
    
    url = "http://localhost:11434/api/generate"
    resp = requests.post(
        url,
        json={"model": model, "prompt": prompt, "stream": False},
        timeout=300,
    )
    resp.raise_for_status()
    return resp.json().get("response", "").strip()



def extract_sql_query(llm_output: str) -> str:
    
    text = llm_output.strip()

    for marker in ("```sql", "```", "`"):
        text = text.replace(marker, "")

    text = text.strip()
    lower = text.lower()

    select_pos = lower.find("select")
    with_pos = lower.find("with")

    start_pos = -1
    if select_pos != -1 and with_pos != -1:
        start_pos = min(select_pos, with_pos)
    elif select_pos != -1:
        start_pos = select_pos
    elif with_pos != -1:
        start_pos = with_pos

    if start_pos == -1:
        raise ValueError("Could not find a SELECT or WITH in LLM output.")

    text = text[start_pos:].strip()

    semi_idx = text.find(";")
    if semi_idx != -1:
        text = text[:semi_idx + 1]

    sql = text.strip()

    if not (sql.lower().startswith("select") or sql.lower().startswith("with")):
        raise ValueError(f"Extracted SQL does not start with SELECT/WITH: {sql[:60]}")

    return sql



def connect_to_ilab(host: str = "ilab2.cs.rutgers.edu") -> paramiko.SSHClient:
    
    default_user = "zhr6"
    username = input(f"ILAB username [{default_user}]: ").strip()
    if not username:
        username = default_user

    password = getpass.getpass("ILAB password (hidden): ")

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print(f"Connecting to {host} as {username} ...")
    client.connect(hostname=host, username=username, password=password)
    print("Connected to ILAB.")
    return client


def run_query_on_ilab(ssh_client, sql_query):
    # Extra credit mode: send SQL through stdin (no argv SQL)
    remote_cmd = "python3 ilab_script.py"
    stdin, stdout, stderr = ssh_client.exec_command(remote_cmd)

    # Write the query into stdin, then close stdin so the remote script knows it's done
    stdin.write(sql_query.strip() + "\n")
    stdin.channel.shutdown_write()

    out = stdout.read().decode("utf-8", errors="replace")
    err = stderr.read().decode("utf-8", errors="replace")

    if err.strip():
        print("---- Remote STDERR ----")
        print(err)

    return out


def main():
    schema_file = "schema_mini.sql"
    if not os.path.exists(schema_file):
        print(f"ERROR: missing {schema_file} in current folder.")
        sys.exit(1)

    with open(schema_file, "r", encoding="utf-8") as f:
        schema_text = f.read()

    try:
        ssh_client = connect_to_ilab()
    except Exception as e:
        print(f"Failed to connect to ILAB: {e}")
        sys.exit(2)

    model = os.getenv("OLLAMA_MODEL", "qwen2.5:3b-instruct")

    print("\nType natural language questions about the HMDA database.")
    print("Type 'exit' to quit.\n")

    try:
        while True:
            try:
                question = input("Question> ").strip()
            except (EOFError, KeyboardInterrupt):
                print("\nExiting.")
                break

            if question.lower() == "exit":
                print("Exiting.")
                break
            if not question:
                continue

            prompt = build_prompt(schema_text, question)

            try:
                llm_output = run_with_ollama(prompt, model=model)
            except Exception as e:
                print(f"Error calling local LLM via Ollama: {e}")
                continue

            print("\n--- RAW LLM OUTPUT ---")
            print(llm_output)

            try:
                sql_query = extract_sql_query(llm_output)
            except Exception as e:
                print(f"Could not extract SQL query: {e}")
                continue

            print("\n--- EXTRACTED SQL QUERY ---")
            print(sql_query)

            try:
                result_table = run_query_on_ilab(ssh_client, sql_query)
            except Exception as e:
                print(f"Error running query on ILAB: {e}")
                continue

            print("\n--- QUERY RESULT FROM ILAB ---")
            print(result_table)
            print("-" * 70)

    finally:
        ssh_client.close()
        print("Closed ILAB connection.")


if __name__ == "__main__":
    main()

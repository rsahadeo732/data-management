import os
import sys

def build_prompt(schema_text: str, user_question: str) -> str:
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
    # Requires: Ollama installed + model pulled
    import requests
    url = "http://localhost:11434/api/generate"
    r = requests.post(url, json={"model": model, "prompt": prompt, "stream": False}, timeout=300)
    r.raise_for_status()
    return r.json().get("response", "").strip()

def run_with_llamacpp(prompt: str, model_path: str) -> str:
    # Requires: pip install llama-cpp-python and a GGUF model file on disk
    from llama_cpp import Llama
    llm = Llama(model_path=model_path, n_ctx=4096)
    out = llm(prompt, max_tokens=256, stop=["\n\n"])
    return out["choices"][0]["text"].strip()

def main():
    schema_file = "schema_mini.sql"
    if not os.path.exists(schema_file):
        print(f"ERROR: missing {schema_file} in this folder.")
        sys.exit(1)

    schema_text = open(schema_file, "r", encoding="utf-8").read()

    question = input("Ask a question (ex: 'Total loan amount by action taken'): ").strip()
    prompt = build_prompt(schema_text, question)

    mode = os.getenv("LLM_MODE", "ollama").lower()

    if mode == "ollama":
        # default model tag from Ollama library
        model = os.getenv("OLLAMA_MODEL", "qwen2.5:3b-instruct")
        answer = run_with_ollama(prompt, model=model)
    elif mode == "llamacpp":
        model_path = os.getenv("MODEL_PATH")
        if not model_path:
            print("ERROR: set MODEL_PATH to your GGUF file path (and LLM_MODE=llamacpp).")
            sys.exit(2)
        answer = run_with_llamacpp(prompt, model_path=model_path)
    else:
        print("ERROR: set LLM_MODE to 'ollama' or 'llamacpp'.")
        sys.exit(3)

    print("\n--- LLM OUTPUT ---")
    print(answer)

if __name__ == "__main__":
    main()

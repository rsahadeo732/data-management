1. Naming all team members: Zenis Rupapara - zhr6
			    Rishi Sahadeo - rs23346
			    Morgan Wei - jw1893
2. Video link is below:

https://youtu.be/nAuIh32JQ2s
			
3. Their contributions:
Morgan Wei 
Part 1 — ILAB Program (Major part) 
Responsible for:
Writing ilab_script.py that:
Accepts a SELECT SQL query as an argument
Executes on the ILAB PostgreSQL database
Prints results in table format (recommended: pandas formatting)
Tests with sample queries
Handles the extra credit option (stdin input) if possible
Debugging actual ILAB connection behavior
Deliverables connected:
14 pts category (functioning SQL → table script)
Extra credit option (1 pt)

Rishi Sahadeo
Part 2 — Local LLM + Prompting Pipeline (Major part)
Responsible for:
Setting up the local model:
Install packages (recommended: llama_cpp_python)
Download ~3–4B parameter model (Phi-4-mini-instruct or Qwen-2.5-3B)
Writing logic to:
Read schema file
Generate prompt containing instructions, schema, and user question
Experiment with prompt engineering
Running tests using basic user questions
Deliverables connected:
10 pts = LLM working locally returning text
Steps 2–3 in the project instructions
This is a full system configuration + prompt design role. 

## Part 1 — ilab_script.py (How to Run)

python3 ilab_script.py "SELECT * FROM action_taken LIMIT 5;"

python3 ilab_script.py "SELECT t.action_taken_name, COUNT(*) AS num_apps FROM application a JOIN action_taken t ON a.action_taken = t.action_taken GROUP BY t.action_taken_name ORDER BY num_apps DESC LIMIT 10;"

echo "SELECT t.action_taken_name, COUNT(*) AS num_apps FROM application a JOIN action_taken t ON a.action_taken = t.action_taken GROUP BY t.action_taken_name ORDER BY num_apps DESC LIMIT 5;" | python3 ilab_script.py

***Part 2 (Local LLM): We ran a local model using Ollama (qwen2.5:3b-instruct). The script mini_part2.py reads schema_mini.sql, builds a prompt (rules + schema + user question), sends it to the local Ollama server, and prints the SQL output. We iterated on prompt rules to prevent invalid column references and bad ORDER BY clauses; examples are recorded in part2_transcript.txt.

Zenis Rupapara:
Part 3 — Query Extraction + SSH Tunnel (Major part)
Responsible for:
Writing text-processing logic to isolate clean SELECT ... from LLM output:
Remove backticks, explanations, comments, etc.
Setting up SSH tunnel using paramiko:
Ensuring no visible password use (use getpass)
Sending extracted SQL to the ILAB script
Returning formatted results back to local program
Deliverables connected:
8 pts = working extraction of query + correct SQL file
8 pts = working SSH tunnel and integration
This job touches multiple steps (4, 5, 6, 7) and is large.

Combination of all Members:
Part 4 — Documentation + Readme + Transcript Collection -- 
(This one is intentionally lighter.)
Responsible for:
Creating all required written deliverables:
README:
team members & contributions
challenges & interesting findings
did/will you attempt extra credit?
Collecting and organizing LLM chat transcripts
Claude, Gemini, ChatGPT, etc.
Listing installation instructions
Creating the SQL subset file (schema + a few inserts)
Ensuring everything required is turned in:
2 SQL scripts
video demo (recording task can be shared*)
folder organization
Deliverables connected:
Avoid -3 (no readme) and -5 (no transcripts) penalties
Create schema input file for LLM (required in step 1–2)

- What you found challenging: Getting started was the hardest part. It took me a bit to understand what the assignment wanted because we didn’t really cover Python or LLMs in class, so I had to figure out the basics first.


- What you found interesting: we think it was really interesting to see how all the different parts of the project connected together. we’ve used LLMs before, but this was the first time we had to run one locally and make it interact with a real database over SSH. Watching a natural-language question turn into SQL, then flow through the tunnel, hit the ILAB database, and come back as a formatted table felt like building an actual end-to-end system. It also surprised me how much prompt design and small text-processing details mattered. Once everything finally clicked together, it was satisfying to see the full pipeline working cleanly.

- Did you do the extra credit : Yes.

---
name: analyze
description: "Reproducible data analysis pipeline. Translates source files to machine-friendly formats, generates analysis plans, produces runnable scripts, and tracks progress. Supports CSV, Excel, JSON, and PDF."
---

Run a reproducible data analysis pipeline. All work is saved as files — translated data, analysis plans, scripts, and outputs — so the analysis can be resumed, re-run, and audited.

## Step 1: Determine the target and check for existing analysis

- If the user specified a path (e.g., `/analyze data/sales/`), use that as the source.
- If no path given, look for common data directories: `data/`, `datasets/`, or the current directory.
- If a specific question was asked (e.g., `/analyze data/ what's the trend in revenue?`), note the question for the plan.

Check for an existing analysis workspace:

```bash
if [ -d "analysis" ] && [ -f "analysis/status.json" ]; then
  echo "EXISTING_ANALYSIS"
  cat analysis/status.json
else
  echo "NEW_ANALYSIS"
fi
```

**If `EXISTING_ANALYSIS`:** Read `analysis/status.json` to understand what's done and what's pending. Present the status to the user and ask whether to continue from where we left off or start fresh.

**If `NEW_ANALYSIS`:** Continue to Step 2.

## Step 2: Set up virtual environment

Check if `.venv-analyst` exists:

```bash
if [ -d ".venv-analyst" ]; then
  echo "VENV_EXISTS"
  source .venv-analyst/bin/activate
  python3 --version
else
  echo "VENV_MISSING"
fi
```

**If `VENV_MISSING`:** Ask the user: "Data analysis needs a Python virtual environment with pandas, matplotlib, seaborn (and optionally pdfplumber for PDFs and openpyxl for Excel). Create `.venv-analyst` and install packages?"

Stop and wait for confirmation. Then:

```bash
python3 -m venv .venv-analyst
source .venv-analyst/bin/activate
pip install pandas matplotlib seaborn
```

Conditionally install based on source file types:
- PDF files present → `pip install pdfplumber`
- Excel files present → `pip install openpyxl`

Ensure `.venv-analyst` is in `.gitignore`:
```bash
grep -q '.venv-analyst' .gitignore 2>/dev/null || echo '.venv-analyst/' >> .gitignore
```

**If `VENV_EXISTS`:** Activate and install any missing required packages silently.

## Step 3: Create workspace and launch agent

Create the analysis workspace structure:

```bash
mkdir -p analysis/{data,scripts,outputs,logs}
```

Launch the `data-analyst` agent with:
- The source file paths
- The user's question (or "profile and explore this data" if no specific question)
- The analysis workspace path (`analysis/`)
- Whether this is a new or resumed analysis

The agent handles the three-phase pipeline: translate → plan → script.

## Step 4: Present results

The agent will produce files in the `analysis/` workspace. Present:
- Summary of translated files (`analysis/data/`)
- The analysis plan (`analysis/plan.md`)
- Generated scripts (`analysis/scripts/`)
- Any outputs and charts (`analysis/outputs/`)
- Current status (`analysis/status.json`)

For any PNG files generated, read them so they're visible in the conversation.

If the analysis is partially complete, tell the user what's done and what remains.

## Rules

- **Never install packages without asking first.** The initial venv creation needs user confirmation.
- **Always use the venv.** Every Python command runs inside `.venv-analyst`. Never install into the system Python.
- **Everything goes to `analysis/`.** Data, plans, scripts, outputs — all in the workspace. Nothing ephemeral.
- **Scripts must be re-runnable.** Anyone can `cd analysis && source ../.venv-analyst/bin/activate && python scripts/01_profile.py` and get the same results.
- **Resume, don't restart.** Check `status.json` before redoing work.

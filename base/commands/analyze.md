---
name: analyze
description: "Analyze data files in a directory. Profiles datasets, answers questions, computes statistics, and generates visualizations. Supports CSV, Excel, JSON, and PDF."
---

Analyze data files and answer questions about them.

## Step 1: Determine the target

- If the user specified a path (e.g., `/analyze data/sales/`), use that.
- If no path given, look for common data directories: `data/`, `datasets/`, `analysis/`, or the current directory.
- If a specific question was asked (e.g., `/analyze data/ what's the trend in revenue?`), pass both the path and the question to the agent.

## Step 2: Set up virtual environment

Check if a `.venv-analyst` virtual environment already exists in the project root:

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

If the target includes PDF files, also install PDF support:
```bash
pip install pdfplumber
```

If the target includes Excel files (.xlsx, .xls), also install Excel support:
```bash
pip install openpyxl
```

**If `VENV_EXISTS`:** Activate it and verify packages:

```bash
source .venv-analyst/bin/activate
python3 -c "import pandas; print(f'pandas {pandas.__version__}')" 2>/dev/null || echo "MISSING: pandas"
python3 -c "import matplotlib; print(f'matplotlib {matplotlib.__version__}')" 2>/dev/null || echo "MISSING: matplotlib"
python3 -c "import seaborn; print(f'seaborn {seaborn.__version__}')" 2>/dev/null || echo "MISSING: seaborn"
python3 -c "import pdfplumber; print(f'pdfplumber {pdfplumber.__version__}')" 2>/dev/null || echo "OPTIONAL: pdfplumber (needed for PDF tables)"
python3 -c "import openpyxl; print(f'openpyxl {openpyxl.__version__}')" 2>/dev/null || echo "OPTIONAL: openpyxl (needed for Excel files)"
```

If any required package is missing, install it into the existing venv (no need to ask — the user already approved the venv).

**Important:** Ensure `.venv-analyst` is in `.gitignore`. If not:
```bash
grep -q '.venv-analyst' .gitignore 2>/dev/null || echo '.venv-analyst/' >> .gitignore
```

## Step 3: Discover data files

```bash
find <target_path> -type f \( -name "*.csv" -o -name "*.tsv" -o -name "*.xlsx" -o -name "*.xls" -o -name "*.json" -o -name "*.jsonl" -o -name "*.pdf" \) | head -50
```

If no data files found, tell the user and stop.

If many files found (>10), present a summary and ask if the user wants to analyze all of them or a subset.

## Step 4: Launch analyst

Launch the `data-analyst` agent with:
- The data file paths
- The user's question (or "profile and explore this data" if no specific question)
- Note if any Python packages are missing (so the agent can work around them)

## Step 5: Present results

The agent will return:
- Data profile (shape, columns, types, quality issues)
- Analysis with code-backed findings
- Visualizations saved as PNG files in `/tmp/`
- Key findings and suggested next questions

Present the results. For any PNG files generated, read them so they're visible in the conversation.

If the user asks follow-up questions, resume the agent with the new question — it retains the data context.

## Rules

- **Never install packages without asking first.** The initial venv creation needs user confirmation. After that, missing packages in an existing venv can be installed automatically.
- **Always use the venv.** Every Python command runs inside `.venv-analyst`. Never install into the system Python.
- **Keep .venv-analyst out of git.** Ensure it's in `.gitignore`.
- **Handle large datasets gracefully.** If a file is >100MB, note it and let the agent decide whether to sample.
- **PDF data requires inspection.** Warn the user that PDF extraction is imperfect — tables may need manual cleanup.
- **Follow-up questions reuse context.** Don't re-profile the data on every question — resume the agent.
- **Charts go to /tmp/.** Don't write files into the user's project directory unless asked.

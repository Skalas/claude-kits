---
name: analyze
description: "Analyze data files in a directory. Profiles datasets, answers questions, computes statistics, and generates visualizations. Supports CSV, Excel, JSON, and PDF."
---

Analyze data files and answer questions about them.

## Step 1: Determine the target

- If the user specified a path (e.g., `/analyze data/sales/`), use that.
- If no path given, look for common data directories: `data/`, `datasets/`, `analysis/`, or the current directory.
- If a specific question was asked (e.g., `/analyze data/ what's the trend in revenue?`), pass both the path and the question to the agent.

## Step 2: Verify Python environment

```bash
python3 -c "import pandas; print(f'pandas {pandas.__version__}')" 2>/dev/null || echo "MISSING: pandas"
python3 -c "import matplotlib; print(f'matplotlib {matplotlib.__version__}')" 2>/dev/null || echo "MISSING: matplotlib"
python3 -c "import seaborn; print(f'seaborn {seaborn.__version__}')" 2>/dev/null || echo "MISSING: seaborn"
python3 -c "import pdfplumber; print(f'pdfplumber {pdfplumber.__version__}')" 2>/dev/null || echo "OPTIONAL: pdfplumber (needed for PDF tables)"
```

If pandas or matplotlib is missing, ask the user:
"Data analysis requires Python packages. Install them with `pip install pandas matplotlib seaborn`? (Add `pdfplumber` if working with PDFs.)"

Stop and wait for confirmation before installing anything.

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

- **Never install packages without asking.** Present what's missing and let the user decide.
- **Handle large datasets gracefully.** If a file is >100MB, note it and let the agent decide whether to sample.
- **PDF data requires inspection.** Warn the user that PDF extraction is imperfect — tables may need manual cleanup.
- **Follow-up questions reuse context.** Don't re-profile the data on every question — resume the agent.
- **Charts go to /tmp/.** Don't write files into the user's project directory unless asked.

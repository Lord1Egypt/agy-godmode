# Multi-Agent Orchestration Skill

> **Note:** `<ai>` is a placeholder for your AI CLI tool (e.g., `agy`, `claude`, `copilot`, etc.). Flags and syntax may vary by provider — adapt as needed. The `--allow-execution` flag is also provider-specific (some tools use `--dangerously-skip-permissions` or `--force`).

## When to Use Subagents

Spawn an AI subshell when a task is:
- **Independent** — doesn't need current conversation context
- **Parallel** — can run alongside other tasks simultaneously
- **Isolated** — self-contained input → output with no follow-up iteration needed
- **Token-heavy** — large analysis that would pollute the main context

Don't spawn when you need to refine output iteratively or when the task requires conversation history.

---

## Subshell Patterns

### Single Task
```bash
<ai> --prompt "TASK_DESCRIPTION"
```

### With Model Selection (Cost Control)
```bash
# Complex reasoning → expensive model
<ai> --prompt "audit this Solidity contract for reentrancy: $(cat contract.sol)" \
    --model "powerful reasoning model"

# Simple tasks → cheap model
<ai> --prompt "summarize this file in 3 bullets: $(cat README.md)" \
    --model "lightweight model"
```

### Parallel Execution
```bash
# Launch multiple agents simultaneously
<ai> --prompt "analyze ~/project/contracts/TokenA.sol for security issues" \
    --allow-execution > /tmp/agent_a.txt &

<ai> --prompt "analyze ~/project/contracts/TokenB.sol for security issues" \
    --allow-execution > /tmp/agent_b.txt &

<ai> --prompt "analyze ~/project/contracts/TokenC.sol for security issues" \
    --allow-execution > /tmp/agent_c.txt &

wait  # wait for all background jobs

echo "=== TokenA ===" && cat /tmp/agent_a.txt
echo "=== TokenB ===" && cat /tmp/agent_b.txt
echo "=== TokenC ===" && cat /tmp/agent_c.txt
```

### File Generation Pipeline
```bash
# Stage 1: Generate
<ai> --prompt "write unit tests for $(cat src/utils.py)" \
    --allow-execution > tests/test_utils.py

# Stage 2: Verify the generated output
<ai> --prompt "review these tests for correctness and completeness: $(cat tests/test_utils.py)" \
    --allow-execution
```

### Directory-Scoped Agent
```bash
# Scope agent to a specific project
<ai> --prompt "TASK" --include-dir ~/my-project --allow-execution
```

---

## Orchestration Patterns

### Map-Reduce Over Files
```bash
#!/bin/bash
# Map: analyze each contract independently
results=""
for contract in contracts/*.sol; do
    result=$(<ai> --prompt "audit $contract for OWASP smart contract top 10" \
             --allow-execution)
    results+="=== $contract ===\n$result\n\n"
done

# Reduce: synthesize findings
echo -e "$results" | <ai> --prompt "synthesize these audit findings into a ranked risk report" \
    --allow-execution
```

### Sequential Refinement
```bash
# Draft
draft=$(<ai> --prompt "write a README for my-tool" --allow-execution)

# Refine
final=$(echo "$draft" | <ai> --prompt \
    "improve this README: add badges, better examples, and a quickstart. Input: $draft" \
    --allow-execution)

echo "$final" > README.md
```

### Validation Agent
```bash
# Implement something
<ai> --prompt "implement the JWT auth middleware in src/auth.py" --allow-execution

# Independent validation (separate context = no bias)
<ai> --prompt "review src/auth.py for security issues and correctness. Be critical." \
    --allow-execution
```

---

## Token Budget Management

### Estimate Token Cost
- Simple question: ~500-2K tokens
- File analysis (small file): ~2-5K tokens
- Code generation (function): ~3-8K tokens
- Full audit (contract): ~10-20K tokens
- Large codebase exploration: ~50K+ tokens (use subshells to parallelize)

### Strategy: Main Session = Orchestration Only
Reserve the main AI session for:
- High-level decisions
- Synthesis of subagent results
- Tasks requiring conversation history

Push everything else to subshells.

### Context Reset with Continuity
```bash
# 1. Save current session state
<ai> --prompt "summarize what we've done this session and what's next" \
    --allow-execution > /tmp/session_checkpoint.md

# 2. Start fresh session with context injected
<ai> --interactive \
    "Continue from checkpoint: $(cat /tmp/session_checkpoint.md). Next task: ..."
```

---

## Useful Compositions

### Codebase Explorer
```bash
<ai> --prompt "explore the codebase at ~/my-project and explain its architecture in 500 words" \
    --include-dir ~/my-project --allow-execution
```

### Batch Commit Messages
```bash
# For each changed file, generate a targeted commit message
git diff --name-only | while read file; do
    diff=$(git diff -- "$file")
    msg=$(echo "$diff" | <ai> --prompt "write a one-line git commit message for this diff" \
          --model "lightweight model" --allow-execution)
    echo "$file: $msg"
done
```

### PR Description Generator
```bash
diff=$(git diff main...HEAD)
<ai> --prompt "write a GitHub PR description with ## Summary and ## Test Plan sections for this diff: $diff" \
    --allow-execution
```

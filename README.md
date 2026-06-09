# agy-godmode

Portable configuration package for Antigravity CLI (and compatible agents like OpenCode, Gemini CLI).
Drop this onto any machine and get the full setup in one command.

---

## What's Inside

```
agy-godmode/
├── GEMINI.md          ← Main system instructions (auto-loaded by agy from ~/)
├── install.sh         ← One-command installer
├── README.md          ← This file
└── skills/
    ├── rust.md        ← Rust, wgpu, WASM, ThothTerm patterns
    ├── solidity.md    ← Smart contract audit checklist + ethsmith workflow
    ├── python.md      ← Python best practices, packaging, async
    ├── debugging.md   ← Spiral-prevention + systematic root-cause protocol
    ├── code-review.md ← Full review checklist (CRITICAL → NIT)
    ├── git-mastery.md ← Git archaeology, bisect, gh CLI workflows
    └── multi-agent.md ← agy subshell orchestration + token saving patterns
```

---

## Install (New Machine / WSL Instance)

```bash
bash install.sh
```

That's it. Installs:
- `~/GEMINI.md` — loaded automatically by agy every session
- `~/.gemini/skills/*.md` — on-demand skill library

---

## Using the Skills

Load any skill by prefixing your prompt with `@~/.gemini/skills/<name>.md`:

```bash
# Audit a smart contract
agy
> @~/.gemini/skills/solidity.md audit contracts/MyToken.sol

# Debug a Rust panic
> @~/.gemini/skills/rust.md @~/.gemini/skills/debugging.md the wgpu renderer panics on resize

# Review a PR
> @~/.gemini/skills/code-review.md review the changes in git diff HEAD~1
```

Multiple skills can be loaded at once.

---

## Subshell Pattern (saves tokens on bulk tasks)

```bash
# Analyze files in parallel without filling main context
for f in contracts/*.sol; do
  agy --print "$(cat ~/.gemini/skills/solidity.md) audit $f" \
      --dangerously-skip-permissions > "/tmp/$(basename $f).txt" &
done
wait && cat /tmp/*.txt

# Generate tests for a module
agy --print "$(cat ~/.gemini/skills/python.md) write pytest tests for $(cat src/utils.py)" \
    --dangerously-skip-permissions > tests/test_utils.py
```

---

## For Other Agent Providers (OpenCode, Cursor, Cline, etc.)

### OpenCode
OpenCode reads `AGENTS.md` or `OPENCODE.md` from the project/home directory.
Copy `GEMINI.md` content into `~/OPENCODE.md` or the project root.

### Cursor / Windsurf / Cline
Paste the contents of `GEMINI.md` into the **System Prompt** or **Rules** field in settings.
Load skills by adding them to the context via `@file` or the rules field.

### Any Claude instance (Claude Code, Claude API)
Paste `GEMINI.md` contents into `~/CLAUDE.md`.
The skill files work identically — load with `@~/.gemini/skills/<name>.md` or paste inline.

---

## What Makes This Different from Default agy

| Default agy | agy-godmode |
|-------------|-------------|
| Rewrites whole files when one line fails | Surgical fix: read error → change exact line → verify |
| Generates complete scripts in one shot | Incremental: skeleton → verify → add logic → verify |
| No language-specific rules | Full rule sets for Rust, Python, Solidity, JS |
| Generic debugging ("try this") | Root-cause protocol: quote error → form hypothesis → targeted fix |
| No memory of your projects | Full profile: projects, deployment rules, preferences |
| Silent when context gets long | Compresses session to brain file before hitting limits |

---

## Updating

When you improve `GEMINI.md` or add new skill files on your main machine:

```bash
cd ~/agy-godmode
cp ~/GEMINI.md .
cp ~/.gemini/skills/*.md skills/
# then push to GitHub if you want it synced across machines
```

---

*Originally authored by [Lord1Egypt](https://github.com/Lord1Egypt)*

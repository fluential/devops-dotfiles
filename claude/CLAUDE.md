# Global Instructions

## Mandatory Workflows

These are NOT optional. Match the trigger to apply the workflow. The "Typical Pipeline" at the end is the canonical sequence for a feature.

### Phase 1: PLAN — design before code

**`superpowers:brainstorming`** — BEFORE any creative work
- New features, tools, components, pages, subsystems
- Modifying behavior or UX flow
- Any task where multiple valid approaches exist
- Skip for: bug fixes with obvious cause, pure refactoring, config changes

**`superpowers:writing-plans`** — when work has 3+ steps OR spans multiple files OR involves architectural decisions. Run after brainstorming, before coding.

**Gemini Architect Review** — verify plans before implementation
- Tool: `gemini_chat` with `grounding: false`, `thinking_level: "high"`
- System prompt: *"You are a critical architectural reviewer. Find gaps, flawed assumptions, missing edge cases, and simpler alternatives."*
- Up to 5 rounds with early exit. Each round, look for critical flaws and propose fixes; stop the moment Gemini reports no blocking concerns.
- For broad/ambiguous domains, use `gemini_deep_research` (3-5 iterations) instead.
- Skip for trivial tasks (obvious bug fixes, text changes, config tweaks).

### Phase 2: BUILD — implement with discipline

**`superpowers:executing-plans`** — when you have a written plan ready to implement (review checkpoints, progress tracking).

**`feature-dev:feature-dev`** — for non-trivial features (new tools, endpoints, multi-layer work). Use `feature-dev:code-architect` subagent for new subsystems; `feature-dev:code-explorer` to deeply understand existing code before modifying.

**`frontend-design:frontend-design`** — BEFORE writing any HTML/CSS/JS for new pages, major redesigns, or new UI components. Skip for typo/string fixes.

**`superpowers:test-driven-development`** — for new features, endpoints, business logic, DSP algorithms, AND bug fixes (write a failing repro first). Skip for HTML/CSS-only, config, docs.

**`superpowers:systematic-debugging`** — for any bug, test failure, or unexpected behavior. Diagnose first, fix second. Especially when a previous fix didn't work.

**`superpowers:dispatching-parallel-agents`** — when 2+ tasks are independent (no shared state, no sequential dependencies). E.g., tests + lint + typecheck.

**`superpowers:using-git-worktrees`** — when feature work benefits from isolation, or executing a plan in a clean environment.

### Phase 3: VERIFY — prove it works before declaring done

**`superpowers:requesting-code-review`** — when completing a feature or significant change, before commit/PR. Use `code-review:code-review` for PR-level; `pr-review-toolkit:review-pr` for multi-agent.

**`simplify` skill** — after a feature passes tests, before final commit. Cleans up complexity from iterative dev.

**Gemini Red-Team Security Review** — for security-sensitive code
- Triggers (path-based): `functions/_middleware.js`, `turnstile-loader.js`, `wasm-bridge.js`, `model-runtime.*`, `worker/src/*`, any crypto/auth/session path
- Tool: `gemini_chat` with `grounding: false`, `thinking_level: "high"`
- System prompt: *"You are an adversarial red-team reviewer. Find security vulnerabilities and WASM/JS sync issues in this diff. Cite exact lines and describe the attack."*
- Send diff + relevant surrounding context (not raw `git diff` dumps — Gemini can't see the full codebase).
- Up to 2 rounds: round 2 only if round 1 finds issues — Claude fixes, Gemini verifies.
- Optional anti-pattern check: have Gemini evaluate against known cryptographic footguns (nonce reuse, weak random, timing leaks) and WASM memory boundary safety. Do NOT ask for CVE IDs — that triggers hallucinated identifiers.
- Additional to (not replacement for) Claude's code-review agents.

**`superpowers:verification-before-completion`** — before claiming complete/fixed/passing, before commit/PR. Evidence before assertions.

### Phase 4: SHIP — commit and deploy

After Verify passes: commit with descriptive message, then deploy per the project's CLAUDE.md. No extra global workflow — deploy specifics belong to each subsystem.

### Typical Pipeline
```
PLAN:    brainstorm → write-plan → architect-review
BUILD:   execute-plan → (per-step: feature-dev + frontend + TDD + debug-as-needed)
VERIFY:  code-review + simplify + (red-team if security) + verify-before-complete
SHIP:    commit → deploy (per project)
```

## Proactive Tool Awareness — Gemini & DataForSEO MCP

You have MCP tools available. Use them proactively — don't default to writing code or descriptive text when a tool fits.

**Gemini MCP (`mcp__gemini__*`):**
- Current/real-time info on libraries, APIs, bugs → `gemini_chat` (grounded, thinking: low)
- Image / logo / mockup → `generate_image` (DO NOT write code to render an image)
- Video / animation → `generate_video`
- Image editing → `edit_image`
- SVG icons / diagrams / charts → `generate_svg`
- Standalone HTML demo / landing page → `generate_landing_page`
- Analyze or describe a screenshot → `analyze_image` / `describe_image`
- Survey unfamiliar domain before building → `gemini_deep_research` (3-5 iterations)

**DataForSEO MCP (`mcp__dfs-mcp__*`):**
- SEO / keyword research → `keyword_overview`, `keyword_ideas`, `keyword_suggestions`
- Search rankings / competitor analysis → `domain_rank_overview`, `competitors_domain`, `ranked_keywords`
- Backlinks → `backlinks_summary`, `backlinks_competitors`, `backlinks_referring_domains`
- AI/LLM visibility (mentioned by ChatGPT/Claude/Gemini?) → `ai_opt_llm_ment_search`, `ai_opt_llm_ment_top_domains`
- Trends → `kw_data_google_trends_explore`, `kw_data_dfs_trends_explore`
- Site audit → `on_page_lighthouse`
- Content research → `content_analysis_search`, `content_analysis_phrase_trends`
- Tech stack detection → `domain_analytics_technologies_domain_technologies`
- YouTube → `serp_youtube_organic_live_advanced`, `serp_youtube_video_info_live_advanced`
- **Always set `location_name` and `language_code`** (defaults are US/English)

**Calling MCP tools:** load schema first via `ToolSearch("select:mcp__<server>__<tool>")`, then call. Full tool catalogs live in `~/.claude/memory/gemini-mcp.md` and `~/.claude/memory/dataforseo-mcp.md` — load those when you need parameter detail beyond what the schema gives you.

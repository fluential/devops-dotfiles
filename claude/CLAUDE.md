# Global Instructions

## Mandatory Workflows

These are NOT optional. Follow the skill pipeline in order for every task that qualifies.

### 1. Brainstorming: ALWAYS before creative/feature work
You MUST invoke `superpowers:brainstorming` BEFORE any creative work. This includes:
- Building a new feature or tool
- Adding new functionality to existing features
- Designing a new component, page, or subsystem
- Modifying behavior or UX flow
- Any task where multiple valid approaches exist
- Does NOT apply to: bug fixes with obvious cause, pure refactoring, config changes

### 2. Feature Development: Use for guided feature implementation
You MUST invoke `feature-dev:feature-dev` when implementing any non-trivial feature. This includes:
- New tools, pages, or endpoints
- Significant additions to existing features
- Work that spans multiple files or layers (frontend + backend + DSP)
- Use `feature-dev:code-architect` subagent for architecture design when building new subsystems
- Use `feature-dev:code-explorer` subagent to deeply understand existing code before modifying it
- Does NOT apply to: single-file bug fixes, simple text/style changes

### 3. Planning: Write plans before multi-step work
You MUST invoke `superpowers:writing-plans` when:
- A task has 3+ implementation steps
- Work spans multiple files or components
- The task involves architectural decisions
- After brainstorming produces a direction, before coding begins

### 4. Plan Verification: Gemini Architect Reviewer
Before implementing any multi-step plan or significant feature, you MUST verify the plan with Gemini as **Architect Reviewer** — up to 5 rounds (`grounding: false`, `thinking_level: "high"`). Stop early when Gemini's confidence is high and no blocking concerns remain.
1. **Round 1**: Send plan + constraints. System prompt: "You are a critical architectural reviewer. Find gaps, flawed assumptions, missing edge cases, and simpler alternatives."
2. **Round 2**: Claude responds to critique (defend valid points, acknowledge gaps). Send back for deeper review.
3. **Round 3**: Gemini digs deeper on unresolved concerns. Claude adjusts plan.
4. **Round 4** (if needed): Send refined plan for final validation.
5. **Round 5** (if needed): "Given all rounds, provide your final assessment, confidence level, and any remaining risks."
- **Stop condition**: If Gemini reports high confidence with no blocking concerns after any round, synthesize and move on. Don't force all 5 rounds.
- For broad/ambiguous domains, use `gemini_deep_research` (3-5 iterations) INSTEAD of the argue loop.
- Skip this for trivial tasks (bug fixes with obvious cause, simple text changes, config tweaks).

### 5. Plan Execution: Use structured execution for plans
You MUST invoke `superpowers:executing-plans` when you have a written plan ready to implement. This ensures:
- Review checkpoints between steps
- Structured progress tracking
- No steps get skipped or forgotten

### 6. HTML/Frontend: Always use `frontend-design` skill
When creating or significantly modifying HTML pages, templates, or frontend components, you MUST invoke the `frontend-design:frontend-design` skill BEFORE writing any HTML/CSS/JS. This applies to:
- New pages or templates
- Major visual redesigns or layout changes
- New UI components (modals, cards, forms, navigation)
- Does NOT apply to trivial changes (fixing a typo, changing a text string, adding a data attribute)

### 7. Test-Driven Development: Write tests before implementation
You MUST invoke `superpowers:test-driven-development` when:
- Implementing any new feature or endpoint
- Fixing a bug (write a failing test that reproduces it first)
- Adding business logic or DSP algorithms
- Does NOT apply to: HTML/CSS-only changes, config files, documentation

### 8. Debugging: Systematic approach to bugs
You MUST invoke `superpowers:systematic-debugging` when:
- Encountering any bug, test failure, or unexpected behavior
- BEFORE proposing fixes — diagnose first, fix second
- When a previous fix attempt didn't work

### 9. Parallel Agents: Parallelize independent work
You MUST invoke `superpowers:dispatching-parallel-agents` when:
- 2+ independent tasks can be worked on simultaneously
- Tasks don't share state or have sequential dependencies
- Example: running tests + linting + type checking in parallel

### 10. Code Review: Review before completion
You MUST invoke `superpowers:requesting-code-review` when:
- Completing a feature or significant change
- Before creating a PR or committing final work
- Use `code-review:code-review` for PR-level reviews
- Use `pr-review-toolkit:review-pr` for comprehensive multi-agent PR review

### 11. Verification: Prove it works before claiming done
You MUST invoke `superpowers:verification-before-completion` when:
- About to claim work is complete, fixed, or passing
- Before committing or creating PRs
- Evidence before assertions — run tests, verify output, confirm behavior

### 12. Git Worktrees: Isolate feature work
You SHOULD invoke `superpowers:using-git-worktrees` when:
- Starting feature work that benefits from isolation
- Working on changes that might conflict with current state
- Executing implementation plans in a clean environment

### 13. Code Simplification: Clean up after implementation
You SHOULD invoke the `simplify` skill when:
- A feature implementation is complete and passing tests
- Code has grown complex during iterative development
- Before final commit to ensure code quality

### 14. Security Review: Gemini Red-Team Code Reviewer
You MUST use `gemini_chat` as a **Red-Team Code Reviewer** — up to 2 rounds — when changing security-sensitive code:
- **Triggers**: Changes to `functions/_middleware.js`, `turnstile-loader.js`, `wasm-bridge.js`, `model-runtime.*`, Worker code (`worker/src/*`), any crypto/auth/session path
- **Round 1**: Send the diff + surrounding context. System prompt: "You are an adversarial security red-team reviewer. Find vulnerabilities, logic errors, race conditions, bypass opportunities, injection vectors, auth bypasses, timing attacks, information leakage, and WASM/JS sync issues. Cite exact lines. Describe the attack."
  - Use `grounding: false`, `thinking_level: "high"` for pure adversarial reasoning.
- **Round 2** (if issues found): Claude addresses findings, sends fixes back. Gemini verifies fixes and checks for regressions.
- **Optional CVE check**: After the red-team rounds, optionally do one `grounding: true` call to check if any flagged patterns have known CVEs.
- **Stop condition**: If round 1 finds no issues, no round 2 needed. Don't force both rounds.
- Does NOT replace Claude's code-review agents — this is an *additional* adversarial pass on security-critical paths.

### Typical skill pipeline for a new feature
```
brainstorming → writing-plans → Gemini Architect Review (up to 5 rounds) → executing-plans
  → (per step: feature-dev + frontend-design + TDD)
  → requesting-code-review + Gemini Red-Team (if security-sensitive)
  → verification-before-completion → commit
```

### Proactive Tool Awareness: Use Gemini & DataForSEO MCP when relevant
You have two powerful MCP servers available. Use them proactively — don't wait for the user to ask.

**Gemini MCP (`mcp__gemini__*`) — use when:**
- You need current/real-time info about libraries, APIs, or bugs → `gemini_chat` (grounded)
- User asks for an image, logo, mockup, or visual asset → `generate_image`
- User asks for a video clip or animation → `generate_video`
- User wants to edit an existing image → `edit_image`
- You need SVG icons, diagrams, or charts → `generate_svg`
- A standalone HTML page is needed (landing page, demo) → `generate_landing_page`
- You want to analyze or describe a screenshot/image → `analyze_image` / `describe_image`
- A complex domain needs surveying before building → `gemini_deep_research`
- You're unsure about post-cutoff API changes or library behavior → `gemini_chat` (grounded, thinking: low)

**DataForSEO MCP (`mcp__dfs-mcp__*`) — use when:**
- SEO / keyword research is discussed → `keyword_overview`, `keyword_ideas`, `keyword_suggestions`
- User asks about search rankings or competitor analysis → `domain_rank_overview`, `competitors_domain`, `ranked_keywords`
- Backlink analysis or link building is mentioned → `backlinks_summary`, `backlinks_competitors`, `backlinks_referring_domains`
- User wants to check AI/LLM visibility (is site mentioned by ChatGPT/Claude/Gemini?) → `ai_opt_llm_ment_search`, `ai_opt_llm_ment_top_domains`
- Google Trends or keyword trends are needed → `kw_data_google_trends_explore`, `kw_data_dfs_trends_explore`
- Site audit / Lighthouse performance check → `on_page_lighthouse`
- Content research or phrase trends → `content_analysis_search`, `content_analysis_phrase_trends`
- Tech stack detection on a competitor → `domain_analytics_technologies_domain_technologies`
- YouTube search or video analysis → `serp_youtube_organic_live_advanced`, `serp_youtube_video_info_live_advanced`
- **Always specify `location_name` and `language_code`** — defaults are US/English

**How to call any MCP tool**: Run `ToolSearch("select:mcp__<server>__<tool>")` first to load the schema, then call it. See memory files for full tool catalogs: `~/.claude/memory/gemini-mcp.md` and `~/.claude/memory/dataforseo-mcp.md`.

## Gemini MCP (@houtini/gemini-mcp)

MCP server providing Gemini AI tools inside Claude Code. These extend Claude's native capabilities with image/video generation, Google Search grounding, and deep research.

### Available Tools

| Tool | When to use |
|------|-------------|
| `gemini_chat` | Google Search grounded answers — current/real-time web info, verify APIs, check known bugs |
| `gemini_deep_research` | Multi-iteration research synthesis (3-10 iterations, 2-5 min) |
| `generate_image` | Image creation with optional search grounding (Claude can't generate images natively) |
| `edit_image` | Natural-language image editing with multi-turn continuity |
| `generate_video` | Veo 3.1 video generation (4-8s, up to 4K, native audio) |
| `analyze_image` | Structured image extraction via Gemini 3.1 Pro |
| `describe_image` | Fast image descriptions via Gemini 3 Flash |
| `generate_svg` | Production-ready vector graphics and diagrams (9 design systems) |
| `generate_landing_page` | Self-contained HTML pages (inline CSS/JS) |
| `gemini_prompt_assistant` | Image gen guidance with 9 chart design systems |

### How to call

All tools are prefixed `mcp__gemini__`. Must load via ToolSearch before calling:
```
ToolSearch: "select:mcp__gemini__generate_image"
then: mcp__gemini__generate_image(...)
```

### When to use Gemini vs native Claude

- **Google Search / current info** -> `gemini_chat` with grounding
- **Image generation** -> `generate_image` (Claude can't generate images)
- **Video generation** -> `generate_video` (Claude can't generate video)
- **Image editing** -> `edit_image` (multi-turn conversational editing)
- **Deep web research** -> `gemini_deep_research` (multi-iteration synthesis)
- **SVG/diagrams** -> `generate_svg` (specialized design systems)
- **Landing pages** -> `generate_landing_page` (self-contained HTML)
- **Reasoning / code / codebase questions** -> stay with Claude (don't use Gemini)
- **Things already in project docs** -> stay with Claude (don't use Gemini)

### gemini_chat — three roles

**Role 1: Search Oracle** (`grounding: true`, `thinking_level: "low"`):
- Debugging external library issues — "is this a known bug in X?"
- Verifying current APIs — library docs may have changed post-cutoff
- Current best practices for fast-moving ecosystems
- Keep queries specific and scoped — e.g. "librosa 0.10 breaking changes" not "librosa problems"

**Role 2: Architect Reviewer** (`grounding: false`, `thinking_level: "high"`):
Up to 5 rounds for plan critique. Stop when Gemini's confidence is high and no blocking concerns remain. See Mandatory Workflow #4 for full protocol.
- System prompt: "You are a critical architectural reviewer. Find gaps, flawed assumptions, missing edge cases, and simpler alternatives."
- Each round builds on previous. Claude defends valid points, acknowledges gaps, adjusts plan.
- Do BEFORE committing to implementation.

**Role 3: Red-Team Code Reviewer** (`grounding: false`, `thinking_level: "high"`):
Up to 2 rounds for adversarial security review of code diffs. See Mandatory Workflow #14 for triggers and full protocol.
- System prompt: "You are an adversarial security red-team reviewer. Find vulnerabilities, logic errors, race conditions, bypass opportunities, injection vectors, auth bypasses, timing attacks, information leakage, and WASM/JS sync issues. Cite exact lines. Describe the attack."
- Send diff + relevant surrounding context (not raw `git diff` dumps — Gemini can't see the full codebase).
- Optional follow-up with `grounding: true` to check flagged patterns against known CVEs.

**Parameters**:
- `grounding: true` (default) — Gemini searches Google first, then answers with source links
- `grounding: false` — pure LLM reasoning, no web search (use for Architect Review and Red-Team)
- `thinking_level: "low"` — fast factual lookups (known bugs, API signatures)
- `thinking_level: "high"` — deep reasoning (architectural decisions, plan critique, security review)
- `system_prompt` — set the role: search oracle, architect reviewer, or red-team reviewer

### gemini_deep_research — survey a landscape

`max_iterations: 3-5` (2-5 min). Multiple grounded search iterations -> synthesized report.

**When to use**:
- Surveying state of the art: "current approaches to X"
- Competitive landscape analysis
- Architecture decisions with many viable options
- Undocumented behavior across library versions
- Pre-design research before building a new subsystem

**When NOT to use** (use `gemini_chat` instead):
- Single factual question ("does X support Y?")
- Quick API lookup or bug check
- Anything answerable in one search hit

### Image and video generation

- `generate_image`: text-to-image, supports `grounding: true` for reference-aware generation
- `edit_image`: pass existing image + natural language edit instruction, supports multi-turn editing sessions
- `generate_video`: Veo 3.1 — 4-8 second clips, up to 4K resolution, native audio generation
- `generate_svg`: production vector graphics with 9 specialized design systems
- `gemini_prompt_assistant`: get guidance on crafting effective image generation prompts

### Models used internally

- `gemini-3.1-pro-preview` — chat, analysis (default)
- `gemini-3-pro-image-preview` — highest quality image gen/edit
- `gemini-3-flash-preview` — fast descriptions
- `veo-3.1-generate-preview` — video generation (4K, native audio)

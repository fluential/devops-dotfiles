#!/bin/bash
# Claude Code statusline: caveman badge, model, repo + MR, prompt cache, cost.
# Reads the session JSON Claude Code pipes on stdin and prints two lines.
# Wired via "statusLine" in ~/.claude/settings.json. Targets macOS /bin/bash 3.2.
#
# Always brace variables next to literal text (${DIM}│, not $DIM│): bash 3.2 in
# a UTF-8 locale reads the first byte of a multibyte char as part of the name.

CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

E=$'\e'
RST="${E}[0m"
DIM="${E}[2m"
BOLD="${E}[1m"
ORANGE="${E}[38;5;172m"
CYAN="${E}[36m"
MAGENTA="${E}[35m"
YELLOW="${E}[33m"
GREEN="${E}[32m"
RED="${E}[31m"
ICE="${E}[38;5;75m"
SEP=" ${DIM}│${RST} "

# One jq pass pulls every field. Split on \x1f rather than tab: bash `read`
# collapses runs of whitespace IFS, so an empty field would shift the rest.
US=$'\x1f'
IFS="$US" read -r model effort fast dir pr_num pr_url pr_state pr_kind \
  cache_state cache_hit cache_left recache cost_cents added removed <<<"$(
  jq -r --arg us "$US" '
    def human:
      if . >= 1000000 then "\(. / 100000 | floor / 10)M"
      elif . >= 1000 then "\(. / 1000 | floor)k"
      else tostring end;
    (.prompt_cache // null) as $c
    | ($c.expires_at // 0) as $exp
    | [ .model.display_name // "",
        .effort.level // "",
        (.fast_mode == true | tostring),
        .workspace.current_dir // .cwd // "",
        (.pr.number // "" | tostring),
        .pr.url // "",
        .pr.review_state // "",
        .pr.kind // "",
        (if $c == null then ""
         elif $c.warm == true and $exp > now then "warm"
         else "cold" end),
        (if $c.hit_ratio == null then "" else ($c.hit_ratio * 100 | round | tostring) end),
        (($exp - now) / 60 | floor | tostring),
        (if $c.recache_tokens_if_cold == null then "" else ($c.recache_tokens_if_cold | human) end),
        ((.cost.total_cost_usd // 0) * 100 | round | tostring),
        (.cost.total_lines_added // 0 | tostring),
        (.cost.total_lines_removed // 0 | tostring)
      ] | join($us)' 2>/dev/null
)"

# Join non-empty arguments with SEP.
join() {
  local out="" s
  for s in "$@"; do
    [ -n "$s" ] && out="${out:+${out}${SEP}}${s}"
  done
  printf '%s' "$out"
}

# --- caveman badge ------------------------------------------------------------
# Same hardening as the plugin's own statusline: refuse symlinks, cap the read,
# whitelist the mode, strip control bytes from the savings suffix.
badge=""
flag="$CFG/.caveman-active"
if [ -f "$flag" ] && [ ! -L "$flag" ]; then
  mode=$(head -c 64 "$flag" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
  case "$mode" in
    full) badge="[CAVEMAN]" ;;
    lite|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      badge="[CAVEMAN:$(printf '%s' "$mode" | tr '[:lower:]' '[:upper:]')]" ;;
  esac
  suffix_file="$CFG/.caveman-statusline-suffix"
  if [ -n "$badge" ] && [ -f "$suffix_file" ] && [ ! -L "$suffix_file" ]; then
    suffix=$(head -c 64 "$suffix_file" 2>/dev/null | tr -d '\000-\037\177')
    [ -n "$suffix" ] && badge="${badge} ${suffix}"
  fi
  [ -n "$badge" ] && badge="${ORANGE}${badge}${RST}"
fi

# --- model --------------------------------------------------------------------
model_seg=""
if [ -n "$model" ]; then
  model_seg="${CYAN}${model}${RST}"
  [ -n "$effort" ] && model_seg="${model_seg} ${DIM}·${RST} ${effort}"
  [ "$fast" = true ] && model_seg="${model_seg} ${YELLOW}⚡${RST}"
fi

# --- repo: dir, branch, dirty marker, MR ----------------------------------------
# --no-optional-locks: this runs while Claude runs its own git commands; a
# plain `git status` can take .git/index.lock and make those fail.
repo_seg=""
if [ -n "$dir" ]; then
  repo_seg="${BOLD}${dir##*/}${RST}"
  branch=$(git --no-optional-locks -C "$dir" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git --no-optional-locks -C "$dir" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    [ -n "$(git --no-optional-locks -C "$dir" status --porcelain 2>/dev/null | head -1)" ] && dirty="${YELLOW}*${RST}"
    repo_seg="${repo_seg} ${DIM}⎇${RST} ${MAGENTA}${branch}${RST}${dirty}"
  fi
fi

if [ -n "$pr_num" ]; then
  mr='#'
  [ "$pr_kind" = mr ] && mr='!'
  mr="${mr}${pr_num}"
  case "$pr_state" in
    approved)          mr="${mr}✅" ;;
    pending)           mr="${mr}⏳" ;;
    changes_requested) mr="${mr}✋" ;;
    draft)             mr="${mr}📝" ;;
  esac
  # OSC 8 hyperlink: Cmd+click opens the MR/PR.
  pr_url=$(printf '%s' "$pr_url" | tr -d '\000-\037\177')
  [ -n "$pr_url" ] && mr="${E}]8;;${pr_url}"$'\a'"${mr}${E}]8;;"$'\a'
  repo_seg="${repo_seg:+${repo_seg} }${mr}"
fi

# --- prompt cache ---------------------------------------------------------------
# Cold means the next prompt re-writes the whole prefix to cache (slow, pricier).
cache_seg=""
case "$cache_state" in
  warm)
    left="${cache_left}m"
    [ "$cache_left" -lt 1 ] 2>/dev/null && left="<1m"
    cache_seg="${GREEN}🔥 cache${cache_hit:+ ${cache_hit}%} · ${left} left${RST}"
    ;;
  cold)
    cache_seg="${ICE}❄ cache cold${recache:+ · ${recache} to recache}${RST}"
    ;;
esac

# --- cost + lines ---------------------------------------------------------------
# Cost arrives as integer cents from jq, so no float printf (locale-proof).
cents=${cost_cents:-0}
frac=$((cents % 100))
[ "$frac" -lt 10 ] && frac="0${frac}"
cost_seg="\$$((cents / 100)).${frac}"

lines_seg=""
if [ "${added:-0}" != 0 ] || [ "${removed:-0}" != 0 ]; then
  lines_seg="${GREEN}+${added:-0}${RST}/${RED}−${removed:-0}${RST}"
fi

printf '%s\n%s\n' \
  "$(join "$badge" "$model_seg" "$repo_seg")" \
  "$(join "$cache_seg" "$cost_seg" "$lines_seg")"

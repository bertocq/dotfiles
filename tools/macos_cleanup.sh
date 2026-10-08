#!/usr/bin/env bash
#
# macos_cleanup.sh - Modular, non-interactive disk cleanup for macOS.
#
# BEGIN USER GUIDE (printed by --help; keep lines within 80 columns)
# USAGE
#   macos_cleanup.sh               Run ALL sections: colima, bergamotte,
#                                  bloomandwild, caches (in that order).
#   macos_cleanup.sh <section>...  Run only the named sections, in the
#                                  order given. Example: `... caches`.
#   macos_cleanup.sh -n|--dry-run [section]...
#                                  Preview: print every command that would
#                                  delete or change something, run none.
#   macos_cleanup.sh -l|--list     List the sections and exit.
#   macos_cleanup.sh -h|--help     Show this guide and exit.
#
#   No arguments = everything, `caches` included. Naming sections only
#   restricts the run; it never adds anything.
#
#   No prompts: every step of every selected section runs, destructive ones
#   included. Each command is printed before it runs and all output is also
#   appended to a per-run log: ${TMPDIR:-/tmp}/macos_cleanup.<ts>.<pid>.log
#   On the first failure (or Ctrl-C) the run HALTS and prints a report to
#   stderr (step, command, exit code, likely cause, debug info); paste it,
#   with this script, to an AI agent to get it fixed. A summary of the space
#   freed per section is printed at the end.
#
#   DRY RUN (-n|--dry-run): nothing is deleted or changed. Commands that
#   would delete or change something are printed as `[dry-run] $ cmd` and
#   skipped; read-only ones (du, docker system df, git count-objects, git
#   prune --dry-run, brew cleanup -n...) still run so the report is useful.
#   All checks still apply: a running Chrome/Discord is skipped as usual; a
#   busy git repo is reported as a warning (the real run would halt there).
#   The summary shows an ESTIMATE of the space each section would free.
#
# BEFORE RUNNING: CHECKLIST
#   [ ] Run with --dry-run first to preview what would be deleted.
#   [ ] Quit Google Chrome (Cmd-Q, not just its windows). While it runs, ALL
#       Chrome caches are skipped with a warning (~5.8G last measured,
#       profile caches included).
#   [ ] Quit Discord (Cmd-Q; it stays alive in the menu bar). While it runs,
#       its caches are skipped with a warning (~0.4G).
#       Chrome and Discord are the only apps checked; none is ever killed.
#   [ ] No git command running in bergamotte / bloomandwild (rebase, fetch,
#       IDE git integration, git gc...). If one is (or a stale .git/index.lock
#       or gc.pid is left), the run HALTS before git prune/gc/worktree prune.
#   [ ] Stop dev servers, specs and asset/yarn watchers in those repos: their
#       tmp/, node_modules, vendor/bundle and app/assets/builds are deleted.
#   [ ] For `colima`: start Colima (`colima start`) to have Docker pruned,
#       and start every container you want to keep: stopped containers are
#       removed first, then any image or volume no container uses is deleted.
#
# SECTIONS
#   colima        When: Docker/Colima disk usage (~/.colima) has grown.
#     Deletes: stopped containers; ALL images not used by a container; ALL
#     unused volumes, named ones included (their data is LOST permanently);
#     build cache; downloaded VM images in ~/Library/Caches/colima. Then runs
#     fstrim on the VM disk so freed blocks return to macOS.
#     Needs Colima running, else the Docker steps are skipped (a note).
#     After: images are re-pulled/rebuilt on next use.
#
#   bergamotte    Repo ~/dev/bergamotte/bergamotte.
#     When: after heavy test runs, or when the repo bloats.
#     Deletes: contents of tmp/storage, tmp/cache, tmp/capybara; truncates
#     log/*.log; old graphify-out/YYYY-MM-DD snapshots (newest and
#     graph.json kept) and graphify-out/cache; ./core if it is an ELF core
#     dump; unreachable git objects (git prune --expire=now, git gc
#     --prune=now: slow); .git tmp_obj_* older than 60 min; stale worktree
#     entries; node_modules (root, engines/online_store, engines/shipping,
#     iso/internal); app/assets/builds.
#     After: `yarn install`, bin/assets-build; graphify cache regeneration
#     costs API tokens.
#
#   bloomandwild  Repo ~/dev/bloomandwild/bloomandwild.
#     When: after heavy test runs, when the repo bloats, or after
#     downloading staging DB dumps.
#     Deletes: contents of tmp/storage, tmp/cache, tmp/capybara; truncates
#     log/*.log; old graphify snapshots and graphify-out/cache;
#     tmp/db_backup_*.dump; vendor/bundle; stale worktree entries.
#     After: `bundle install` in docker (vendor/bundle holds linux-aarch64
#     gems); graphify cache regeneration costs API tokens.
#     Never touches .dockerdev/ (live Postgres data, init backup.dump).
#
#   caches        When: any time; most useful periodically or when the disk
#     is low. Quit Chrome and Discord first (see the checklist).
#     - Chrome: ~/Library/Caches/Google/Chrome (HTTP/code/GPU cache); in
#       every profile: Service Worker, Shared Dictionary, GPU/Dawn caches;
#       root shader caches. After: slower first page loads; sites lose their
#       service worker data (PWA offline data, web push registrations).
#       Logins, cookies, history, bookmarks and settings are kept.
#     - Discord: Cache, Code Cache, GPUCache, Service Worker. After: slower
#       first start, media is re-downloaded. Login is kept.
#     - Homebrew: `brew cleanup -s --prune=all` (all cached downloads and
#       old versions). After: reinstalls re-download.
#     - Aerial wallpaper/screensaver videos (manifest and thumbnails kept).
#       After: macOS re-downloads a video when it is next shown.
#     - Apple caches GeoServices, com.apple.helpd, com.apple.CloudTelemetry:
#       best-effort, a macOS-protected file only warns. macOS rebuilds them.
#     - Spotify: a note only (clear it in Spotify > Settings > Storage).
#
# NEVER TOUCHED
#   Spotify (offline downloads), Slack, Sublime Text, Playwright browsers,
#   uv, WhatsApp, and every other ~/Library/Caches entry, including Apple
#   caches other than the three above; .dockerdev/state and
#   .dockerdev/init/db/backups/backup.dump; git stashes; worktrees whose
#   directory still exists. Running apps are never killed.
# END USER GUIDE
#
# ===========================================================================
# DEVELOPER NOTES
#
# Layout: config -> output helpers -> error handling -> command execution ->
# guards -> generic cleaners -> sections -> section registry -> CLI + main.
#
# Safety guards that are kept (they protect live state; they are not prompts):
#   - .dockerdev/state and .dockerdev/init/db/backups/backup.dump are never
#     touched.
#   - git prune / gc / worktree prune and tmp_obj_* cleanup require that no
#     git process is active on the repo; if one is, the script HALTS with the
#     failure report (it does not silently skip). In dry-run it only warns.
#   - .git/objects/tmp_obj_* files are only removed when older than
#     GIT_TMP_OBJ_MIN_AGE_MIN minutes.
#   - REPO/core is only removed when `file` reports it as an ELF core dump.
#   - Deletions refuse empty paths, "/" and $HOME (halts with a report).
# Not errors (a note is printed and the script continues):
#   - a directory or repository that does not exist;
#   - a tool that is not installed (colima, docker, git, brew);
#   - Colima not running (Docker steps are skipped);
#   - Chrome or Discord running while its caches would be deleted: a warning
#     is printed and those caches are skipped, apps are never killed;
#   - rm failing on a macOS-protected file ("Operation not permitted") in the
#     small Apple caches (GeoServices, com.apple.helpd,
#     com.apple.CloudTelemetry): a warning is printed (best-effort steps).
#
# Command execution (the read-only vs mutating split):
#   run CMD...      deletes/changes something. Printed and executed; halts
#                   with the failure report on a non-zero exit. In dry-run it
#                   is printed as `[dry-run] $ CMD` and NOT executed.
#   try_run CMD...  like run, but a failure only warns (best-effort steps).
#   probe CMD...    read-only. Always executed, dry-run included; halts on
#                   failure like run.
#   Plain `$(...)` captures (du, find listing, git ... --dry-run) must be
#   read-only too, and guarded with `|| true` when a failure is harmless.
#
# HOW TO ADD A NEW SECTION
#   1. Add its paths/constants to the CONFIG block.
#   2. Write a function named `cleanup_<name>` (e.g. `cleanup_homebrew`):
#      - prefer the generic cleaners (clean_contents, remove_dir,
#        delete_files, clean_app_caches...): they print steps and sizes,
#        guard paths, feed the dry-run estimate and honour dry-run;
#      - otherwise call `step "description"` before each logical action (it
#        prints a header and is what the failure report names), run commands
#        through run / try_run / probe (see above), call `show_target PATH`
#        on what is about to be deleted (prints its size and adds it to the
#        dry-run estimate) and `guard_path PATH` before any rm;
#      - use `require_cmd NAME || return 0` to skip when a tool is missing;
#      - any command whose non-zero exit is expected (grep with no match,
#        pgrep, command -v, test) must be guarded with `if`, `||` or
#        `|| true`; any other failure halts the script with the report.
#   3. Add one line "<name>|<short description>" to the SECTIONS registry.
#   That's it: the section is then listed by --list and runs by default.
#
# Compatible with the bash 3.2 that ships with macOS (no associative arrays,
# no mapfile, no ${var,,}; never expand an empty array under `set -u`).

# ===========================================================================
# STRICT MODE, GLOBALS AND CONFIG
# ===========================================================================
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"

# --- Paths (all derived from $HOME) ---------------------------------------
CACHES_DIR="${HOME}/Library/Caches"
APPSUP_DIR="${HOME}/Library/Application Support"

COLIMA_DIR="${HOME}/.colima"
COLIMA_CACHE_DIR="${CACHES_DIR}/colima"

BERGAMOTTE_REPO="${HOME}/dev/bergamotte/bergamotte"
BERGAMOTTE_NODE_MODULES=(node_modules engines/online_store/node_modules
  engines/shipping/node_modules iso/internal/node_modules)
BERGAMOTTE_ASSET_BUILDS="app/assets/builds"

BLOOMANDWILD_REPO="${HOME}/dev/bloomandwild/bloomandwild"
BLOOMANDWILD_DB_DUMPS='db_backup_*.dump'          # in REPO/tmp
BLOOMANDWILD_DOCKERDEV_STATE=".dockerdev/state"
BLOOMANDWILD_DOCKERDEV_DUMP=".dockerdev/init/db/backups/backup.dump"

CHROME_PROCESS="Google Chrome"
CHROME_CACHE_DIR="${CACHES_DIR}/Google/Chrome"
CHROME_USER_DATA="${APPSUP_DIR}/Google/Chrome"
# Chromium cache folder names found inside each Chrome profile directory
# (Default, Profile N, System Profile, Guest Profile, ...).
CHROME_PROFILE_CACHES=("Service Worker" "Shared Dictionary" "GPUCache"
  "DawnCache" "DawnGraphiteCache" "DawnWebGPUCache")
# GPU/shader caches at the Chrome user-data root (shared by all profiles).
CHROME_ROOT_CACHES=("GraphiteDawnCache" "GrShaderCache" "ShaderCache")

DISCORD_PROCESS="Discord"
DISCORD_DIR="${APPSUP_DIR}/discord"
DISCORD_CACHES=("Cache" "Code Cache" "GPUCache" "Service Worker")

AERIALS_DIR="${APPSUP_DIR}/com.apple.wallpaper/aerials"   # videos/ cleared
APPLE_BEST_EFFORT_CACHES=(GeoServices com.apple.helpd com.apple.CloudTelemetry)
BREW_CACHE_DIR="${CACHES_DIR}/Homebrew"

# --- Constants -------------------------------------------------------------
GIT_TMP_OBJ_MIN_AGE_MIN=60       # only older tmp_obj_* files are removed
GRAPHIFY_SNAPSHOT_PATTERN='[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
LOG_TAIL_LINES=20                # log lines shown in the failure report

# --- Run state ---------------------------------------------------------------
DRY_RUN=0
START_PWD="$PWD"
ORIG_ARGS=""
LOG=""
SELECTED=""
COMPLETED=""
CURRENT_SECTION=""
CURRENT_STEP=""
CURRENT_CMD=""
REPORTED=0
RUN_RC=0
ESTIMATE_KB=0        # dry-run: KiB the current section would free

if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_CYAN=$'\033[36m'
else
  C_RESET=""; C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_CYAN=""
fi

# ===========================================================================
# OUTPUT AND LOGGING HELPERS (terminal gets colors, the log plain text)
# ===========================================================================
log_plain() {
  if [ -n "$LOG" ]; then printf '%s\n' "$@" >>"$LOG"; fi
}

info()   { printf '%s\n' "${C_GREEN}==>${C_RESET} $*"; log_plain "==> $*"; }
warn()   { printf '%s\n' "${C_RED}WARNING:${C_RESET} $*" >&2; log_plain "WARNING: $*"; }
note()   { printf '%s\n' "${C_DIM}note:${C_RESET} $*"; log_plain "note: $*"; }
header() { printf '\n%s\n' "${C_BOLD}${C_CYAN}### $*${C_RESET}"; log_plain "" "### $*"; }

# step "description": mark the start of a logical action. The failure report
# names the current section and step.
step() {
  CURRENT_STEP="$*"
  printf '%s\n' "${C_BOLD}${C_YELLOW}--> $*${C_RESET}"
  log_plain "--> $*"
}

is_dry_run() { [ "$DRY_RUN" -eq 1 ]; }

# quote_cmd ARGS...: format argv as a shell-quoted command string.
quote_cmd() {
  local out="" arg
  for arg in "$@"; do
    out="${out}$(printf '%q' "$arg") "
  done
  printf '%s' "${out% }"
}

# human_kb KB: human-readable size from KiB (signed).
human_kb() {
  awk -v kb="$1" 'BEGIN {
    s = (kb < 0) ? "-" : ""; if (kb < 0) kb = -kb
    split("KiB MiB GiB TiB", u, " "); i = 1
    while (kb >= 1024 && i < 4) { kb /= 1024; i++ }
    printf "%s%.1f %s\n", s, kb, u[i]
  }'
}

# kb_from_human SIZE...: total KiB of sizes like "1.2GB", "512MB", "12kB",
# "0B" (docker / brew output). Unparsable words count as 0.
kb_from_human() {
  printf '%s\n' "$@" | awk '{
    if (match($0, /^[0-9.]+/)) {
      n = substr($0, 1, RLENGTH); u = toupper(substr($0, RLENGTH + 1, 1))
      if (u == "K") m = 1; else if (u == "M") m = 1024
      else if (u == "G") m = 1048576; else if (u == "T") m = 1073741824
      else m = 1 / 1024
      t += n * m
    }
  } END { printf "%d\n", t }'
}

# free_kb: free KiB on the root volume.
free_kb() { df -k / | awk 'NR==2 {print $4}'; }

# sum_kb_stdin: total disk usage (KiB) of the paths given on stdin, one per
# line (batched through a single du).
sum_kb_stdin() {
  local paths
  paths="$(grep -v '^$' || true)"
  if [ -z "$paths" ]; then echo 0; return 0; fi
  printf '%s\n' "$paths" | tr '\n' '\0' \
    | { xargs -0 du -sk 2>/dev/null || true; } \
    | awk '{t += $1} END {printf "%d\n", t}'
}

# add_estimate KB: count KB towards the current section's dry-run estimate.
add_estimate() { ESTIMATE_KB=$((ESTIMATE_KB + ${1:-0})); }

# show_size PATH: print human-readable disk usage of PATH (if it exists).
show_size() {
  local path="$1" size
  if [ -e "$path" ]; then
    size="$(du -sh "$path" 2>/dev/null | cut -f1 || true)"
    printf '%s\n' "  ${C_BOLD}${size:-?}${C_RESET}  ${path}"
    log_plain "  ${size:-?}  ${path}"
  else
    printf '%s\n' "  ${C_DIM}(missing)${C_RESET}  ${path}"
    log_plain "  (missing)  ${path}"
  fi
}

# show_kb KB TEXT: print a size line from a KiB total.
show_kb() {
  local h
  h="$(human_kb "$1")"
  printf '%s\n' "  ${C_BOLD}${h}${C_RESET}  $2"
  log_plain "  ${h}  $2"
}

# show_target PATH: print the size of PATH, which is about to be deleted,
# and add it to the dry-run estimate.
show_target() {
  local kb
  kb="$(printf '%s\n' "$1" | sum_kb_stdin)"
  show_kb "$kb" "$1"
  add_estimate "$kb"
}

# show_targets LABEL PATHS: like show_target for newline-separated PATHS,
# printed as one line.
show_targets() {
  local paths="$2" kb n
  kb="$(printf '%s\n' "$paths" | sum_kb_stdin)"
  n="$(printf '%s\n' "$paths" | grep -c . || true)"
  show_kb "$kb" "$1 (${n} files)"
  add_estimate "$kb"
}

# ===========================================================================
# ERROR HANDLING (ERR / INT traps, failure report)
# ===========================================================================

# resolve_path PATH: resolve symlinks (macOS readlink has no -f).
resolve_path() {
  local p="$1" d
  while [ -L "$p" ]; do
    d="$(cd "$(dirname "$p")" && pwd)"
    p="$(readlink "$p")"
    case "$p" in /*) ;; *) p="${d}/${p}" ;; esac
  done
  printf '%s/%s\n' "$(cd "$(dirname "$p")" && pwd)" "$(basename "$p")"
}

# tool_line LABEL BINARY CMD...: one-line version of a tool, tolerating absence.
tool_line() {
  local label="$1" bin="$2" v
  shift 2
  if command -v "$bin" >/dev/null 2>&1; then
    v="$("$@" 2>&1 | head -n 1)"
  else
    v="not installed"
  fi
  printf '  %-8s %s\n' "${label}:" "${v:-unknown}"
}

# likely_cause RC CMD LOG_TAIL: best-effort hint for the failure report.
likely_cause() {
  local rc="$1" cmd="$2" tail_out="$3"
  case "$rc" in
    127) echo "Command not found: a required tool is missing from PATH."; return ;;
    126) echo "Command found but not executable (permission issue)."; return ;;
    130) echo "Interrupted (Ctrl-C)."; return ;;
  esac
  case "$tail_out" in
    *"Cannot connect to the Docker daemon"*|*"docker daemon"*|*"docker.sock"*)
      echo "Docker daemon not reachable (is colima running? check 'colima status' and 'docker context ls')."; return ;;
    *"index.lock"*|*"Another git process"*)
      echo "Another git process is running in the repo (or left a stale .git/index.lock)."; return ;;
    *"unknown flag"*|*"unknown shorthand flag"*)
      echo "The installed tool does not support a flag used here (e.g. 'docker volume prune -a' needs Docker 23+)."; return ;;
    *"Permission denied"*|*"Operation not permitted"*)
      echo "Permission issue: files owned by another user (root/docker) or the terminal lacks macOS Full Disk Access."; return ;;
    *"No space left on device"*)
      echo "Disk is full; free some space manually and re-run."; return ;;
  esac
  case "$cmd" in
    docker\ *) echo "Docker daemon not reachable or docker command failed (is colima running?)." ;;
    colima\ *) echo "Colima VM problem (check 'colima status'; try 'colima stop && colima start')." ;;
    git\ *)    echo "git command failed; check the repo with 'git -C <repo> status' and 'git -C <repo> fsck'." ;;
    *)         echo "See the command output above (and the log tail below)." ;;
  esac
}

# report_failure RC CMD FRAME [LINE] [CAUSE]
# FRAME is the FUNCNAME index (relative to this function) of the function in
# which the failure happened. LINE overrides the line number (ERR trap).
report_failure() {
  local rc="$1" cmd="$2" frame="${3:-2}" line="${4:-}" cause="${5:-}"
  local fn fn_i src i stack="" tail_out="(no log file yet)" script_path report
  if [ "$REPORTED" -eq 1 ]; then return 0; fi
  REPORTED=1
  trap - ERR
  set +eu

  fn="${FUNCNAME[$frame]:-top-level}"
  src="${BASH_SOURCE[$frame]:-$0}"
  [ -n "$line" ] || line="${BASH_LINENO[$((frame - 1))]:-?}"

  # The outermost FUNCNAME entry is bash's script top level (named "main").
  i="$frame"
  while [ "$i" -lt "${#FUNCNAME[@]}" ]; do
    if [ "$i" -eq $((${#FUNCNAME[@]} - 1)) ]; then fn_i="<top-level>"; else fn_i="${FUNCNAME[$i]}"; fi
    stack="${stack}${fn_i}@$(basename "${BASH_SOURCE[$i]:-?}"):${BASH_LINENO[$((i - 1))]:-?} <- "
    i=$((i + 1))
  done
  stack="${stack% <- }"

  if [ -n "$LOG" ] && [ -f "$LOG" ]; then
    tail_out="$(tail -n "$LOG_TAIL_LINES" "$LOG")"
  fi
  [ -n "$cause" ] || cause="$(likely_cause "$rc" "$cmd" "$tail_out")"
  script_path="$(resolve_path "$0" 2>/dev/null)"

  report="$(
    echo "==================== ${SCRIPT_NAME} FAILED ===================="
    echo "What happened: ${CURRENT_SECTION:-<no section>} / ${CURRENT_STEP:-<no step>} failed"
    echo "Command:       ${cmd}"
    echo "Exit code:     ${rc}"
    echo "Location:      ${src}:${line} in ${fn}"
    echo "Call stack:    ${stack:-<none>}"
    echo "Likely cause:  ${cause}"
    echo "--- Debug info for an AI agent ---"
    echo "script:              ${script_path:-$0}"
    echo "invoked as:          $0 ${ORIG_ARGS}"
    echo "dry run:             $([ "$DRY_RUN" -eq 1 ] && echo yes || echo no)"
    echo "date:                $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo "macOS:               $(sw_vers -productVersion 2>/dev/null) ($(sw_vers -buildVersion 2>/dev/null))"
    echo "bash:                ${BASH_VERSION}"
    echo "arch:                $(uname -m)"
    echo "cwd:                 ${START_PWD} (now: ${PWD})"
    echo "sections requested:  ${SELECTED:-<none>}"
    echo "sections completed:  ${COMPLETED:-<none>}"
    echo "log file:            ${LOG:-<none>}"
    echo "disk free:"
    df -h / 2>&1 | sed 's/^/  /'
    echo "tool versions:"
    tool_line docker docker docker --version
    tool_line colima colima colima version
    tool_line git git git --version
    tool_line git-lfs git-lfs git lfs version
    echo "last ${LOG_TAIL_LINES} lines of output (from the log):"
    printf '%s\n' "$tail_out" | sed 's/^/  | /'
    echo "Suggested next step: re-run a single section with \`${SCRIPT_NAME} <section>\`;"
    echo "  paste this block to an AI agent along with the script (${script_path:-$0})."
    echo "================================================================="
  )"
  printf '\n%s\n' "${C_RED}${report}${C_RESET}" >&2
  log_plain "" "$report"
}

# die CMD CAUSE [RC]: halt with the failure report for a failed guard.
die() {
  local cmd="$1" cause="$2" rc="${3:-3}"
  report_failure "$rc" "$cmd" 2 "" "$cause"
  exit "$rc"
}

on_err() {
  local rc="$1" line="$2" cmd="$3"
  # Inside a subshell / command substitution: just propagate the status and
  # let the parent shell (which has the full context) report it.
  if [ "${BASH_SUBSHELL:-0}" -gt 0 ]; then exit "$rc"; fi
  # 141 = 128 + SIGPIPE: a write to our stdout hit a closed pipe (e.g.
  # `--help | head`). The reader just stopped reading; exit with the
  # conventional status and no report.
  if [ "$rc" -eq 141 ]; then exit 141; fi
  report_failure "$rc" "$cmd" 2 "$line"
  exit "$rc"
}

on_int() {
  trap - INT
  report_failure 130 "${CURRENT_CMD:-<between commands>}" 2 "" "Interrupted (Ctrl-C) by the user."
  exit 130
}

# ===========================================================================
# COMMAND EXECUTION (run = mutating, try_run = best-effort, probe = read-only)
# ===========================================================================

# exec_logged CMD...: print the command, execute it with output streamed to
# the terminal and appended to $LOG, and store its exit status in RUN_RC (it
# never fails itself). Use run / try_run / probe, not this directly.
exec_logged() {
  local cmd st="" tee_rc
  RUN_RC=0
  cmd="$(quote_cmd "$@")"
  CURRENT_CMD="$cmd"
  printf '%s\n' "${C_CYAN}\$ ${cmd}${C_RESET}"
  log_plain "\$ ${cmd}"
  "$@" 2>&1 | tee -a "$LOG" || st="${PIPESTATUS[*]}"
  if [ -n "$st" ]; then
    # Same status pipefail gives: tee's if non-zero, else the command's.
    tee_rc="${st##* }"
    if [ "$tee_rc" -ne 0 ]; then RUN_RC="$tee_rc"; else RUN_RC="${st%% *}"; fi
    # tee killed by SIGPIPE: our stdout reader went away (e.g. `| head`).
    # That is not a cleanup failure; stop quietly.
    if [ "$tee_rc" -eq 141 ]; then exit 141; fi
  fi
}

# skip_dry_run CMD...: in dry-run, print the command as skipped and return 0;
# otherwise return 1 (the caller executes it).
skip_dry_run() {
  local cmd
  is_dry_run || return 1
  cmd="$(quote_cmd "$@")"
  printf '%s\n' "${C_YELLOW}[dry-run] \$ ${cmd}${C_RESET}"
  log_plain "[dry-run] \$ ${cmd}"
}

# probe CMD...: read-only command; always runs, halts on failure.
probe() {
  exec_logged "$@"
  if [ "$RUN_RC" -ne 0 ]; then
    report_failure "$RUN_RC" "$CURRENT_CMD" 2
    exit "$RUN_RC"
  fi
  CURRENT_CMD=""
}

# run CMD...: mutating command; halts on failure. Skipped in dry-run.
run() {
  if skip_dry_run "$@"; then return 0; fi
  exec_logged "$@"
  if [ "$RUN_RC" -ne 0 ]; then
    report_failure "$RUN_RC" "$CURRENT_CMD" 2
    exit "$RUN_RC"
  fi
  CURRENT_CMD=""
}

# try_run CMD...: like run, but a failure only prints a warning. Reserve it
# for best-effort steps whose failure is expected and harmless (e.g.
# macOS-protected cache files that rm may not delete).
try_run() {
  if skip_dry_run "$@"; then return 0; fi
  exec_logged "$@"
  if [ "$RUN_RC" -ne 0 ]; then
    warn "Best-effort step failed (exit ${RUN_RC}), continuing: ${CURRENT_CMD}"
  fi
  CURRENT_CMD=""
}

# ===========================================================================
# GUARDS
# ===========================================================================

# guard_path PATH: halt if PATH is empty, "/" or $HOME (never rm those).
guard_path() {
  case "${1:-}" in
    ""|/|"$HOME"|"${HOME}/")
      die "guard_path '${1:-}'" "Refusing to delete an empty path, '/' or \$HOME: a path variable in the script is wrong." 4 ;;
  esac
}

# require_cmd NAME: return 1 with a note if NAME is not installed.
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    note "'$1' not found; skipping steps that need it."
    return 1
  fi
}

# dir_has_entries DIR: true if DIR exists and is not empty.
dir_has_entries() {
  [ -d "$1" ] && [ -n "$(find "$1" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null || true)" ]
}

# app_running NAME: return 0 if a process whose name is exactly NAME runs.
# `pgrep -x` matches the process name, so helpers ("Google Chrome Helper",
# crash handlers, plugin hosts) never match the main app's name.
app_running() {
  pgrep -x "$1" >/dev/null 2>&1
}

# git_repo_busy REPO: return 0 (busy) and print why if a git operation may be
# running against REPO; return 1 when it looks idle.
git_repo_busy() {
  local repo="$1" gitdir procs pid
  gitdir="${repo}/.git"
  if [ -e "${gitdir}/index.lock" ]; then
    warn "${gitdir}/index.lock exists: a git command is running (or crashed and left a stale lock)."
    return 0
  fi
  if [ -f "${gitdir}/gc.pid" ]; then
    pid="$(awk '{print $1; exit}' "${gitdir}/gc.pid" 2>/dev/null || true)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      warn "git gc is running (pid ${pid}, from ${gitdir}/gc.pid)."
      return 0
    fi
  fi
  procs="$(pgrep -fl git 2>/dev/null | grep -F -- "$repo" || true)"
  if [ -n "$procs" ]; then
    warn "git processes referencing ${repo}:"
    printf '%s\n' "$procs" >&2
    log_plain "$procs"
    return 0
  fi
  if command -v lsof >/dev/null 2>&1; then
    procs="$(lsof -a -c git -d cwd -F pcn 2>/dev/null | awk -v r="$repo" '
      /^p/ {pid = substr($0, 2)} /^c/ {cmd = substr($0, 2)}
      /^n/ {p = substr($0, 2); if (p == r || index(p, r "/") == 1) print pid, cmd, p}' || true)"
    if [ -n "$procs" ]; then
      warn "git processes with working directory inside ${repo}:"
      printf '%s\n' "$procs" >&2
      log_plain "$procs"
      return 0
    fi
  fi
  return 1
}

# require_git_idle REPO: halt with the failure report if git is busy on REPO.
# In dry-run only warn that the real run would halt, and continue.
require_git_idle() {
  local repo="$1"
  CURRENT_STEP="Check that no git process is active in ${repo}"
  git_repo_busy "$repo" || return 0
  if is_dry_run; then
    warn "[dry-run] A real run would HALT here: git is busy on ${repo}."
    return 0
  fi
  die "git_repo_busy $(quote_cmd "$repo")" \
    "Another git process is running in the repo (or left a stale .git/index.lock or gc.pid). Wait for it to finish, or remove the stale lock if no git process exists, then re-run."
}

# ===========================================================================
# GENERIC CLEANERS
# ===========================================================================

# --- Files and directories ---------------------------------------------------

# clean_contents BASE REL LABEL [best-effort]: delete the contents of
# BASE/REL (the directory itself is kept). Silent if it is missing or empty.
# With "best-effort", a failed rm warns (try_run) instead of halting.
clean_contents() {
  local base="$1" rel="$2" label="$3" mode="${4:-}" dir runner=run
  dir="${base}/${rel}"
  dir_has_entries "$dir" || return 0
  if [ "$mode" = "best-effort" ]; then runner=try_run; fi
  step "Delete the contents of ${rel} (${label})"
  guard_path "$base"
  guard_path "$rel"
  show_target "$dir"
  "$runner" find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
}

# remove_dir BASE REL LABEL: delete BASE/REL. Silent if it is missing;
# symlinks are left alone.
remove_dir() {
  local base="$1" rel="$2" label="$3" dir
  dir="${base}/${rel}"
  [ -d "$dir" ] && [ ! -L "$dir" ] || return 0
  step "Delete ${rel} (${label})"
  guard_path "$base"
  guard_path "$rel"
  show_target "$dir"
  run rm -rf "$dir"
}

# delete_files DIR PATTERN LABEL: list, then delete the regular files
# DIR/PATTERN (not recursive). Silent if there are none.
delete_files() {
  local dir="$1" pattern="$2" label="$3" files
  files="$(find "$dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null || true)"
  [ -n "$files" ] || return 0
  step "Delete ${pattern} (${label})"
  probe find "$dir" -maxdepth 1 -type f -name "$pattern" -exec ls -lh {} +
  show_targets "${dir}/${pattern}" "$files"
  run find "$dir" -maxdepth 1 -type f -name "$pattern" -delete
}

# --- Rails repos -------------------------------------------------------------

# begin_repo REPO: return 1 (section skipped) if REPO is missing, else print
# its size.
begin_repo() {
  local repo="$1"
  if [ ! -d "$repo" ]; then
    note "Repository ${repo} not found; skipping section."
    return 1
  fi
  step "Measure repository size before cleanup"
  show_size "$repo"
}

end_repo() {
  step "Measure repository size after cleanup"
  show_size "$1"
}

# truncate_logs REPO: empty REPO/log/*.log. Truncate rather than delete: a
# running server keeps deleted files open, so their space would not be freed
# until it exits. Falls back to deleting them if `truncate` is missing.
truncate_logs() {
  local repo="$1" logs
  [ -d "${repo}/log" ] || return 0
  logs="$(find "${repo}/log" -maxdepth 1 -type f -name '*.log')"
  [ -n "$logs" ] || return 0
  if command -v truncate >/dev/null 2>&1; then
    step "Truncate log/*.log to zero bytes"
    show_targets "${repo}/log/*.log" "$logs"
    run find "${repo}/log" -maxdepth 1 -type f -name '*.log' -exec truncate -s 0 {} +
  else
    step "Delete log/*.log (Rails recreates them)"
    show_targets "${repo}/log/*.log" "$logs"
    run find "${repo}/log" -maxdepth 1 -type f -name '*.log' -delete
  fi
}

# clean_rails_tmp REPO: tmp/storage, tmp/cache, tmp/capybara and log/*.log.
# Plain file removal; does not invoke rails (it may not boot outside docker).
clean_rails_tmp() {
  local repo="$1"
  clean_contents "$repo" "tmp/storage" "ActiveStorage dev/test files, regenerated by specs"
  clean_contents "$repo" "tmp/cache" "Rails/bootsnap/asset cache"
  clean_contents "$repo" "tmp/capybara" "Capybara screenshots and saved pages"
  truncate_logs "$repo"
}

# prune_graphify_snapshots REPO: in graphify-out/, delete dated snapshot
# directories (YYYY-MM-DD) except the newest, then delete cache/ (its
# regeneration costs API tokens). graph.json and non-dated files are kept.
prune_graphify_snapshots() {
  local repo="$1" g p newest old count
  g="${repo}/graphify-out"
  p="$GRAPHIFY_SNAPSHOT_PATTERN"
  [ -d "$g" ] || return 0

  newest="$(find "$g" -mindepth 1 -maxdepth 1 -type d -name "$p" -exec basename {} \; | sort | tail -n 1)"
  if [ -n "$newest" ]; then
    old="$(find "$g" -mindepth 1 -maxdepth 1 -type d -name "$p" ! -name "$newest")"
    count="$(printf '%s\n' "$old" | grep -c . || true)"
    if [ "$count" -gt 0 ]; then
      step "Delete ${count} old graphify-out snapshot dirs (keep ${newest}, graph.json)"
      show_targets "${g}: old dated snapshots" "$old"
      run find "$g" -mindepth 1 -maxdepth 1 -type d -name "$p" ! -name "$newest" -exec rm -rf {} +
    fi
  fi

  if [ -d "${g}/cache" ]; then
    step "Delete graphify-out/cache (regenerating it costs API tokens)"
    guard_path "$g"
    show_target "${g}/cache"
    run rm -rf "${g}/cache"
  fi
}

# remove_core_dump REPO: delete REPO/core only if it is a regular file that
# `file` identifies as an ELF core dump.
remove_core_dump() {
  local repo="$1" core desc
  core="${repo}/core"
  [ -f "$core" ] && [ ! -L "$core" ] || return 0
  step "Inspect ${core}"
  probe ls -lh "$core"
  desc="$(file -b "$core" 2>/dev/null || true)"
  note "file: ${desc}"
  case "$desc" in
    *ELF*core*|*[Cc]ore\ file*) ;;
    *) note "${core} is not reported as a core dump; leaving it."; return 0 ;;
  esac
  step "Delete core dump ${core}"
  show_target "$core"
  run rm -f "$core"
}

# clean_node_modules REPO REL...: delete each node_modules dir.
clean_node_modules() {
  local repo="$1" rel
  shift
  for rel in "$@"; do
    remove_dir "$repo" "$rel" "regenerable with 'yarn install'"
  done
}

# --- git ---------------------------------------------------------------------

# has_git_repo REPO: true if REPO has a .git dir and git is installed.
has_git_repo() {
  [ -d "${1}/.git" ] || return 1
  require_cmd git
}

# prune_git_loose REPO: remove unreachable loose objects immediately (plain
# `git prune` keeps objects younger than 2 weeks, so --expire=now is needed
# for recently written garbage), then `git gc --prune=now`.
prune_git_loose() {
  local repo="$1" objs out n kb
  objs="${repo}/.git/objects"
  has_git_repo "$repo" || return 0
  require_git_idle "$repo"

  step "Count unreachable loose git objects"
  show_size "$objs"
  out="$(git -C "$repo" prune --dry-run --expire=now -v 2>/dev/null || true)"
  n="$(printf '%s\n' "$out" | grep -c . || true)"
  note "${n:-?} unreachable loose objects."
  if [ "$n" != "0" ]; then
    step "Prune unreachable loose objects (git prune --expire=now)"
    # Each output line is "<sha> <type>"; the object file is objects/xx/yyyy.
    kb="$(printf '%s\n' "$out" | awk -v o="$objs" 'NF {print o "/" substr($1, 1, 2) "/" substr($1, 3)}' | sum_kb_stdin)"
    show_kb "$kb" "${objs}: ${n} unreachable loose objects"
    add_estimate "$kb"
    run git -C "$repo" prune --expire=now -v
  fi

  step "Repack and drop unreachable objects (git gc --prune=now, slow)"
  if is_dry_run; then note "git gc savings are not included in the estimate."; fi
  run git -C "$repo" gc --prune=now
}

# clean_git_tmp_objects REPO: leftovers of aborted object writes. Only files
# older than GIT_TMP_OBJ_MIN_AGE_MIN are removed so an in-flight write is
# never touched. They live in .git/objects/??/tmp_obj_* or at the top.
clean_git_tmp_objects() {
  local repo="$1" objs age files
  objs="${repo}/.git/objects"
  age="+${GIT_TMP_OBJ_MIN_AGE_MIN}"
  [ -d "$objs" ] || return 0
  files="$(find "$objs" -mindepth 1 -maxdepth 2 -type f -name 'tmp_obj_*' -mmin "$age")"
  [ -n "$files" ] || return 0
  require_git_idle "$repo"
  step "Delete stale .git/objects/tmp_obj_* files (aborted writes, older than ${GIT_TMP_OBJ_MIN_AGE_MIN} min)"
  show_targets "${objs}/tmp_obj_*" "$files"
  run find "$objs" -mindepth 1 -maxdepth 2 -type f -name 'tmp_obj_*' -mmin "$age" -delete
}

# show_git_stats REPO: object stats and stash count (stashes never touched).
show_git_stats() {
  local repo="$1" stashes
  has_git_repo "$repo" || return 0
  step "Show git object stats"
  probe git -C "$repo" count-objects -vH
  stashes="$(git -C "$repo" stash list 2>/dev/null | wc -l | tr -d ' ' || true)"
  note "${stashes:-?} stash entries (not touched; review with 'git -C ${repo} stash list')."
}

# prune_git_worktrees REPO: `git worktree prune`, which only drops entries
# whose directory no longer exists.
prune_git_worktrees() {
  local repo="$1" out
  has_git_repo "$repo" || return 0
  step "Check for stale worktree entries"
  out="$(git -C "$repo" worktree prune --dry-run -v 2>&1 || true)"
  if [ -z "$out" ]; then
    note "No prunable worktree entries."
    return 0
  fi
  printf '%s\n' "$out"
  log_plain "$out"
  require_git_idle "$repo"
  step "Prune stale worktree entries"
  run git -C "$repo" worktree prune -v
}

# --- Docker / Colima ---------------------------------------------------------

# colima_running: true if colima and docker are installed and Colima runs.
colima_running() {
  require_cmd colima || return 1
  require_cmd docker || return 1
  if ! colima status >/dev/null 2>&1; then
    note "Colima is not running; skipping Docker steps (start it with 'colima start')."
    return 1
  fi
}

# estimate_docker_reclaimable: dry-run only; add the "reclaimable" sizes of
# `docker system df` (containers, images, volumes, build cache).
estimate_docker_reclaimable() {
  local sizes kb
  is_dry_run || return 0
  sizes="$(docker system df --format '{{.Reclaimable}}' 2>/dev/null | awk '{print $1}' || true)"
  kb="$(kb_from_human "$sizes")"
  show_kb "$kb" "Docker reclaimable (docker system df)"
  add_estimate "$kb"
}

# prune_docker: prune everything no container uses, then fstrim the VM disk.
prune_docker() {
  step "Show Docker disk usage"
  probe docker system df
  estimate_docker_reclaimable

  step "Remove all stopped containers"
  run docker container prune -f

  step "Remove dangling images"
  run docker image prune -f

  step "Remove ALL images not used by a container (they must be re-pulled/rebuilt)"
  run docker image prune -a -f

  step "List dangling volumes"
  probe docker volume ls -f dangling=true

  step "Remove unused anonymous volumes"
  run docker volume prune -f

  step "Remove ALL unused volumes, including named ones (their data is deleted permanently)"
  run docker volume prune -a -f

  step "Remove Docker build cache"
  run docker builder prune -f

  step "fstrim the Colima VM disk so freed blocks return to macOS"
  run colima ssh -- sudo fstrim -av
}

# --- App caches --------------------------------------------------------------

# clean_app_caches NAME PROCESS BASE LABEL REL...: delete the contents of
# each existing BASE/REL unless the app (process name PROCESS) is running,
# in which case one warning is printed and all of them are skipped (not a
# failure). Only pass well-known cache folder names: app profile dirs also
# hold real state (logins, settings) that must not be touched.
clean_app_caches() {
  local name="$1" proc="$2" base="$3" label="$4" rel found=""
  shift 4
  for rel in "$@"; do
    if [ -d "${base}/${rel}" ]; then found="${found}${base}/${rel}"$'\n'; fi
  done
  if [ -z "$found" ]; then
    note "No ${name} caches found in ${base}."
    return 0
  fi
  if app_running "$proc"; then
    warn "${name} caches skipped: quit ${proc} first to free $(human_kb "$(printf '%s' "$found" | sum_kb_stdin)") (${base}: $*)."
    return 0
  fi
  for rel in "$@"; do
    clean_contents "$base" "$rel" "$label"
  done
}

# chrome_cache_rels ROOT: print, one per line and relative to ROOT, every
# existing Chrome cache dir: root caches, then per-profile caches.
chrome_cache_rels() {
  local root="$1" p sub
  [ -d "$root" ] || return 0
  for sub in "${CHROME_ROOT_CACHES[@]}"; do
    if [ -d "${root}/${sub}" ]; then printf '%s\n' "$sub"; fi
  done
  for p in "$root"/*/; do
    p="$(basename "$p")"
    for sub in "${CHROME_PROFILE_CACHES[@]}"; do
      if [ -d "${root}/${p}/${sub}" ]; then printf '%s\n' "${p}/${sub}"; fi
    done
  done
}

# clean_chrome_profiles: Chromium caches in every Chrome profile dir plus the
# root GPU caches (see CHROME_*_CACHES). Skipped as a whole while Chrome runs.
clean_chrome_profiles() {
  local rels=() rel
  while IFS= read -r rel; do
    if [ -n "$rel" ]; then rels+=("$rel"); fi
  done <<EOF_RELS
$(chrome_cache_rels "$CHROME_USER_DATA")
EOF_RELS
  [ "${#rels[@]}" -gt 0 ] || return 0
  clean_app_caches "Chrome profile" "$CHROME_PROCESS" "$CHROME_USER_DATA" \
    "Chromium cache, Chrome rebuilds it" "${rels[@]}"
}

# clean_brew: `brew cleanup -s --prune=all`; in dry-run `brew cleanup -n`
# (read-only) shows what it would remove and feeds the estimate.
clean_brew() {
  local line
  require_cmd brew || return 0
  step "Remove old Homebrew downloads and versions (brew cleanup -s --prune=all)"
  show_size "$BREW_CACHE_DIR"
  if ! is_dry_run; then
    run brew cleanup -s --prune=all
    return 0
  fi
  probe brew cleanup -n -s --prune=all
  line="$(grep 'would free approximately' "$LOG" | tail -n 1 || true)"
  line="$(printf '%s' "$line" | sed -n 's/.*approximately \([0-9.]*[KMGT]*B\).*/\1/p')"
  add_estimate "$(kb_from_human "${line:-0B}")"
}

# ===========================================================================
# SECTIONS (one cleanup_<name> function each; see the registry below)
# ===========================================================================
cleanup_colima() {
  step "Inspect current Colima usage"
  show_size "$COLIMA_DIR"
  show_size "$COLIMA_CACHE_DIR"

  if colima_running; then prune_docker; fi

  if dir_has_entries "$COLIMA_CACHE_DIR"; then
    clean_contents "$(dirname "$COLIMA_CACHE_DIR")" "$(basename "$COLIMA_CACHE_DIR")" \
      "downloaded VM images"
  else
    note "No Colima cache to clear at ${COLIMA_CACHE_DIR}."
  fi

  step "Report Colima usage after cleanup"
  show_size "$COLIMA_DIR"
  show_size "$COLIMA_CACHE_DIR"
  note "If ~/.colima did not shrink, last resort (destroys the VM and ALL its Docker data):"
  note "  colima delete && colima start --disk 60"
}

cleanup_bergamotte() {
  local repo="$BERGAMOTTE_REPO"
  begin_repo "$repo" || return 0
  show_size "${repo}/.git"

  clean_rails_tmp "$repo"
  prune_graphify_snapshots "$repo"
  remove_core_dump "$repo"
  prune_git_loose "$repo"
  clean_git_tmp_objects "$repo"
  show_git_stats "$repo"
  prune_git_worktrees "$repo"
  clean_node_modules "$repo" "${BERGAMOTTE_NODE_MODULES[@]}"
  remove_dir "$repo" "$BERGAMOTTE_ASSET_BUILDS" "regenerated by bin/assets-build"

  show_size "${repo}/.git"
  end_repo "$repo"
}

cleanup_bloomandwild() {
  local repo="$BLOOMANDWILD_REPO" state
  begin_repo "$repo" || return 0

  clean_rails_tmp "$repo"
  prune_graphify_snapshots "$repo"
  delete_files "${repo}/tmp" "$BLOOMANDWILD_DB_DUMPS" "downloaded staging DB dumps"

  if [ -d "${repo}/vendor/bundle" ]; then
    note "vendor/bundle holds linux-aarch64 gems used by the docker setup; restore with 'bundle install' (in docker)."
    remove_dir "$repo" "vendor/bundle" "installed gems"
  fi

  show_git_stats "$repo"
  prune_git_worktrees "$repo"

  state="${repo}/${BLOOMANDWILD_DOCKERDEV_STATE}"
  if [ -d "$state" ]; then
    note "Not touching ${BLOOMANDWILD_DOCKERDEV_STATE} ($(du -sh "$state" 2>/dev/null | cut -f1 || true)): live local Postgres data."
  fi
  if [ -f "${repo}/${BLOOMANDWILD_DOCKERDEV_DUMP}" ]; then
    note "Not touching ${BLOOMANDWILD_DOCKERDEV_DUMP}: used by docker init."
  fi
  end_repo "$repo"
}

cleanup_caches() {
  local rel

  step "Measure ~/Library/Caches before cleanup"
  show_size "$CACHES_DIR"

  clean_app_caches "Google Chrome" "$CHROME_PROCESS" \
    "$(dirname "$CHROME_CACHE_DIR")" \
    "per-profile HTTP, code and GPU caches; Chrome rebuilds them" \
    "$(basename "$CHROME_CACHE_DIR")"
  clean_chrome_profiles
  clean_app_caches "Discord" "$DISCORD_PROCESS" "$DISCORD_DIR" \
    "Chromium cache, Discord rebuilds it" "${DISCORD_CACHES[@]}"

  clean_contents "$AERIALS_DIR" "videos" \
    "downloaded aerial wallpaper videos, re-downloaded on demand"

  # Some files can be protected by macOS (TCC / SIP) and make rm fail with
  # "Operation not permitted"; that must not stop the run.
  for rel in "${APPLE_BEST_EFFORT_CACHES[@]}"; do
    clean_contents "$CACHES_DIR" "$rel" "Apple cache, macOS rebuilds it" best-effort
  done

  clean_brew

  note "Spotify cache is not touched (it holds offline downloads); clear it in Spotify > Settings > Storage > Clear cache."

  step "Measure ~/Library/Caches after cleanup"
  show_size "$CACHES_DIR"
}

# ===========================================================================
# SECTION REGISTRY: one "name|description" per line. Order = execution order.
# ===========================================================================
SECTIONS="
colima|Docker/Colima: prune containers, images, volumes, build cache; fstrim the VM disk; clear Colima cache
bergamotte|Rails repo ~/dev/bergamotte/bergamotte: tmp, logs, graphify snapshots, core dump, loose git objects, node_modules
bloomandwild|Rails repo ~/dev/bloomandwild/bloomandwild: tmp/storage, logs, graphify snapshots, DB dumps, vendor/bundle
caches|App/OS caches: Chrome cache + profile caches (Service Worker, GPU/Dawn), Discord, aerial wallpaper videos, GeoServices/helpd/CloudTelemetry, Homebrew (apps running are skipped)
"

section_names() {
  printf '%s\n' "$SECTIONS" | awk -F'|' 'NF {print $1}'
}

section_exists() {
  case " $(section_names | tr '\n' ' ') " in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

list_sections() {
  echo "Available sections:"
  printf '%s\n' "$SECTIONS" | awk -F'|' 'NF {printf "  %-13s %s\n", $1, $2}'
}

# ===========================================================================
# CLI PARSING AND MAIN
# ===========================================================================

# usage: print the USER GUIDE block from the header comment of this file
# (single source of truth for --help), then the section list.
usage() {
  local src
  src="$(resolve_path "$0" 2>/dev/null || true)"
  if [ -n "$src" ] && [ -r "$src" ]; then
    awk '/^# END USER GUIDE/ {exit} f {sub(/^# ?/, ""); print}
      /^# BEGIN USER GUIDE/ {f = 1}' "$src"
  else
    echo "Usage: ${SCRIPT_NAME} [-n|--dry-run] [-l|--list] [-h|--help] [section ...]"
    echo "(full guide: the header comment of ${SCRIPT_NAME})"
  fi
  echo
  list_sections
}

# parse_args ARGS...: set DRY_RUN and SELECTED (validated, in order).
parse_args() {
  local selected="" name
  while [ $# -gt 0 ]; do
    case "$1" in
      -n|--dry-run) DRY_RUN=1 ;;
      -l|--list)    list_sections; exit 0 ;;
      -h|--help)    usage; exit 0 ;;
      --)           shift; selected="$selected $*"; break ;;
      -*)           printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
      *)            selected="$selected $1" ;;
    esac
    shift
  done

  if [ -z "${selected// /}" ]; then
    selected="$(section_names | tr '\n' ' ')"
  fi
  for name in $selected; do
    if ! section_exists "$name"; then
      printf 'Unknown section: %s\n\n' "$name" >&2
      usage >&2
      exit 2
    fi
  done
  SELECTED="$(printf '%s\n' "$selected" | xargs)"
}

init_log() {
  local tmpdir="${TMPDIR:-/tmp}"
  tmpdir="${tmpdir%/}"
  LOG="${tmpdir}/macos_cleanup.$(date +%Y%m%d-%H%M%S).$$.log"
  : >"$LOG"
}

main() {
  local name before after s_before summary="" total_est=0

  ORIG_ARGS="$(quote_cmd "$@")"
  parse_args "$@"
  init_log

  if is_dry_run; then
    printf '%s\n' "${C_BOLD}${C_YELLOW}DRY RUN — nothing will be deleted${C_RESET}"
    log_plain "DRY RUN — nothing will be deleted"
  fi
  info "Running sections: ${SELECTED}"
  info "Log file: ${LOG}"

  before="$(free_kb)"
  for name in $SELECTED; do
    CURRENT_SECTION="$name"
    CURRENT_STEP="(section start)"
    ESTIMATE_KB=0
    header "$name"
    s_before="$(free_kb)"
    "cleanup_${name}"
    if is_dry_run; then
      summary="${summary}$(printf '  %-13s %s' "${name}:" "$(human_kb "$ESTIMATE_KB")")"$'\n'
      total_est=$((total_est + ESTIMATE_KB))
    else
      summary="${summary}$(printf '  %-13s %s' "${name}:" "$(human_kb $(($(free_kb) - s_before)))")"$'\n'
    fi
    COMPLETED="${COMPLETED:+${COMPLETED} }${name}"
  done

  CURRENT_SECTION="summary"
  CURRENT_STEP="print summary"
  after="$(free_kb)"
  header "Summary"
  {
    if is_dry_run; then
      printf '  DRY RUN: nothing was deleted.\n'
      printf '  Free space on / now:    %s\n' "$(human_kb "$after")"
      printf '  Would free (estimate):  %s\n' "$(human_kb "$total_est")"
      printf '  Estimate per section (du of targets + docker/brew/git reclaimable;\n'
      printf '  excludes git gc repacking and fstrim; apps running are skipped):\n'
    else
      printf '  Free space on / before: %s\n' "$(human_kb "$before")"
      printf '  Free space on / after:  %s\n' "$(human_kb "$after")"
      printf '  Freed (total):          %s\n' "$(human_kb $((after - before)))"
      printf '  Freed per section (free-space delta on /):\n'
    fi
    printf '%s' "$summary"
    printf '  Log file: %s\n' "$LOG"
  } | tee -a "$LOG"
  return 0
}

trap 'on_err "$?" "$LINENO" "$BASH_COMMAND"' ERR
trap on_int INT

main "$@"

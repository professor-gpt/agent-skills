#!/usr/bin/env bash
# =============================================================================
# memory-profile.sh
# Profile memory usage of a Node.js process or Python script.
# Helps diagnose memory leaks and high memory consumption.
#
# Usage:
#   ./memory-profile.sh node src/server.js          # Profile Node.js process
#   ./memory-profile.sh python src/worker.py        # Profile Python process
#   ./memory-profile.sh --pid 12345                 # Attach to running process
#   ./memory-profile.sh --pid 12345 --interval 5    # Sample every 5 seconds
# =============================================================================

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
INTERVAL=2          # Seconds between samples
DURATION=60         # Total profiling duration in seconds
OUTPUT_DIR="./memory-profiles/$(date +%Y%m%d-%H%M%S)"
TARGET_PID=""
COMMAND=""
THRESHOLD_MB=500    # Alert if heap exceeds this

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pid)       TARGET_PID="$2"; shift 2 ;;
    --interval)  INTERVAL="$2"; shift 2 ;;
    --duration)  DURATION="$2"; shift 2 ;;
    --output)    OUTPUT_DIR="$2"; shift 2 ;;
    --threshold) THRESHOLD_MB="$2"; shift 2 ;;
    *)           COMMAND="$*"; break ;;
  esac
done

mkdir -p "$OUTPUT_DIR"
LOG_FILE="$OUTPUT_DIR/memory.csv"
REPORT_FILE="$OUTPUT_DIR/report.txt"

echo "timestamp_unix,rss_mb,heap_used_mb,heap_total_mb,external_mb" > "$LOG_FILE"

# ── OS detection ──────────────────────────────────────────────────────────────
OS="$(uname -s)"

get_memory_linux() {
  local pid="$1"
  # /proc/PID/status has VmRSS (resident set size)
  if [[ -f "/proc/$pid/status" ]]; then
    local rss_kb
    rss_kb=$(grep VmRSS "/proc/$pid/status" 2>/dev/null | awk '{print $2}')
    echo $((rss_kb / 1024))
  else
    echo "0"
  fi
}

get_memory_mac() {
  local pid="$1"
  # ps -o rss on macOS returns KB
  local rss_kb
  rss_kb=$(ps -o rss= -p "$pid" 2>/dev/null || echo "0")
  echo $((rss_kb / 1024))
}

get_memory_mb() {
  local pid="$1"
  case "$OS" in
    Linux)  get_memory_linux "$pid" ;;
    Darwin) get_memory_mac "$pid" ;;
    *)      echo "0" ;;
  esac
}

# ── Start process if not attaching ───────────────────────────────────────────
if [[ -n "$COMMAND" ]]; then
  echo "Starting: $COMMAND"
  $COMMAND &
  TARGET_PID=$!
  echo "PID: $TARGET_PID"
  sleep 1
fi

if [[ -z "$TARGET_PID" ]]; then
  echo "Error: Provide a command or --pid"
  exit 1
fi

echo ""
echo "============================================================"
echo "  Memory Profile"
echo "  PID: $TARGET_PID"
echo "  Interval: ${INTERVAL}s, Duration: ${DURATION}s"
echo "  Output: $OUTPUT_DIR"
echo "  Threshold: ${THRESHOLD_MB}MB"
echo "============================================================"
echo ""
printf "%-12s %-10s %-12s\n" "Time(s)" "RSS(MB)" "Status"
printf "%-12s %-10s %-12s\n" "-------" "-------" "------"

# ── Sampling loop ─────────────────────────────────────────────────────────────
START_TIME=$(date +%s)
SAMPLES=0
MAX_RSS=0
MIN_RSS=99999
ALERTS=0

while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))

  # Check if process is still running
  if ! kill -0 "$TARGET_PID" 2>/dev/null; then
    echo ""
    echo "Process $TARGET_PID has exited."
    break
  fi

  # Check duration
  if [[ $ELAPSED -ge $DURATION ]]; then
    echo ""
    echo "Duration reached (${DURATION}s)."
    break
  fi

  # Get memory
  RSS_MB=$(get_memory_mb "$TARGET_PID")
  TIMESTAMP=$(date +%s)

  # Track min/max
  [[ $RSS_MB -gt $MAX_RSS ]] && MAX_RSS=$RSS_MB
  [[ $RSS_MB -lt $MIN_RSS ]] && MIN_RSS=$RSS_MB

  # Alert threshold
  STATUS="OK"
  if [[ $RSS_MB -gt $THRESHOLD_MB ]]; then
    STATUS="⚠ HIGH"
    ALERTS=$((ALERTS+1))
  fi

  # Log to CSV
  echo "${TIMESTAMP},${RSS_MB},,,," >> "$LOG_FILE"
  SAMPLES=$((SAMPLES+1))

  # Print progress
  printf "%-12s %-10s %-12s\n" "${ELAPSED}s" "${RSS_MB}MB" "$STATUS"

  sleep "$INTERVAL"
done

# ── Generate report ───────────────────────────────────────────────────────────
DURATION_ACTUAL=$(($(date +%s) - START_TIME))

{
  echo "Memory Profile Report"
  echo "====================="
  echo "PID:              $TARGET_PID"
  echo "Duration:         ${DURATION_ACTUAL}s"
  echo "Samples:          $SAMPLES"
  echo "Sample interval:  ${INTERVAL}s"
  echo ""
  echo "Memory Summary"
  echo "--------------"
  echo "Min RSS:          ${MIN_RSS}MB"
  echo "Max RSS:          ${MAX_RSS}MB"
  echo "Growth:           $((MAX_RSS - MIN_RSS))MB"
  echo "Alerts (>${THRESHOLD_MB}MB): $ALERTS"
  echo ""
  if [[ $((MAX_RSS - MIN_RSS)) -gt 100 ]]; then
    echo "⚠  WARNING: Memory grew by $((MAX_RSS - MIN_RSS))MB — possible leak"
    echo ""
    echo "Next Steps for Node.js:"
    echo "  1. node --inspect src/app.js"
    echo "  2. Open chrome://inspect"
    echo "  3. Take heap snapshot at start and after 10 minutes"
    echo "  4. Compare snapshots: look for growing Constructor counts"
    echo ""
    echo "Next Steps for Python:"
    echo "  1. pip install memray"
    echo "  2. python -m memray run src/worker.py"
    echo "  3. python -m memray flamegraph memray-output.bin"
  else
    echo "✅ Memory appears stable (growth < 100MB)"
  fi
  echo ""
  echo "Raw data: $LOG_FILE"
} | tee "$REPORT_FILE"

echo ""
echo "Report saved: $REPORT_FILE"

# ── Node.js heap snapshot helper ──────────────────────────────────────────────
node_heap_snapshot() {
  local pid="$1"
  local output="$OUTPUT_DIR/heap-$(date +%H%M%S).heapsnapshot"
  echo "Taking heap snapshot for PID $pid..."
  # Requires process started with --inspect
  # This sends USR2 signal which triggers a heapdump if node-heapdump is installed
  kill -USR2 "$pid" 2>/dev/null && echo "Snapshot triggered (check process output)" \
    || echo "Note: install 'node-heapdump' and restart with --inspect for heap snapshots"
}

# Uncomment to take a heap snapshot at end of profiling:
# node_heap_snapshot "$TARGET_PID"

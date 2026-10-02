#!/usr/bin/env bash
# Live terminal view of train_chat.py (macOS). Run: bash watch_training.sh [log]   Quit: Ctrl-C
LOG=${1:-models/train.log}

bar() { awk -v p="$1" 'BEGIN { n = int(p / 5 + 0.5); s = ""; for (i = 0; i < 20; i++) s = s (i < n ? "█" : "░"); printf "%s %3d%%", s, p }'; }

spark() {  # values on stdin -> ▁▂▃▄▅▆▇█ line plus first/last/min
  awk '{ v[NR] = $1; if (NR == 1 || $1 < lo) lo = $1; if (NR == 1 || $1 > hi) hi = $1 }
    END { if (!NR) { print "  (none yet)"; exit }
      split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", c, " "); s = ""
      for (i = (NR > 60 ? NR - 59 : 1); i <= NR; i++) s = s c[hi > lo ? int((v[i] - lo) / (hi - lo) * 7) + 1 : 4]
      printf "  %s\n  first %.3f  last %.3f  min %.3f  (%d points)\n", s, v[1], v[NR], lo, NR }'
}

while true; do
  out=$(tr '\r' '\n' < "$LOG" 2>/dev/null)
  gpu=$(ioreg -r -d 1 -c IOAccelerator | grep -o '"Device Utilization %"=[0-9]*' | head -1 | cut -d= -f2)
  mem=$(top -l 1 -n 0 | grep PhysMem | sed 's/PhysMem: //')
  swap=$(sysctl -n vm.swapusage | awk '{print $6 " of " $3}')
  free=$(memory_pressure | awk -F': ' '/free percentage/ {print $2}')

  clear
  echo "MindMender training    $(date +%H:%M:%S)    log: $LOG"
  pgrep -f "train_chat.py" >/dev/null && echo "status: RUNNING" || echo "status: STOPPED"
  echo "$out" | grep -m1 '^device:'
  echo
  echo "Progress"
  steps=$(echo "$out" | grep -E '\| *[0-9]+/[0-9]+ \[' | grep -v '\[A')
  echo "$steps" | tail -1 | sed 's/^/  /'
  # Real speed from the last 10 steps (tqdm's own ETA is wrong after --resume).
  read -r rate eta < <(echo "$steps" | awk -F'[][/<|]' '{ n_t = split($5, t, ":"); e = 0; for (i = 1; i <= n_t; i++) e = e * 60 + t[i]
      st = $3 + 0; tot = $4 + 0
      if (st == ps + 1 && ps > 0) d[++n] = e - pe  # only real one-step moves; skips the jump on --resume
      if (st != ps) { ps = st; pe = e } }
    END { k = n > 10 ? n - 9 : 1; for (i = k; i <= n; i++) sum += d[i]
      if (n) { r = sum / (n - k + 1); printf "%.1f %d\n", r, (tot - ps) * r } }')
  [ -n "$eta" ] && printf "  speed %s s/step   ETA %dh %02dm   (finish ~%s)\n" "$rate" $((eta / 3600)) $((eta % 3600 / 60)) "$(date -v+"${eta}"S +%H:%M)"
  echo "$out" | grep -E '\[A$' | tail -1 | sed 's/^/  eval: /'
  echo
  echo "Training loss (last 60 logs)"
  echo "$out" | grep -o "'loss': '[0-9.]*'" | grep -o '[0-9.]*' | spark
  echo "Eval loss (per epoch)"
  echo "$out" | grep -o "'eval_loss': '[0-9.]*'" | grep -o '[0-9.]*' | spark
  echo "$out" | grep -E 'Traceback|Error|saved to' | tail -2
  echo
  echo "System"
  echo "  GPU   $(bar "${gpu:-0}")"
  echo "  RAM   $mem   (free: ${free:-?})"
  echo "  Swap  $swap used"
  sleep 5
done

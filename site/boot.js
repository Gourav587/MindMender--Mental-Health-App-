// Loaded in <head> without defer so the saved theme applies before the first paint (no light flash in dark mode).
try { const t = localStorage.getItem('theme'); if (t) document.documentElement.dataset.theme = t; } catch { /* storage blocked */ }

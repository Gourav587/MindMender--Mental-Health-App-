// Loaded in <head> without defer so the saved theme applies before the first paint (no light flash in dark mode).
try { const t = localStorage.getItem('theme'); if (t) document.documentElement.dataset.theme = t; } catch { /* storage blocked */ }
// Phone browser bar matches the page background in either theme. style.css is loaded first, so the colour is ready.
document.head.append(Object.assign(document.createElement('meta'), { name: 'theme-color', content: getComputedStyle(document.documentElement).backgroundColor }));

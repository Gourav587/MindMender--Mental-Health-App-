// Site-wide interface: header, theme, search, cookie banner, help panel, footer, dialogs, toasts, copy buttons.
// Every page loads it through app.js. Page content stays in each HTML file.

// Shown in the help panel when set. Leave empty until there is a real inbox for it.
const CONTACT_EMAIL = '';

const NAV = [['chat.html', 'Chat'], ['checks.html', 'Self-checks'], ['mood.html', 'Mood'], ['relax.html', 'Relax'], ['faq.html', 'FAQ']];
// Pages the site search reads. Screener questions are drawn by script, so their titles carry the search.
const SEARCH_PAGES = ['index.html', 'chat.html', 'checks.html', 'screener.html?t=phq9', 'screener.html?t=gad7',
  'screener.html?t=stress', 'social.html', 'mood.html', 'journal.html', 'relax.html', 'faq.html', 'privacy.html', 'terms.html'];
const HELPLINES = [['India · Tele-MANAS', '14416'], ['India · KIRAN', '1800-599-0019'], ['US · Suicide & Crisis Lifeline', '988']];

const svg = (d) => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${d}</svg>`;
const ICON = {
  menu: svg('<path d="M4 6h16M4 12h16M4 18h16"/>'),
  close: svg('<path d="M6 6l12 12M18 6L6 18"/>'),
  search: svg('<circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/>'),
  moon: svg('<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"/>'),
  sun: svg('<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'),
  up: svg('<path d="M12 19V5M5 12l7-7 7 7"/>'),
  help: svg('<circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .9-1 1.6V14M12 17.5v.01"/>'),
};

// localStorage can throw (private mode, blocked storage); the site must work without it.
export const store = {
  get: (k) => { try { return localStorage.getItem(k); } catch { return null; } },
  set: (k, v) => { try { localStorage.setItem(k, v); } catch { /* not saved, fine */ } },
  del: (k) => { try { localStorage.removeItem(k); } catch { /* nothing to remove */ } },
};
const escape = (s) => s.replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// ---------- Skip link, header, mobile menu, theme toggle, scroll progress ----------
const main = document.querySelector('main');
main.id = 'main';
main.tabIndex = -1;
document.body.insertAdjacentHTML('afterbegin', '<a class="skip" href="#main">Skip to content</a>');

const header = document.querySelector('header');
header.className = 'site-header';
header.innerHTML = `
  <a class="brand" href="/"><img src="img/logo.png" alt="" width="32" height="32">MindMender</a>
  <nav class="site-nav" id="site-nav" aria-label="Main">
    ${NAV.map(([href, text]) => `<a href="${href}"${location.pathname.endsWith('/' + href) ? ' aria-current="page"' : ''}>${text}</a>`).join('')}
    <a id="auth" href="login.html">Log in</a>
  </nav>
  <div class="tools">
    <button class="icon-btn" id="search-btn" type="button" aria-label="Search the site" title="Search (press /)">${ICON.search}</button>
    <button class="icon-btn" id="theme-btn" type="button" aria-label="Dark mode" aria-pressed="false"></button>
    <button class="icon-btn menu-btn" id="menu-btn" type="button" aria-label="Menu" aria-expanded="false" aria-controls="site-nav">${ICON.menu}</button>
  </div>
  <div class="progress" aria-hidden="true"></div>`;

const menuBtn = document.getElementById('menu-btn');
const setMenu = (open) => {
  header.classList.toggle('open', open);
  menuBtn.setAttribute('aria-expanded', open);
  menuBtn.innerHTML = open ? ICON.close : ICON.menu;
};
menuBtn.onclick = () => setMenu(!header.classList.contains('open'));
header.querySelector('nav').addEventListener('click', (e) => { if (e.target.closest('a')) setMenu(false); });

const themeBtn = document.getElementById('theme-btn');
const isDark = () => (document.documentElement.dataset.theme ?? (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')) === 'dark';
const showTheme = () => {
  themeBtn.setAttribute('aria-pressed', isDark());
  themeBtn.innerHTML = isDark() ? ICON.sun : ICON.moon;
  themeBtn.title = isDark() ? 'Switch to light mode' : 'Switch to dark mode';
};
themeBtn.onclick = () => {
  const next = isDark() ? 'light' : 'dark';
  document.documentElement.dataset.theme = next;
  store.set('theme', next);
  showTheme();
  // Browser bar colour follows the page (boot.js sets it on load).
  document.querySelector('meta[name="theme-color"]')?.setAttribute('content', getComputedStyle(document.documentElement).backgroundColor);
};
showTheme();

const progress = header.querySelector('.progress');
const toTop = document.createElement('button');
toTop.className = 'icon-btn to-top';
toTop.type = 'button';
toTop.setAttribute('aria-label', 'Back to top');
toTop.innerHTML = ICON.up;
toTop.onclick = () => { scrollTo({ top: 0 }); main.focus({ preventScroll: true }); };
document.body.append(toTop);
let ticking = false;
const onScroll = () => {
  const max = document.documentElement.scrollHeight - innerHeight;
  progress.style.transform = `scaleX(${max > 0 ? scrollY / max : 0})`;
  toTop.classList.toggle('show', scrollY > 600);
  header.classList.toggle('scrolled', scrollY > 4); // the header's line only appears once content passes under it
  ticking = false;
};
addEventListener('scroll', () => {
  if (ticking) return;
  ticking = true;
  requestAnimationFrame(onScroll);
}, { passive: true });
onScroll();

// ---------- Footer with crisis lines and the page's real last-updated date, standing on a row of hills ----------
const updated = document.querySelector('meta[name="updated"]')?.content;
document.querySelector('footer')?.remove();
document.body.insertAdjacentHTML('beforeend', `
  <div class="land" aria-hidden="true"><svg viewBox="0 0 1200 72" preserveAspectRatio="none">
    <path class="hill-far" d="M0 40C150 18 300 22 450 34S750 14 900 26 1100 36 1200 22V72H0Z"/>
    <path class="hill-near" d="M0 56C200 38 380 44 560 52S900 34 1200 48V72H0Z"/></svg></div>
  <div class="site-footer-wrap"><footer class="site-footer">
    <p>MindMender is not a substitute for professional care. In crisis? India: Tele-MANAS <a href="tel:14416">14416</a> · KIRAN <a href="tel:18005990019">1800-599-0019</a> · US: <a href="tel:988">988</a> · Elsewhere: <a href="https://findahelpline.com">findahelpline.com</a></p>
    <p><a href="faq.html">FAQ</a> · <a href="privacy.html">Privacy Policy</a> · <a href="terms.html">Terms</a>${updated ? ` · Page last updated <time datetime="${updated}">${new Date(updated + 'T00:00').toLocaleDateString(undefined, { day: 'numeric', month: 'long', year: 'numeric' })}</time>` : ''}</p>
  </footer></div>`);

// ---------- Toasts (success / error states) ----------
const toasts = document.createElement('div');
toasts.className = 'toasts';
toasts.setAttribute('aria-live', 'polite');
document.body.append(toasts);
export function toast(text, kind = 'ok') {
  const el = document.createElement('div');
  el.className = `toast ${kind}`;
  if (kind === 'error') el.setAttribute('role', 'alert');
  el.textContent = text;
  toasts.append(el);
  setTimeout(() => { el.classList.add('leaving'); setTimeout(() => el.remove(), 250); }, kind === 'error' ? 7000 : 3500); // eases out, then leaves
}

// ---------- Confirmation dialog: resolves true only when the person confirms ----------
export function confirmDialog(text, okLabel = 'Confirm') {
  const dialog = document.createElement('dialog');
  dialog.innerHTML = `<form method="dialog"><p>${escape(text)}</p><div class="actions">
    <button value="ok">${escape(okLabel)}</button><button value="cancel" class="secondary" autofocus>Cancel</button></div></form>`;
  document.body.append(dialog);
  dialog.showModal();
  return new Promise((resolve) => dialog.addEventListener('close', () => { resolve(dialog.returnValue === 'ok'); dialog.remove(); }));
}

// ---------- Busy state for buttons while something saves ----------
export async function busy(button, work) {
  button.setAttribute('aria-busy', 'true');
  button.disabled = true;
  try { return await work(); } finally { button.removeAttribute('aria-busy'); button.disabled = false; }
}

// ---------- Copy buttons ----------
export function copyButton(getText, label = 'Copy') {
  const btn = document.createElement('button');
  btn.type = 'button';
  btn.className = 'copy';
  btn.textContent = label;
  btn.onclick = async () => {
    try {
      await navigator.clipboard.writeText(getText());
      btn.textContent = 'Copied';
      setTimeout(() => { btn.textContent = label; }, 2000);
    } catch {
      toast('Copy didn’t work in this browser. Select the text and copy it instead.', 'error');
    }
  };
  return btn;
}
// Any element with data-copy="text" gets a copy button after it.
export function enhanceCopy(root = document) {
  root.querySelectorAll('[data-copy]:not([data-copy-ready])').forEach((el) => {
    el.dataset.copyReady = '';
    el.after(copyButton(() => el.dataset.copy));
  });
}

// ---------- Floating help panel (native popover) ----------
document.body.insertAdjacentHTML('beforeend', `
  <button class="fab" type="button" popovertarget="help-panel">${ICON.help}Get help</button>
  <div class="help-panel" id="help-panel" popover>
    <h2>Need to talk to someone now?</h2>
    <ul>${HELPLINES.map(([name, num]) => `<li>${name}: <a href="tel:${num.replace(/-/g, '')}" data-copy="${num}">${num}</a></li>`).join('')}
      <li>Elsewhere: <a href="https://findahelpline.com">findahelpline.com</a></li></ul>
    <p class="muted">If you are in immediate danger, call 112 (India) or your local emergency number.</p>
    <p><a href="faq.html">Questions about MindMender</a>${CONTACT_EMAIL ? ` · <a href="mailto:${CONTACT_EMAIL}">Contact us</a>` : ''}</p>
  </div>`);
enhanceCopy(document.getElementById('help-panel'));

// ---------- Site search over the site's own pages ----------
let searchIndex;
async function loadIndex() {
  const parser = new DOMParser();
  const pages = await Promise.all(SEARCH_PAGES.map(async (href) => {
    try {
      const doc = parser.parseFromString(await (await fetch(href)).text(), 'text/html');
      doc.querySelectorAll('script, header, footer').forEach((n) => n.remove());
      const title = doc.title.replace(' · MindMender', '');
      const special = { 'screener.html?t=phq9': 'Depression check (PHQ-9)', 'screener.html?t=gad7': 'Anxiety check (GAD-7)', 'screener.html?t=stress': 'Stress check (PSS-10)' }[href];
      const entries = [{ title: special ?? title, href, text: doc.querySelector('main')?.textContent ?? '' }];
      // Each FAQ answer is its own result so search can jump straight to it.
      doc.querySelectorAll('details[id]').forEach((d) => entries.push({
        title: d.querySelector('summary').textContent, href: `${href}#${d.id}`, text: d.textContent,
      }));
      return entries;
    } catch { return []; }
  }));
  return pages.flat().map((e) => ({ ...e, text: e.text.replace(/\s+/g, ' ').trim() }));
}

const searchDialog = document.createElement('dialog');
searchDialog.className = 'search-dialog';
searchDialog.setAttribute('aria-label', 'Search MindMender');
searchDialog.innerHTML = `<form method="dialog">
    <input type="search" placeholder="Search MindMender, e.g. sleep, anxiety, breathing" aria-label="Search MindMender" autocomplete="off">
    <button class="icon-btn" value="close" aria-label="Close search">${ICON.close}</button>
  </form>
  <ul class="search-results" aria-live="polite"></ul>`;
document.body.append(searchDialog);
const searchInput = searchDialog.querySelector('input');
const results = searchDialog.querySelector('ul');

function snippet(text, term) {
  const i = text.toLowerCase().indexOf(term);
  const start = Math.max(0, i - 50);
  const piece = (start ? '…' : '') + text.slice(start, start + 140) + '…';
  return escape(piece).replace(new RegExp(`(${RegExp.escape(term)})`, 'ig'), '<mark>$1</mark>');
}

async function runSearch() {
  const q = searchInput.value.trim().toLowerCase();
  if (!q) { results.innerHTML = ''; return; }
  searchIndex ??= await loadIndex();
  const terms = q.split(/\s+/);
  const hits = searchIndex
    .filter((e) => terms.every((t) => `${e.title} ${e.text}`.toLowerCase().includes(t)))
    .sort((a, b) => b.title.toLowerCase().includes(terms[0]) - a.title.toLowerCase().includes(terms[0]))
    .slice(0, 8);
  results.innerHTML = hits.length
    ? hits.map((e) => `<li><a href="${e.href}"><strong>${escape(e.title)}</strong><small>${snippet(e.text, terms[0])}</small></a></li>`).join('')
    : `<li class="muted">No results for “${escape(searchInput.value.trim())}”.</li>`;
}
searchInput.addEventListener('input', runSearch);
results.addEventListener('click', (e) => { if (e.target.closest('a')) searchDialog.close(); });

const openSearch = () => { searchDialog.showModal(); searchInput.select(); };
document.getElementById('search-btn').onclick = openSearch;
addEventListener('keydown', (e) => {
  const typing = e.target.closest('input, textarea, [contenteditable]');
  if ((e.key === '/' && !typing) || (e.key === 'k' && (e.metaKey || e.ctrlKey))) { e.preventDefault(); openSearch(); }
  if (e.key === 'Escape' && header.classList.contains('open')) setMenu(false);
});

// ---------- Cookie banner and UTM attribution (only kept with consent) ----------
const UTM_KEYS = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content'];
const params = new URLSearchParams(location.search);
if (UTM_KEYS.some((k) => params.has(k))) {
  const utm = Object.fromEntries(UTM_KEYS.filter((k) => params.has(k)).map((k) => [k, params.get(k).slice(0, 100)]));
  try { sessionStorage.setItem('utm_pending', JSON.stringify({ ...utm, landing: location.pathname, ts: Date.now() })); } catch { /* ignore */ }
}
function keepAttribution() {
  try {
    const pending = sessionStorage.getItem('utm_pending');
    if (pending && !store.get('utm')) store.set('utm', pending); // first touch wins
  } catch { /* ignore */ }
}
// The campaign tags a visitor arrived with, only if they allowed it.
export function attribution() {
  if (store.get('consent') !== 'all') return null;
  try { return JSON.parse(store.get('utm')); } catch { return null; }
}

if (store.get('consent') === 'all') keepAttribution();
if (!store.get('consent')) {
  const banner = document.createElement('div');
  banner.className = 'cookie';
  banner.setAttribute('role', 'region');
  banner.setAttribute('aria-label', 'Cookie notice');
  banner.innerHTML = `<p>MindMender stores a few things in your browser to keep you logged in and remember settings like dark mode. With your OK, we also keep an unsaved journal draft on this device, and the campaign tags of the link you arrived from so we know which links help people find us. No ads, no third-party trackers. <a href="privacy.html#browser">Privacy Policy</a></p>
    <div class="actions"><button type="button" data-consent="all">Allow</button><button type="button" class="secondary" data-consent="essential">Essential only</button></div>`;
  banner.addEventListener('click', (e) => {
    const choice = e.target.dataset.consent;
    if (!choice) return;
    store.set('consent', choice);
    if (choice === 'all') keepAttribution();
    banner.remove();
  });
  document.body.append(banner);
}

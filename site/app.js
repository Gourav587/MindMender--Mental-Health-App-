import { toast, confirmDialog, attribution } from './ui.js';
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js';
import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js';
import { getFirestore, collection, addDoc, getDocs, query, orderBy, limit, doc, setDoc, deleteDoc } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js';

// Public web config; access is enforced by firestore.rules.
const app = initializeApp({
  apiKey: 'AIzaSyAM66c4EXXKKXaP_SbsL2oTmzAUxwOX7Fc',
  appId: '1:273965387967:web:fbcecbe0dd9af77d29b60a',
  messagingSenderId: '273965387967',
  projectId: 'mindmender-1dc9a',
  authDomain: 'mindmender-1dc9a.firebaseapp.com',
  storageBucket: 'mindmender-1dc9a.appspot.com',
});
export const auth = getAuth(app);
const db = getFirestore(app);

const userReady = new Promise((resolve) => {
  const stop = onAuthStateChanged(auth, (user) => { stop(); resolve(user); });
});

userReady.then(async (user) => {
  if (!user) return;
  // Nav link becomes "Log out", with a confirmation.
  const link = document.getElementById('auth');
  link.textContent = 'Log out';
  link.onclick = async (e) => {
    e.preventDefault();
    if (await confirmDialog('Log out of MindMender?', 'Log out')) { await signOut(auth); location.href = '/'; }
  };
  // Campaign tags (only present with consent) are saved once per account.
  const utm = attribution();
  try {
    if (utm && localStorage.getItem('utm_saved') !== user.uid) {
      await setDoc(doc(db, 'users', user.uid, 'profile', 'attribution'), utm);
      localStorage.setItem('utm_saved', user.uid);
    }
  } catch { /* not important enough to bother the user */ }
});

export async function requireLogin() {
  const user = await userReady;
  if (!user) location.replace('login.html?next=' + encodeURIComponent(location.pathname + location.search));
  return user;
}

export async function save(coll, data) {
  const user = await requireLogin();
  try {
    const ref = await addDoc(collection(db, 'users', user.uid, coll), { ...data, ts: Date.now() });
    toast('Saved to your history');
    return ref;
  } catch (err) {
    toast('Couldn’t save this. Check your connection and try again.', 'error');
    throw err;
  }
}

export async function remove(coll, id) {
  const user = await requireLogin();
  try {
    await deleteDoc(doc(db, 'users', user.uid, coll, id));
    toast('Deleted');
  } catch (err) {
    toast('Couldn’t delete this. Check your connection and try again.', 'error');
    throw err;
  }
}

// Renders one radio group per question into `el` (option index = value); returns a reader for the answers.
// A question can be [text, options] to override the shared options.
// Unanswered questions are outlined and listed in an error summary instead of the browser's own popup.
export function questionnaire(el, questions, options, prefix = '') {
  el.innerHTML = `<p class="form-error" role="alert"></p>` + questions.map((q, i) => `
    <fieldset><legend>${i + 1}. ${prefix}${Array.isArray(q) ? q[0] : q}</legend><div class="options">
      ${(Array.isArray(q) ? q[1] : options).map((o, v) => `<label><input type="radio" name="q${i}" value="${v}" required><span>${o}</span></label>`).join('')}
    </div></fieldset>`).join('');
  const summary = el.querySelector('.form-error');
  const form = el.closest('form');
  form.addEventListener('invalid', (e) => {
    e.preventDefault();
    const missing = [...el.querySelectorAll('fieldset')].filter((f) => !f.querySelector('input:checked'));
    missing.forEach((f) => f.classList.add('missing'));
    summary.textContent = `Please answer every question. ${missing.length} still need an answer: ${missing.map((f) => f.querySelector('legend').textContent.split('.')[0]).join(', ')}.`;
    missing[0]?.querySelector('input').focus();
  }, true);
  el.addEventListener('change', (e) => {
    e.target.closest('fieldset').classList.remove('missing');
    if (!el.querySelector('fieldset.missing')) summary.textContent = '';
  });
  return () => questions.map((_, i) => Number(el.querySelector(`input[name=q${i}]:checked`).value));
}

// Newest first. Throws if it can't load, so the page can show an error state.
export async function history(coll, n = 30) {
  const user = await requireLogin();
  const snap = await getDocs(query(collection(db, 'users', user.uid, coll), orderBy('ts', 'desc'), limit(n)));
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

// Shared states for history lists.
export const LOADING = '<li class="skeleton"></li><li class="skeleton"></li><li class="skeleton"></li><li class="sr-only">Loading…</li>';
export const LOAD_ERROR = '<li class="error">Couldn’t load your history. Check your connection and refresh the page.</li>';

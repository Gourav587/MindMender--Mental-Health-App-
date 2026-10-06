import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js';
import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js';
import { getFirestore, collection, addDoc, getDocs, query, orderBy, limit } from 'https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js';

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

// One header for every page: add new pages here only.
const NAV = [['chat.html', 'Chat'], ['stress.html', 'Stress test'], ['social.html', 'Social media'], ['mood.html', 'Mood'], ['relax.html', 'Relax']];
document.querySelector('header').innerHTML = `<a class="brand" href="/"><img src="img/logo.png" alt="">MindMender</a>
  <nav>${NAV.map(([href, text]) => `<a href="${href}"${location.pathname.endsWith('/' + href) ? ' aria-current="page"' : ''}>${text}</a>`).join('')}<a id="auth" href="login.html">Log in</a></nav>`;

const userReady = new Promise((resolve) => {
  const stop = onAuthStateChanged(auth, (user) => { stop(); resolve(user); });
});

// Nav link toggles between "Log in" and "Log out".
userReady.then((user) => {
  const link = document.getElementById('auth');
  if (!link || !user) return;
  link.textContent = 'Log out';
  link.onclick = async (e) => { e.preventDefault(); await signOut(auth); location.href = '/'; };
});

export async function requireLogin() {
  const user = await userReady;
  if (!user) location.replace('login.html?next=' + encodeURIComponent(location.pathname));
  return user;
}

export async function save(coll, data) {
  const user = await requireLogin();
  return addDoc(collection(db, 'users', user.uid, coll), { ...data, ts: Date.now() });
}

// Renders one radio group per question into `el` (option index = value); returns a reader for the answers.
// A question can be [text, options] to override the shared options.
export function questionnaire(el, questions, options, prefix = '') {
  el.innerHTML = questions.map((q, i) => `
    <fieldset><legend>${i + 1}. ${prefix}${Array.isArray(q) ? q[0] : q}</legend><div class="options">
      ${(Array.isArray(q) ? q[1] : options).map((o, v) => `<label><input type="radio" name="q${i}" value="${v}" required><span>${o}</span></label>`).join('')}
    </div></fieldset>`).join('');
  return () => questions.map((_, i) => Number(el.querySelector(`input[name=q${i}]:checked`).value));
}

// Newest first.
export async function history(coll, n = 30) {
  const user = await requireLogin();
  const snap = await getDocs(query(collection(db, 'users', user.uid, coll), orderBy('ts', 'desc'), limit(n)));
  return snap.docs.map((d) => d.data());
}

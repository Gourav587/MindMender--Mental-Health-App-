// Perceived Stress Scale (PSS-10, Cohen 1983). Answers are 0 (Never) .. 4 (Very often).
export const PSS_OPTIONS = ['Never', 'Almost never', 'Sometimes', 'Fairly often', 'Very often'];
export const PSS_QUESTIONS = [
  'been upset because of something that happened unexpectedly?',
  'felt that you were unable to control the important things in your life?',
  'felt nervous and stressed?',
  'felt confident about your ability to handle your personal problems?',
  'felt that things were going your way?',
  'found that you could not cope with all the things that you had to do?',
  'been able to control irritations in your life?',
  'felt that you were on top of things?',
  'been angered because of things that happened that were outside of your control?',
  'felt difficulties were piling up so high that you could not overcome them?',
];
const PSS_REVERSED = new Set([3, 4, 6, 7]); // items 4, 5, 7, 8 are positively worded

export function pssScore(answers) {
  const score = answers.reduce((sum, a, i) => sum + (PSS_REVERSED.has(i) ? 4 - a : a), 0);
  const band = score <= 13 ? 'low' : score <= 26 ? 'moderate' : 'high';
  return { score, band };
}

// WHO-5 Well-Being Index. Answers are 0 (At no time) .. 5 (All of the time).
export const WHO5_OPTIONS = ['At no time', 'Some of the time', 'Less than half of the time', 'More than half of the time', 'Most of the time', 'All of the time'];
export const WHO5_QUESTIONS = [
  'I have felt cheerful and in good spirits',
  'I have felt calm and relaxed',
  'I have felt active and vigorous',
  'I woke up feeling fresh and rested',
  'My daily life has been filled with things that interest me',
];

export function who5Score(answers) {
  const score = answers.reduce((sum, a) => sum + a, 0) * 4;
  const band = score <= 28 ? 'very low' : score <= 50 ? 'low' : 'good';
  return { score, band };
}

// Social media & mental health check, from the "Correlation SM Mental Health" study (smmh dataset, 2022).
// Answers are 1..5. A question is either text (frequency scale) or [text, options].
export const SM_OPTIONS = ['Never', 'Rarely', 'Sometimes', 'Often', 'Very often'];
export const SM_TIME_OPTIONS = ['Less than an hour', '1–2 hours', '2–3 hours', '3–4 hours', '4–5 hours', 'More than 5 hours'];
export const SM_QUESTIONS = [
  'How often do you find yourself using social media without a specific purpose?',
  'How often do you get distracted by social media when you are busy doing something?',
  "Do you feel restless if you haven't used social media in a while?",
  'How easily distracted are you?',
  'How much are you bothered by worries?',
  'Do you find it difficult to concentrate on things?',
  'How often do you compare yourself to other successful people through social media?',
  ['How do you feel about these comparisons, generally speaking?', ['Very negative', 'Slightly negative', 'Neutral', 'Slightly positive', 'Very positive']],
  'How often do you look to seek validation from features of social media?',
  'How often do you feel depressed or down?',
  'How frequently does your interest in daily activities fluctuate?',
  'How often do you face issues regarding sleep?',
];
const SM_AREAS = ['adhd', 'adhd', 'anxiety', 'adhd', 'anxiety', 'adhd', 'selfEsteem', 'selfEsteem', 'selfEsteem', 'depression', 'depression', 'depression'];
export const SM_AREA_MAX = { adhd: 20, anxiety: 10, selfEsteem: 14, depression: 15 };
const COMPARISON_FEELING = [0, 4, 2, 0, 0, 0]; // only negative feelings count: 1 -> 4, 2 -> 2, 3..5 -> 0

export function smScore(answers) {
  const areas = { adhd: 0, anxiety: 0, selfEsteem: 0, depression: 0 };
  answers.forEach((a, i) => { areas[SM_AREAS[i]] += i === 7 ? COMPARISON_FEELING[a] : a; });
  const total = Object.values(areas).reduce((s, v) => s + v, 0);
  return { areas, total, checkup: total >= 40 }; // max 59; the study's checkup threshold is 40
}

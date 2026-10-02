// Run: node site/scoring.test.js
import assert from 'node:assert/strict';
import { pssScore, who5Score } from './scoring.js';

assert.deepEqual(pssScore(Array(10).fill(0)), { score: 16, band: 'moderate' });
assert.deepEqual(pssScore([0, 0, 0, 4, 4, 0, 4, 4, 0, 0]), { score: 0, band: 'low' });
assert.deepEqual(pssScore([4, 4, 4, 0, 0, 4, 0, 0, 4, 4]), { score: 40, band: 'high' });
assert.deepEqual(who5Score(Array(5).fill(5)), { score: 100, band: 'good' });
assert.deepEqual(who5Score([2, 2, 2, 2, 2]), { score: 40, band: 'low' });
assert.deepEqual(who5Score([1, 1, 1, 1, 1]), { score: 20, band: 'very low' });
console.log('scoring ok');

import { smScore } from './scoring.js';
// All 3s: 11 questions x 3 = 33, and "Neutral" on the comparison-feeling question scores 0.
assert.deepEqual(smScore(Array(12).fill(3)), { areas: { adhd: 12, anxiety: 6, selfEsteem: 6, depression: 9 }, total: 33, checkup: false });
assert.deepEqual(smScore([5, 5, 5, 5, 5, 5, 5, 1, 5, 5, 5, 5]), { areas: { adhd: 20, anxiety: 10, selfEsteem: 14, depression: 15 }, total: 59, checkup: true });
assert.equal(smScore([4, 4, 4, 4, 4, 4, 4, 2, 4, 4, 4, 4]).total, 46);
assert.equal(smScore([4, 3, 3, 4, 4, 3, 3, 2, 3, 4, 4, 3]).total, 40); // exactly at threshold
assert.equal(smScore([4, 3, 3, 4, 4, 3, 3, 2, 3, 4, 4, 3]).checkup, true);
console.log('social media scoring ok');

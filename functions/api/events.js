// Receives anonymous learning events from the app and stores them in D1.
// POST /api/events  {"locale": "en", "events": [{"koan": "dart/maps/3", "outcome": "wrong", "answer": "true"}]}

const KOAN = /^[a-z]+\/[a-z0-9-]+\/\d{1,3}$/;
const OUTCOMES = new Set(['wrong', 'reveal', 'solve', 'hint']);
const MAX_EVENTS = 25;

export async function onRequestPost({ request, env }) {
  let body;
  try {
    body = await request.json();
  } catch {
    return new Response('bad json', { status: 400 });
  }
  const events = Array.isArray(body?.events) ? body.events.slice(0, MAX_EVENTS) : [];
  const locale = body?.locale === 'id' ? 'id' : 'en';
  const at = Math.floor(Date.now() / 1000);
  const rows = events.filter(
    (e) => typeof e?.koan === 'string' && KOAN.test(e.koan) && OUTCOMES.has(e.outcome),
  );
  if (rows.length === 0) return new Response(null, { status: 204 });

  const insert = env.DB.prepare(
    'INSERT INTO events (at, koan, outcome, answer, attempts, locale) VALUES (?, ?, ?, ?, ?, ?)',
  );
  await env.DB.batch(
    rows.map((e) =>
      insert.bind(
        at,
        e.koan,
        e.outcome,
        typeof e.answer === 'string' ? e.answer.slice(0, 120) : null,
        Number.isInteger(e.attempts) ? Math.min(e.attempts, 99) : null,
        locale,
      ),
    ),
  );
  return new Response(null, { status: 204 });
}

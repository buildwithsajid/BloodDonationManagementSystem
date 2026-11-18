const { Pool, types } = require('pg');

// Return BIGINT/COUNT as numbers, and DATE/TIMESTAMP as plain strings
// (same text the Java app printed: 2026-08-10 and 2026-08-10T14:30:15).
types.setTypeParser(20, (v) => parseInt(v, 10));
types.setTypeParser(1082, (v) => v);
types.setTypeParser(1114, (v) => v.replace(' ', 'T'));

let pool;
function getPool() {
  if (!pool) {
    const cs = process.env.DATABASE_URL || process.env.POSTGRES_URL;
    if (!cs) throw new Error('DATABASE_URL is not set');
    pool = new Pool({
      connectionString: cs,
      ssl: /localhost|127\.0\.0\.1/.test(cs) ? false : { rejectUnauthorized: false },
      max: 3,
    });
  }
  return pool;
}

async function query(text, params) {
  const r = await getPool().query(text, params);
  return r.rows;
}
async function one(text, params) {
  const rows = await query(text, params);
  return rows[0] || null;
}
async function tx(fn) {
  const client = await getPool().connect();
  try {
    await client.query('BEGIN');
    const out = await fn({
      query: async (t, p) => (await client.query(t, p)).rows,
      one: async (t, p) => (await client.query(t, p)).rows[0] || null,
    });
    await client.query('COMMIT');
    return out;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

module.exports = { query, one, tx };

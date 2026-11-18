// Local development: npm start  (needs DATABASE_URL in the environment)
const app = require('./lib/app');
const port = process.env.PORT || 3000;
app.listen(port, () => console.log('BDMS running on http://localhost:' + port));

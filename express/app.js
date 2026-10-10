const express = require('express');
const os = require('os');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`<h1>Hello World desde Express - Version 2.0</h1>
<p>Node.js: ${process.version}</p>
<p>Servidor: ${os.hostname()}</p>
<p>PID: ${process.pid}</p>`);
});

app.listen(PORT, '0.0.0.0', () => console.log(`Escuchando en el puerto ${PORT}`));

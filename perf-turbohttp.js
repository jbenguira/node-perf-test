const turbo = require('turbo-http')
var content = "";
const server = turbo.createServer(function (req, res) {
  content = 'hello world ' + (Math.random() * (10000 - 1) + 1);
  res.setHeader('Content-Length', content.length);
  res.write(Buffer.from(content));
})
server.listen(9057);

console.log("Server running on port 9057");
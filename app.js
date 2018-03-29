const http = require('http');
const fs = require('fs');

const port = process.env.PORT || 3000;
const html = fs.readFileSync('static/index.html');
const Cover0 = fs.readFileSync('static/cover_0.png');
const Cover1 = fs.readFileSync('static/cover_1.png');
const Cover2 = fs.readFileSync('static/cover_2.png');
const logo = fs.readFileSync('static/logo-01.png');

const server = http.createServer(function(req, res) {
    if (req.url === '/') {
      res.writeHead(200);
      res.write(html);
    } else if (req.url === '/cover_0.png') {
      res.writeHead(200);
      res.write(Cover0);
    } else if (req.url === '/cover_1.png') {
      res.writeHead(200);
      res.write(Cover1);
    } else if (req.url === '/cover_2.png') {
      res.writeHead(200);
      res.write(Cover2);
    } else if (req.url === '/logo-01.png') {
      res.writeHead(200);
      res.write(logo);
    } else {
      res.writeHead(404);
    }
    res.end();
});

server.listen(port);

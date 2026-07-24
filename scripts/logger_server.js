const express = require('express');
const helmet = require('helmet');
const fs = require('fs');
const path = require('path');
const app = express();
var express = require('express');
var app = express();
const SAFE_ROOT = path.resolve(__dirname);

// set up rate limiter: maximum of five requests per minute
var RateLimit = require('express-rate-limit');
var limiter = RateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // max 100 requests per windowMs
});

// apply rate limiter to all requests
app.use(limiter);

app.get('/:path', function(req, res) {
  const requestedPath = req.params.path;
  const resolvedPath = path.resolve(SAFE_ROOT, requestedPath);

  if (!(resolvedPath === SAFE_ROOT || resolvedPath.startsWith(SAFE_ROOT + path.sep))) {
    return res.status(403).send('Forbidden');
  }

  if (isValidPath(requestedPath))
    res.sendFile(resolvedPath);
});
app.listen(3000, '127.0.0.1', () => console.log("Bridge Optimized: Active on 127.0.0.1:3000"));

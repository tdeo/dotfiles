'use strict';

const fs = require('fs');

var dirname = process.cwd();
var env = {};

function readEnvFile(filepath) {
  if (!fs.existsSync(filepath)) return {};

  const lines = fs.readFileSync(filepath).toString().split("\n");
  var res = {}
  for(var line of lines) {
    if (line.includes('=')) res[line.split('=')[0]] = line.split('=')[1];
  }
  env = Object.assign(res, env);
}

while (fs.existsSync(dirname)) {
  readEnvFile(dirname + `/.env.${process.env.NODE_ENV}`);
  readEnvFile(dirname + `/.env`);

  if (fs.existsSync(dirname + '/.git')) break;
  dirname += '/..'
}

Object.assign(process.env, env);

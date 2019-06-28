'use strict';

const fs = require('fs');

var dirname = process.cwd();
var env = {};

function readEnvFile(filepath) {
  if (!fs.existsSync(filepath)) return {};

  for(var line of fs.readFileSync(filepath).toString().split("\n")) {
    if (line.includes('=')) {
      var [key, value] = line.split('=');
      if (!(key in env)) {
        env[key] = value;
      }
    }
  }
}

while (fs.existsSync(dirname)) {
  readEnvFile(dirname + `/.env.${process.env.NODE_ENV}`);
  if (process.env.NODE_ENV !== 'test')
    readEnvFile(dirname + `/.env`);

  if (fs.existsSync(dirname + '/.git')) break;
  dirname += '/..'
}

Object.assign(process.env, env);

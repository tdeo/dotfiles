import os

dirname = os.getcwd()
env = {}

def readEnvFile(filepath):
  if not os.path.exists(filepath):
    return {}

  for line in open(filepath).read().split('\n'):
    if '=' in line:
      key, value = line.split('=')
      if key not in env:
        env[key] = value

while (os.path.exists(dirname)):
  readEnvFile(dirname + f'/.env.{os.environ.get("PYTHON_ENV")}');
  readEnvFile(dirname + '/.env');

  if (os.path.exists(dirname + '/.git')):
    break
  dirname += '/..'

os.environ.update(env)
del dirname
del env

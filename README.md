# Skillchecker

## Deploy

Local:

- `git push`
- ssh to remote

Remote:

- cd to repo directory
- `git fetch`, `git pull`
- `./build.sh`
- `rc-service elixir-skillchecker stop`
- copy over the contents of `_build/rel` to `/www/skillchecker`
- `rc-service elixir-skillchecker start`

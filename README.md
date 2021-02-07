# opt

[![awwong1/opt](https://circleci.com/gh/awwong1/opt.svg?style=shield)](https://circleci.com/gh/awwong1/opt)
[![Coverage Status](https://coveralls.io/repos/github/awwong1/opt/badge.svg?branch=)](https://coveralls.io/github/awwong1/opt?branch=)

`opt`: to make a choice, to decide in favor of something

## Development

```bash
elixir -v
# Erlang/OTP 23 [erts-11.1.6] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

# Elixir 1.11.3 (compiled with Erlang/OTP 23)
node -v
# v14.15.4
docker -v
# Docker version 20.10.2, build 2291f61
```
```bash
# fetch Postgres from Docker and mount a local volume for persistence
docker pull postgres:13.1-alpine
mkdir -p ${HOME}/docker/volumes/pg_opt_dev
docker run \
  --rm \
  --name pg-opt-dev \
  --env POSTGRES_DB=opt_dev \
  --env POSTGRES_USER=postgres \
  --env POSTGRES_PASSWORD=postgres \
  --publish 5432:5432 \
  --volume ${HOME}/docker/volumes/pg_opt_dev:/var/lib/postgresql/data \
  --detach \
  postgres:13.1-alpine

# Fetch elixir dependencies, setup DB, and install Node.js dependencies
mix setup
# Start the application
mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Recommended Developer Setup

* [kerl](https://github.com/kerl/kerl), Erlang/OTP instance manager
* [kex](https://github.com/taylor/kiex), Elixir version manager
* [Visual Studio Code](https://code.visualstudio.com/)
  * [ElixirLS Fork: Elixir support and debugger](https://marketplace.visualstudio.com/items?itemName=elixir-lsp.elixir-ls)

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# License

[Apache Version 2.0](LICENSE)

```text
Copyright 2020-2021 Alexander Wong, Udia Software Incorporated

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

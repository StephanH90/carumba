# Carumba

PoC for caluma in elixir/phoenix/liveview.

## Instructions

```bash
docker compose up -d
```

Then visit `http://localhost:4000/documents/blah`

This is a multiplayer version of caluma. You can open the webpage in multiple browsers/tabs and watch how fields get updated in real time (if validations pass).

## Warning!

While the source is mounted into the container and the container does correctly recompile on changes **IT DOES NOT WORK WITH LIVE RELOADING**. Normally, if you run `mix phx.server` the webpage will live-reload when you have made changes to your app. This doesn't work when running the server in a container like this (same as ember).

# default readme below:

## Carumba

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

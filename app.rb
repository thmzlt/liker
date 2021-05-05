#!/usr/bin/env ruby

require "sinatra"
require "redis"

COLOR = ENV["COLOR"] || "antiquewhite"

PROMPT = ENV["PROMPT"] || "Do you like it?"

PREFIX = PROMPT.tr(" ", "-")

KEY_DOWN = PREFIX.tr(" ", "-") + "-down"

KEY_UP = PREFIX.tr(" ", "-") + "-up"

REDIS = Redis.new(host: ENV["REDIS_URL"] || "localhost")

TEMPLATE = <<~HTML
<html>
  <head>
    <title>Liker</title>

    <style>
      body {
        background-color: <%= color %>;
      }
      form {
        display: inline;
      }
    </style>
  </head>
  <body>
    <h1>Liker App</h1>
    <h2><%= prompt %></h2>
    <form method="post" action="/down">
      <input type="submit" value="&#128078;" />
      <%= down %>
    </form>
    <form method="post" action="/up">
      <input type="submit" value="&#128077;" />
      <%= up %>
    </form>
  </body>
</html>
HTML

get "/" do
  up = (REDIS.get(KEY_UP) || "0").to_i
  down = (REDIS.get(KEY_DOWN) || "0").to_i

  erb TEMPLATE, locals: {prompt: PROMPT, color: COLOR, up: up, down: down}
end

post "/down" do
  down = (REDIS.get(KEY_DOWN) || "0").to_i

  REDIS.set(KEY_DOWN, (down + 1).to_s)

  redirect "/"
end

post "/up" do
  current = (REDIS.get(KEY_UP) || "0").to_i

  REDIS.set(KEY_UP, (current + 1).to_s)

  redirect "/"
end

get "/reset" do
  REDIS.set(KEY_DOWN, "0")
  REDIS.set(KEY_UP, "0")

  redirect "/"
end

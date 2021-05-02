# SassEx

Sass compiler for Elixir that uses the newer [Dart Sass](https://sass-lang.com/dart-sass).

## Installation

The package is [available in Hex](https://hex.pm/packages/sass_ex) and can be installed
by adding `sass_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sass_ex, "~> 0.1"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/sass_ex](https://hexdocs.pm/sass_ex).


## Basic Usage

```elixir
iex> SassEx.compile(".example { color: red; }")
{:ok, %SassEx.Response{css: ".example {\n  color: red;\n}", source_map: ""}}
```

## Custom importers

SassEx was built with the ability to have custom importers from the start.  Custom importers
allow you to load `@import`ed files from places other than the file system.  By default, the
standard importer loads from the current directory, but this can be changed to either a different
path or a custom loader that loads from something like a database.

See the `SassEx.Importer` documentation for more details at
[https://hexdocs.pm/sass_ex](https://hexdocs.pm/sass_ex).

## Technical details

SassEx uses [Dart Sass](https://sass-lang.com/dart-sass) under the hood.  A copy of Dart Sass
is run at startup inside an [Elixir/Erlang Port](https://hexdocs.pm/elixir/Port.html).

See [dart-sass-embedded](https://github.com/sass/dart-sass-embedded) for more details.
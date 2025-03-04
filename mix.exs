defmodule SassEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :sass_ex,
      description: description(),
      name: "sass_ex",
      source_url: "https://github.com/markglenn/sass_ex",
      homepage_url: "https://github.com/markglenn/sass_ex",
      version: "0.1.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: [main: "SassEx", extras: ["README.md"]],
      package: [
        maintainers: ["markglenn@gmail.com"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/markglenn/sass_ex"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SassEx, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.14.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.34", only: [:dev, :test], runtime: false},
      {:dart_sass, "~> 0.7", runtime: Mix.env() == :dev}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict", "dialyzer"],
      proto_update: &generate/1
    ]
  end

  defp description do
    """
    SCSS/Sass compiler for Elixir that uses Dart Sass.
    """
  end

  defp generate(_) do
    repo = "sass/sass"
    tag = "HEAD"
    # Download the latest proto file
    Mix.shell().cmd(
      "curl https://raw.githubusercontent.com/#{repo}/#{tag}/spec/embedded_sass.proto --output embedded_sass.proto"
    )

    # Generate the elixir code
    Mix.shell().cmd("protoc --elixir_out=./lib embedded_sass.proto")

    # Make sure the generated file is properly formatted
    Mix.shell().cmd("mix format lib/embedded_sass.pb.ex")
  end
end

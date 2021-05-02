defmodule SassEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :sass_ex,
      version: "0.1.0",
      elixir: "~> 1.11",
      # Mix.env() == :prod,
      start_permanent: true,
      deps: deps(),
      aliases: aliases()
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
      {:protobuf, "~> 0.7.1"},
      {:google_protos, "~> 0.1"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict", "dialyzer"],
      proto_update: &generate/1
    ]
  end

  defp generate(_) do
    # Download the latest proto file
    Mix.shell().cmd(
      "curl https://raw.githubusercontent.com/sass/embedded-protocol/master/embedded_sass.proto --output embedded_sass.proto"
    )

    # Generate the elixir code
    Mix.shell().cmd("protoc --elixir_out=./lib embedded_sass.proto")

    # Make sure the generated file is properly formatted
    Mix.shell().cmd("mix format lib/embedded_sass.pb.ex")
  end
end

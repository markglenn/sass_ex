defmodule ScssEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :scss_ex,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.7.1"},
      {:google_protos, "~> 0.1"}
    ]
  end

  defp escript do
    [main_module: ScssEx]
  end
end

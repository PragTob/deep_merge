defmodule Benches.MixProject do
  use Mix.Project

  def project do
    [
      app: :benches,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
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
      {:deep_merge, path: "..", override: true},
      {:benchee, "~> 0.14.0"}
    ]
  end
end

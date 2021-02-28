defmodule DeepMerge.Mixfile do
  use Mix.Project

  @source_url "https://github.com/PragTob/deep_merge"
  @version "1.0.0"

  def project do
    [
      app: :deep_merge,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      package: package(),
      name: "deep_merge",
      description: """
      Deep (recursive) merging for maps, keyword lists and whatever else
      you may want via implementing a simple protocol.
      """,
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs],
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true
      ],
      preferred_cli_env: [
        docs: :docs,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    []
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
      {:inch_ex, "~> 2.0", only: :docs},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: @version
    ]
  end

  defp package do
    [
      maintainers: ["Tobias Pfeiffer"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/deep_merge/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end
end

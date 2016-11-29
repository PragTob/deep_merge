defmodule DeepMerge.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :deep_merge,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     deps: deps(),
     docs: [source_ref: @version],
     package: package(),
     name: "deep_merge",
     source_url: "https://github.com/PragTob/deep_merge",
     description: """
     Deep (recursive) merging for maps, keyword lists and whatever else
     you may want via implementing a simple protocol.
     """

   ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo,   "~> 0.5",   only: :dev},
      {:benchee, "~> 0.5",   only: :dev},
      {:ex_doc,  "~> 0.11",  only: :dev},
      {:earmark, "~> 1.0.1", only: :dev},
      {:inch_ex, "~> 0.5",   only: :docs}
    ]
  end

  defp package do
    [
      maintainers: ["Tobias Pfeiffer"],
      licenses: ["MIT"],
      links: %{
        "github"     => "https://github.com/PragTob/deep_merge"
      }
    ]
  end

end

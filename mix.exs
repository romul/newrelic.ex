defmodule NewRelic.Mixfile do
  use Mix.Project

  def project do
    [app: :new_relic,
     version: "0.1.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Elixir library for sending metrics to New Relic.",
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {NewRelic, []}, applications: [:logger, :lhttpc, :poison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:ecto, ">= 1.1.0"},
     {:lhttpc, "~> 1.4"},
     {:poison, "~> 2.2 or ~> 3.0"},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [maintainers: ["Roman Smirnov"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/romul/newrelic.ex"}]
  end
end

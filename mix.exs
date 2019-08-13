defmodule NewRelic.Mixfile do
  use Mix.Project

  def project do
    [
      app: :new_relic,
      version: "0.1.2",
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Elixir library for sending metrics to New Relic.",
      package: package(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {NewRelic, []}, applications: [:logger, :lhttpc, :poison]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.2", optional: true},
      {:ecto, ">= 2.0.0", optional: true},
      {:lhttpc, "~> 1.4"},
      {:poison, ">= 2.0.0"},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Roman Smirnov"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/romul/newrelic.ex"}
    ]
  end
end

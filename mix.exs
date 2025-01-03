defmodule Aoc2016.MixProject do
  use Mix.Project

  def project do
    [
      app: :main,
      version: "0.1.0",
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

  defp escript do
    [main_module: Main]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:heap, "~> 3.0.0"},
      {:memoize, "~> 1.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

defmodule Eetoul.Mixfile do
  use Mix.Project

  def project do
    [app: :eetoul,
     version: "0.1.0",
     elixir: "~> 1.3.0",
     deps: deps,
     default_task: "escript.build",
     escript: escript,
     dialyzer: dialyzer]
  end

  def application do
    [applications: []]
  end

  defp escript do
    [main_module: Eetoul,
     path: "bin/eetoul"]
  end

  defp dialyzer do
    paths = ~W[eetoul geef monad]
    |> Enum.map(&(File.cwd!() <> "/_build/#{Mix.env}/lib/" <> &1 <> "/ebin"))

    [plt_apps: ~W[erts kernel stdlib mnesia]a,
     flags: ~W[-Wunmatched_returns -Werror_handling -Wrace_conditions -Wno_opaque],
     paths: paths]
  end

  defp deps do
    [{:colorful, "~> 0.6.0"},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:geef, github: "ramonsnir/geef"},
     {:monad, "~> 1.0.4"},
     {:short_maps, "~> 0.1.1"}]
  end
end

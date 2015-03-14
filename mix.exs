defmodule Eetoul.Mixfile do
  use Mix.Project

  def project do
    [app: :eetoul,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps,
		 default_task: "escript.build",
		 escript: escript]
  end

	def application do
		[applications: [:logger]]
	end

	def escript do
		[main_module: Eetoul,
		 path: "bin/eetoul"]
	end

  defp deps do
		[{:geef, git: "https://github.com/ramonsnir/geef.git"},
		 {:colorful, "~> 0.6.0"},
		 {:monad, "~> 1.0.4"}]
  end
end

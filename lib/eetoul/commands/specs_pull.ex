defmodule Eetoul.Commands.SpecsPull do
	use Eetoul.CommandDSL

	command do
		flag :force
	end
end

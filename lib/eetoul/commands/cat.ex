defmodule Eetoul.Commands.Cat do
	use Eetoul.CommandDSL

	command do
		release :release
		flag :color
	end
end

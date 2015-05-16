defmodule Eetoul.Commands.Archive do
	use Eetoul.CommandDSL

	command do
		release :release
		flag :force
	end
end

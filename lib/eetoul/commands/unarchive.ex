defmodule Eetoul.Commands.Unarchive do
	use Eetoul.CommandDSL

	command do
		archived_release :archived_release
		flag :force
	end
end

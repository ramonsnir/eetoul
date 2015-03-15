defmodule Eetoul.Test.SampleTreeRepo do
	use Geef
	import Eetoul.Test.RepoUtils

	@doc false
	def create path do
		:ok = File.mkdir path
		{:ok, repo} = Repository.init path, true

		{:ok, first_commit} = make_commit(repo, "First",
																			%{"greeting" => "Hello",
																				"target" => "world"})
		{:ok, second_commit} = make_commit(repo, "Second",
																			 %{"greeting" => "Hello",
																				 "target" => "world",
																				 "dist/total" => "Hello, world!"},
																			 [first_commit])

		{:ok, _ref} = Reference.create repo, "refs/heads/master", second_commit

		{:ok, repo}
	end
end

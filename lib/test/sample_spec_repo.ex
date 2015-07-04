defmodule Eetoul.Test.SampleSpecRepo do
	use Geef
	import Eetoul.RepoUtils

	@doc false
	def create path do
		:ok = File.mkdir path
		{:ok, repo} = Repository.init path, true

		{:ok, commit} = make_commit(repo, "Eetoul Spec",
																%{"first-release" => "",
																	"second-release" => "",
																	".archive/ancient-release" => ""})
		{:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", commit

		{:ok, commit} = make_commit(repo, "Code Branch 1",
																%{"greeting" => "Hello world!"})
		{:ok, _ref} = Reference.create repo, "refs/tags/first-tag", commit
		{:ok, commit} = make_commit(repo, "Code Branch 2",
																%{"greeting" => "Hello, all!"},
																[commit])
		{:ok, _ref} = Reference.create repo, "refs/heads/first-branch", commit

		{:ok, repo}
	end
end

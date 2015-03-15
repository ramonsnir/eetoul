defmodule Eetoul.Test.SampleSpecRepo do
	use Geef
  alias Geef.Index
  alias Geef.Index.Entry

	@doc false
	def create path do
		:ok = File.mkdir path
		{:ok, repo} = Repository.init path, true
		sig = Signature.now "Eetoul Test", "test@eetoul"

		{:ok, tree_id} = make_index(repo,
																%{"first-release" => "",
																	"second-release" => ""})
		{:ok, commit} = Commit.create repo, sig, sig, "Eetoul Spec", tree_id, []
		{:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", commit

		{:ok, tree_id} = make_index(repo, %{"greeting" => "Hello world!"})
		{:ok, commit} = Commit.create repo, sig, sig, "Code Branch 1", tree_id, []
		{:ok, _ref} = Reference.create repo, "refs/tags/first-tag", commit
		{:ok, tree_id} = make_index(repo, %{"greeting" => "Hello world!"})
		{:ok, commit} = Commit.create repo, sig, sig, "Code Branch 2", tree_id, []
		{:ok, _ref} = Reference.create repo, "refs/heads/first-branch", commit

		{:ok, repo}
	end

	defp make_index repo, files do
    {:ok, odb} = Repository.odb repo
		{:ok, idx} = Index.new
    {now_mega, now_secs, _} = :os.timestamp
    time = now_mega * 1000000 + now_secs
		for {path, content} <- files do
			{:ok, blob_id} = Odb.write odb, content, :blob
			entry = %Entry{mode: 0o100644, id: blob_id, path: path, size: byte_size(content), mtime: time}
			:ok = Index.add idx, entry
		end
		Index.write_tree idx, repo
	end
end

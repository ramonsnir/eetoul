defmodule Eetoul.Test.SampleSpecRepo do
	use Geef
  alias Geef.Index
  alias Geef.Index.Entry

	@doc false
	def create path do
		:ok = File.mkdir path
		{:ok, repo} = Repository.init path, true

    {:ok, odb} = Repository.odb repo
		{:ok, empty_file_id} = Odb.write odb, "", :blob

    {:ok, spec_idx} = Index.new
    {now_mega, now_secs, _} = :os.timestamp
    time = now_mega * 1000000 + now_secs
		for spec <- ["first-release", "second-release"] do
			entry = %Entry{mode: 0o100644, id: empty_file_id, path: spec, size: byte_size(""), mtime: time}
			:ok = Index.add spec_idx, entry
		end

    {:ok, tree_id} = Index.write_tree spec_idx, repo
		sig = Signature.now "Eetoul Test", "test@eetoul"
		{:ok, commit} = Commit.create repo, sig, sig, "Eetoul Spec", tree_id, []
		{:ok, _ref} = Reference.create repo, "refs/heads/eetoul-spec", commit

		{:ok, repo}
	end
end

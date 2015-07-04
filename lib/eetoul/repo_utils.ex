defmodule Eetoul.RepoUtils do
	use Geef
  alias Geef.Index
  alias Geef.Index.Entry

	@doc false
	def make_index repo, files do
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

	@doc false
	def make_commit repo, message, files, parents \\ [], sig \\ nil do
		unless sig do
			sig = Signature.now "Eetoul Test", "test@eetoul"
		end
    {:ok, odb} = Repository.odb repo
		{:ok, idx} = Index.new
    {now_mega, now_secs, _} = :os.timestamp
    time = now_mega * 1000000 + now_secs
		for {path, content} <- files do
			{:ok, blob_id} = Odb.write odb, content, :blob
			entry = %Entry{mode: 0o100644, id: blob_id, path: path, size: byte_size(content), mtime: time}
			:ok = Index.add idx, entry
		end
		{:ok, tree_id} = Index.write_tree idx, repo
		Commit.create repo, sig, sig, message, tree_id, parents
	end
end

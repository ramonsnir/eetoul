defmodule Eetoul.RepoUtils do
  import ShortMaps
  use Geef
  require Monad.Error, as: Error
  alias Geef.Index.Entry

  @doc ""
  def make_commit repo, message, files, parents \\ [], sig \\ nil do
    sig = sig_or_default sig
    {:ok, tree_id} = write_tree repo, files
    Commit.create repo, sig, sig, message, tree_id, parents
  end

  @doc ""
  def read_file repo, reference, path do
    Error.m do
      commit <- resolve_reference repo, reference
      tree <- Commit.tree commit
      ~m{%TreeEntry id}a <- Tree.get tree, path
      blob <- Blob.lookup repo, id
      content <- Blob.content blob
      return content
    end
  end

  @doc ""
  def read_commit repo, reference do
    Error.m do
      commit <- resolve_reference repo, reference
      files <- files_from_commit repo, commit
      return (files
      |> Enum.map(fn {k, v} -> {k, v.content} end)
      |> Enum.into(%{}))
    end
  end

  @doc ""
  def commit repo, reference, message, transformation, extra_parents \\ [], sig \\ nil do
    sig = sig_or_default sig
    maybe_resolved_parent = resolve_reference repo, reference
    maybe_files =
      case maybe_resolved_parent do
        {:ok, parent} -> files_from_commit repo, parent
        _ ->
          {:ok, %{}}
      end

    maybe_commit = Error.m do
      # creating new commit
      files <- maybe_files
      files <- {:ok, transformation.(files)}
      parents <- case maybe_resolved_parent do
                   {:ok, ~m{%Object id}a} -> {:ok, [id]}
                   _ -> {:ok, []}
                 end
      commit <- make_commit repo, message, files, (parents ++ extra_parents), sig
      return commit
    end
    if String.starts_with?(reference, "refs/heads/") do
      Error.m do
        # updating reference
        commit <- maybe_commit
        _ref <- Reference.create repo, reference, commit, true
        return commit
      end
    else
      {:error, :not_found}
    end
  end

  defp files_from_commit repo, commit do
    Error.m do
      tree <- Commit.tree commit
      files <- read_tree repo, tree
      return files
    end
  end

  defp write_tree repo, files do
    {:ok, odb} = Repository.odb repo
    {:ok, idx} = Index.new
    for {path, content} <- files do
      entry = write_entry odb, path, content
      :ok = Index.add idx, entry
    end
    Index.write_tree idx, repo
  end

  @lint {Credo.Check.Readability.LargeNumbers, false}
  defp write_entry odb, path, ~m{mode content}a do
    {now_mega, now_secs, _} = :os.timestamp
    time = now_mega * 1_000_000 + now_secs
    {:ok, blob_id} = Odb.write odb, content, :blob
    %Entry{mode: mode, id: blob_id, path: path, size: byte_size(content), ctime: time, mtime: time}
  end
  defp write_entry odb, path, content do
    {now_mega, now_secs, _} = :os.timestamp
    time = now_mega * 1_000_000 + now_secs
    {:ok, blob_id} = Odb.write odb, content, :blob
    %Entry{mode: 0o100644, id: blob_id, path: path, size: byte_size(content), ctime: time, mtime: time}
  end

  defp read_tree repo, tree do
    {:ok, Enum.into(read_tree(repo, tree, ""), %{})}
  end

  defp read_tree repo, tree, path do
    files = for ~m{%TreeEntry name mode type id}a <- tree do
      name =
      if path != "" do
        "#{path}/#{name}"
      else
        name
      end
      case type do
        :blob ->
          {:ok, blob} = Blob.lookup repo, id
          {:ok, content} = Blob.content blob
          [{name, ~m{mode content}a}]
        :tree ->
          {:ok, tree} = Tree.lookup repo, id
          read_tree repo, tree, name
      end
    end
    Enum.flat_map files, &(&1)
  end

  defp resolve_reference _repo, (ci = %Object{type: :commit}) do
    {:ok, ci}
  end
  defp resolve_reference repo, reference do
    Error.m do
      %Reference{target: commit_id} <- Reference.dwim(repo, reference)
      commit <- Commit.lookup(repo, commit_id)
      return commit
    end
  end

  defp sig_or_default sig do
    if sig do
      sig
    else
      %Signature{name: "Eetoul", email: "eetoul@eetoul", time: {{1000, 0, 0}, 0}}
    end
  end
end

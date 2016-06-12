defmodule Eetoul.Build.ReferenceError do
  defexception message: "Reference not found."
end
defmodule Eetoul.Build.TakeError do
  defexception message: "Could not take branch."
end

defmodule Eetoul.Build do
  use Geef
  alias Eetoul.Build.ReferenceError
  alias Eetoul.Build.TakeError
  alias Eetoul.Colorful
  alias Eetoul.Spec
  alias Eetoul.Merge
  alias Eetoul.RecordedConflictResolutions
  alias Eetoul.RepoUtils

  @spec build(pid, (String.t | Spec.t), Keyword.t) :: :ok
  def build repo, spec, options \\ []
  def build(repo, spec, options) when is_binary(spec) do
    options =
      options
    |> Keyword.put(:rcr_key, spec)
    case RepoUtils.read_file(repo, "refs/heads/eetoul-spec", spec) do
      {:ok, spec_content} ->
        spec = Spec.parse spec_content
        :ok = Spec.validate repo, spec
        build repo, spec, options
      _ ->
        raise ReferenceError, message: "Eetoul spec \"#{spec}\" was not found."
    end
  end
  def build repo, spec, options do
    target_name = Keyword.get options, :target_name, random_reference_name
    options =
      options
    |> Keyword.put_new(:target_name, target_name)
    |> Keyword.put_new(:output, :normal)
    |> Keyword.put_new(:rcr_key, (String.replace target_name, "/", "__"))
    {[{:checkout, base}], directives} = Enum.split spec, 1
    if options[:output] == :normal do
      IO.puts "Checking out '#{Colorful.string base, ~W[green]}'..."
    end
    base_commit_id = resolve repo, base
    commit_id = Enum.reduce(directives, base_commit_id,
                            &(execute_directive repo, &2, &1, options))
    Reference.create! repo, target_name, commit_id, true
    :ok
  end

  defp execute_directive repo, commit_id, {:take, ref, {:squash, message}}, options do
    if options[:output] == :normal do
      IO.puts "Taking '#{Colorful.string ref, ~W[blue]}' (squashed)..."
    end
    merged_commit_id = execute_directive repo, commit_id, {:take, ref, :merge}, options
    {:ok, commit} = Commit.lookup repo, merged_commit_id
    author = Commit.author! commit
    committer = Commit.committer! commit
    tree = Commit.tree! commit
    {:ok, result_commit_id} = Commit.create repo, author, committer, message, tree.id, [commit_id]
    result_commit_id
  end
  defp execute_directive repo, commit_id, {:take, ref, :merge}, options do
    if options[:output] == :normal do
      IO.puts "Taking '#{Colorful.string ref, ~W[blue]}'..."
    end
    ref_commit_id = resolve repo, ref
    maybe_merged_commit_id =
      case Merge.merge repo, commit_id, ref_commit_id do
        (result = {:ok, _}) -> result
        _ ->
          RecordedConflictResolutions.reapply_recorded_resolutions(
            repo, options[:rcr_key],
            ref, commit_id, ref_commit_id
          )
      end
    case maybe_merged_commit_id do
      {:ok, merged_commit_id} ->
        reformat_merge_commit repo, ref, merged_commit_id
      _ ->
        if options[:output] == :normal do
          IO.puts Colorful.string("Failure.", ~W[red])
        end
        raise TakeError
    end
  end

  defp reformat_merge_commit repo, ref, commit_id do
    {:ok, commit} = Commit.lookup repo, commit_id
    base_id = Commit.parent_id! commit, 0
    parent_id = Commit.parent_id! commit, 1
    {:ok, parent} = Commit.lookup repo, parent_id
    author = Commit.author! parent
    committer = Commit.committer! parent
    tree = Commit.tree! commit
    {:ok, result_commit_id} = Commit.create repo, author, committer, "Merged #{ref}", tree.id, [base_id, parent_id]
    result_commit_id
  end

  defp resolve repo, reference do
    reference =
      case RepoUtils.read_file(repo, "refs/heads/eetoul-spec", reference) do
        {:ok, _} ->
          ref_name = random_reference_name
          full_ref = "refs/heads/#{ref_name}"
          build repo, reference, ref_name
          full_ref
        _ -> reference
      end
    case Reference.dwim(repo, reference) do
      {:ok, %Reference{target: commit_id}} -> commit_id
      _ ->
        raise ReferenceError, message: "Reference \"#{reference}\" was not found."
    end
  end

  defp random_reference_name do
    "refs/heads/tmp-reference-#{:random.uniform 1000000}"
  end
end

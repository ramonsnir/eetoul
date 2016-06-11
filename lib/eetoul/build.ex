defmodule Eetoul.Build.ReferenceError do
  defexception message: "Reference not found."
end

defmodule Eetoul.Build do
  use Geef
  alias Eetoul.Build.ReferenceError
  alias Eetoul.Colorful
  alias Eetoul.Spec
  alias Eetoul.Merge
  alias Eetoul.RepoUtils

  @spec build(pid, (String.t | Spec.t)) :: :ok
  def build repo, spec, target_name \\ nil, output \\ :normal
  def build(repo, spec, target_name, output) when is_binary(spec) do
    case RepoUtils.read_file(repo, "refs/heads/eetoul-spec", spec) do
      {:ok, spec_content} ->
        spec = Spec.parse spec_content
        :ok = Spec.validate repo, spec
        build repo, spec, target_name, output
      _ ->
        raise ReferenceError, message: "Eetoul spec \"#{spec}\" was not found."
    end
  end
  def build repo, spec, target_name, output do
    if target_name == nil do
      target_name = random_reference_name
    end
    {[{:checkout, base}], directives} = Enum.split spec, 1
    if output == :normal do
      IO.puts "Checking out '#{Colorful.string base, ~W[green]}'..."
    end
    base_commit_id = resolve repo, base
    commit_id = Enum.reduce(directives, base_commit_id,
                            &(execute_directive repo, &2, &1, output))
    Reference.create! repo, target_name, commit_id, true
    :ok
  end

  defp execute_directive repo, commit_id, directive, output \\ false
  defp execute_directive repo, commit_id, {:take, ref, {:squash, message}}, output do
    if output == :normal do
      IO.puts "Taking '#{Colorful.string ref, ~W[blue]}' (squashed)..."
    end
    merged_commit_id = execute_directive repo, commit_id, {:take, ref, :merge}, true
    {:ok, commit} = Commit.lookup repo, merged_commit_id
    author = Commit.author! commit
    committer = Commit.committer! commit
    tree = Commit.tree! commit
    {:ok, result_commit_id} = Commit.create repo, author, committer, message, tree.id, [commit_id]
    result_commit_id
  end
  defp execute_directive repo, commit_id, {:take, ref, :merge}, output do
    if output == :normal do
      IO.puts "Taking '#{Colorful.string ref, ~W[blue]}'..."
    end
    ref_commit_id = resolve repo, ref
    {:ok, merged_commit_id} = Merge.merge repo, commit_id, ref_commit_id
    {:ok, commit} = Commit.lookup repo, merged_commit_id
    if Commit.parent_count!(commit) == 1 do
      merged_commit_id
    else
      base_id = Commit.parent_id! commit, 0
      parent_id = Commit.parent_id! commit, 1
      {:ok, parent} = Commit.lookup repo, parent_id
      author = Commit.author! parent
      committer = Commit.committer! parent
      tree = Commit.tree! commit
      message = Commit.message! parent
      {:ok, result_commit_id} = Commit.create repo, author, committer, "Merged #{ref}", tree.id, [base_id, parent_id]
      result_commit_id
    end
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

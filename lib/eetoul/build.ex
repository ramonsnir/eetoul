defmodule Eetoul.Build.ReferenceError do
  defexception message: "Reference not found."
end

defmodule Eetoul.Build do
  use Geef
  alias Eetoul.Build.ReferenceError
  alias Eetoul.Spec
  alias Eetoul.RepoUtils

  @spec build(pid, (String.t | Spec.t)) :: :ok
  def build repo, spec, target_name \\ nil
  def build(repo, spec, target_name) when is_binary(spec) do
    case RepoUtils.read_file(repo, "refs/heads/eetoul-spec", spec) do
      {:ok, spec_content} ->
        spec = Spec.parse spec_content
        :ok = Spec.validate repo, spec
        build repo, spec, target_name
      _ ->
        raise ReferenceError, message: "Eetoul spec \"#{spec}\" was not found."
    end
  end
  def build repo, spec, target_name do
    if target_name == nil do
      target_name = random_reference_name
    end
    {[{:checkout, base}], _directives} = Enum.split spec, 1
    base_commit_id = resolve repo, base
    Reference.create! repo, target_name, base_commit_id, true
    :ok
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

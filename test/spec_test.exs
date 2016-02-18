defmodule EetoulSpecTest do
  import ShortMaps
  use ExUnit.Case, async: true
  require Monad.Error, as: Error
  alias Eetoul.Utils
  alias Eetoul.Spec
  alias Eetoul.Spec.ParseError
  alias Eetoul.Spec.ValidationError
  alias Eetoul.Test.SampleTreeRepo
  alias Eetoul.Test.SampleSpecRepo

  setup_all do
    Utils.seed
    tree_path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf tree_path
    on_exit fn -> File.rm_rf tree_path end
    spec_path = "tmp-#{__MODULE__}-#{:random.uniform 1000000}"
    File.rm_rf spec_path
    on_exit fn -> File.rm_rf spec_path end

    Error.m do
      tree_repo <- SampleTreeRepo.create(tree_path)
      spec_repo <- SampleSpecRepo.create(spec_path)
      return ~m{tree_repo spec_repo}a
    end
  end

  test "parse valid spec" do
    spec = "checkout first\ntake-rebase second\ntake third Third tag is here\ntake-merge fourth\n"
    expected = [
      {:checkout, "first"},
      {:take, "second", :rebase},
      {:take, "third", {:squash, "Third tag is here"}},
      {:take, "fourth", :merge}
    ]
    assert expected == Spec.parse(spec)
  end

  test "`checkout` needs arguments" do
    assert_raise ParseError, "`checkout` expects a reference argument.", fn ->
      Spec.parse "checkout"
    end
  end

  test "`checkout` needs only one argument" do
    assert_raise ParseError, "`checkout` does not expect a message argument.", fn ->
      Spec.parse "checkout foo bar"
    end
  end

  test "`take-squash` needs arguments" do
    assert_raise ParseError, "`take` expects a reference argument.", fn ->
      Spec.parse "take"
    end
  end

  test "`take-squash` needs two arguments" do
    assert_raise ParseError, "`take` expects a message argument.", fn ->
      Spec.parse "take foo"
    end
  end

  test "valid spec is valid", meta do
    spec = [
      {:checkout, "first"},
      {:take, "second", :rebase},
      {:take, "third", {:squash, "Third tag is here"}},
      {:take, "fourth", :merge}
    ]
    assert :ok = Spec.validate(meta.tree_repo, spec)
  end

  test "valid spec recursive is valid", meta do
    spec = [
      {:checkout, "first-release"},
      {:take, "second-release", :default}
    ]
    assert :ok = Spec.validate(meta.spec_repo, spec)
  end

  test "must `checkout` at least once", meta do
    spec = []
    assert_raise ValidationError, "First line in spec must be a `checkout`.", fn ->
      Spec.validate(meta.tree_repo, spec)
    end
  end

  test "must `checkout` only once", meta do
    spec = [
      {:checkout, "first"},
      {:checkout, "first"}
    ]
    assert_raise ValidationError, "Cannot `checkout` twice in the same spec.", fn ->
      Spec.validate(meta.tree_repo, spec)
    end
  end

  test "must reference a real reference", meta do
    spec = [
      {:checkout, "last"}
    ]
    assert_raise ValidationError, "Cannot find reference \"last\".", fn ->
      Spec.validate(meta.tree_repo, spec)
    end
  end
end

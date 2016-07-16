%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/", "mix.exs", ".credo.exs"],
        excluded: []
      },
      checks: [
        {Credo.Check.Design.DuplicatedCode, mass_threshold: 16, nodes_threshold: 2},
        {Credo.Check.Design.TagFIXME, exit_status: 0},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},

        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Refactor.PipeChainStart, false},

        {Credo.Check.Warning.NameRedeclarationByAssignment, false},
        {Credo.Check.Warning.NameRedeclarationByCase, false},
        {Credo.Check.Warning.NameRedeclarationByDef, false},
        {Credo.Check.Warning.NameRedeclarationByFn, false},
      ]
    }
  ]
}

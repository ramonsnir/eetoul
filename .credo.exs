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

        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Refactor.PipeChainStart, false},

        {Credo.Check.Warning.NameRedeclarationByAssignment, false}, # FIXME uncomment after credo fixes patterns bug #102
        {Credo.Check.Warning.NameRedeclarationByCase, false}, # FIXME uncomment after credo fixes patterns bug #102
        {Credo.Check.Warning.NameRedeclarationByDef, false}, # FIXME uncomment after credo fixes patterns bug #102
        {Credo.Check.Warning.NameRedeclarationByFn, false}, # FIXME uncomment after credo fixes patterns bug #102
      ]
    }
  ]
}

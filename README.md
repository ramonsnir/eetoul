[ ![Codeship Status for ramonsnir/eetoul](https://codeship.com/projects/d6637e90-dec4-0132-d9d6-465ff4e7e511/status?branch=master)](https://codeship.com/projects/80437)

# Eetoul

Ramon Snir (c) 2015 [MIT License]

A declarative tool for creating integration branches in git

### Why?

I found that during development of a version, people wish to test if their code works with other team members' changes. My team members often had issues with the integration branches, merging the integration branches into their feature branches (and then forcing us to start slowly rebasing the feature branches, to take out commits that were meant for a future version but still needed testing).

This solution fits only very specific development teams. Think twice before you choose this development flow.

### How?

(further explanation will come in the future, and of course with new features)

Create your release specification branch:
```sh
eetoul init
eetoul create release-february master
```

Release specifications are placed in the `eetoul-spec` branch and are named by the file name of the specification file. Let's say we have the following content for the committed `release-february` file in `eetoul-spec`:
```
checkout master
take-merge Task-1
take-merge Task-3
take Task-4 add dropdowns support
```

Then we could test that it can be built without conflicts:
```sh
$ eetoul test release-february
Checking out 'master'...
Taking 'Task-1-improve-buttons'...
Taking 'Task-2-fix-tables'...
Taking 'Task-3-add-dropdowns' (squashed)...
Integration branch succesfully created.
```

This means the branch is good, and we can then push our changes to `eetoul-spec` to our remote repository and redeploy the release.

To actually make the branch (to test it or to use it), we can run `eetoul make release-february`.

If your deployment procedured isn't configured to make the latest `eetoul` branch, then you can make it and push it in a single command (`eetoul push release-february`) and then deploy the branch `release-february`.

## Conflict Resolution Recording

Based on git's own `rerere` feature, `eetoul` comes with its own (hopefully) superior conflict resolution mechanism. In its simplest form, it keeps along the commit tree of the branch `eetoul-recorded-conflict-resolutions` commits that assist it in reapplying resolutions of previously seen conflicts.

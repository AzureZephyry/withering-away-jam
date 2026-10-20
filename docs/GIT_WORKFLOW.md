# Git collaboration and contributor handbook

[README](../README.md) · [Existing-contributor companion](GIT_EXISTING_CONTRIBUTORS.md) ·
[Project structure](PROJECT_STRUCTURE.md) · [Team progress](TEAM_PROGRESS.md)

This is the parent handbook for contributing to Withering Away. Start here if you
are new to Git or the repository. If you already have local work, an old branch,
divergence, or an interrupted operation, start with the companion's diagnosis and
return here for shared policy. The two documents form one workflow, not competing
policies.

## Contents

1. [Purpose and shared policy](#1-purpose-and-shared-policy)
2. [Git and GitHub fundamentals](#2-git-and-github-fundamentals)
3. [Install and identify yourself](#3-install-and-identify-yourself)
4. [Authenticate and obtain access](#4-authenticate-and-obtain-access)
5. [Clone once and verify the copy](#5-clone-once-and-verify-the-copy)
6. [Import and run Godot](#6-import-and-run-godot)
7. [Choose a development branch](#7-choose-a-development-branch)
8. [Start a session deliberately](#8-start-a-session-deliberately)
9. [Make a focused change](#9-make-a-focused-change)
10. [Read status and differences](#10-read-status-and-differences)
11. [Stage only intended work](#11-stage-only-intended-work)
12. [Create a coherent local commit](#12-create-a-coherent-local-commit)
13. [Push the intended development branch](#13-push-the-intended-development-branch)
14. [Prepare and review a Pull Request](#14-prepare-and-review-a-pull-request)
15. [Integrate accepted work](#15-integrate-accepted-work)
16. [Stay synchronized](#16-stay-synchronized)
17. [Godot files and shared resources](#17-godot-files-and-shared-resources)
18. [Maintain relevant documentation](#18-maintain-relevant-documentation)
19. [Coordinate concurrent work](#19-coordinate-concurrent-work)
20. [Diagnose before repairing](#20-diagnose-before-repairing)
21. [Contributor routines](#21-contributor-routines)
22. [Command reference by effect](#22-command-reference-by-effect)
23. [Commands that need special care](#23-commands-that-need-special-care)

## 1. Purpose and shared policy

Git lets us preserve versions, compare changes, and combine reviewed contributions
without replacing another developer's work by guesswork. This handbook defines
the shared collaboration guidance; the companion applies it to existing clones
and complicated states. Game architecture remains in [Project structure](PROJECT_STRUCTURE.md),
not in the Git procedures.

### Team collaboration rules

- Normally develop on a coordinated development or focused feature branch. Keep
  shared `main` stable. Publish reviewed changes through the agreed Pull Request
  process; do not treat write access as permission to bypass review.
- Direct publication to `main` is an exception requiring explicit approval for
  that specific change and compliance with current repository rules. It is not
  the default contributor procedure taught below.
- Preserve unfinished work, including valuable untracked/ignored files. Inspect
  before switching or integrating; a branch or stash alone is not a complete backup.
- Stage explicit paths, review the complete staged contents, and exclude personal
  configuration, secrets, unrelated edits, caches, and backups. Ignore rules do
  not hide tracked changes from a commit.
- Resolve shared-file changes with the affected contributors. Preserve required
  behavior and original assets, validate in Godot, and update relevant documentation.
- Do not use destructive cleanup, forced publication, or history rewriting as an
  ordinary repair. Stop when the state or preservation of work is uncertain.

| Concept | What it determines |
| --- | --- |
| Repository permission | Which actions GitHub technically allows for an account |
| Team coordination | Who is changing overlapping work and how changes will be combined |
| Current responsibility | Who should be consulted about the affected system; assignments can change |
| Branch name | A useful label for a line of work, not a permanent feature permission |
| Integration approval | Whether the reviewed change may enter shared main |

One contributor may work across systems; several may work on one system. No
personal branch permanently owns cinematics, environments, mechanics, or any other
area. Examples such as `dev/contributor-name`, `feat/scene-transition`, and
`docs/git-handbook` are illustrative, not claims that those branches already exist.

**Verified repository facts:** inspection at documentation commit `da54a29` found
the HTTPS remote below, `main` as the remote default, `dev/*` development naming,
and historical `feat/*` integration naming. The project uses Godot 4.7.2. Fetch
current references when working; never use that historical hash as an instruction
to reset or freeze your repository.

**Policy versus enforcement:** this guide recommends review and coordinated
integration. It does not establish which GitHub rulesets, protected branches,
required checks/reviews, or merge methods are currently enabled. Check the live PR
and ask a maintainer. Never bypass a required approval. See
[GitHub branch protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches).

### Reading command examples

Examples use PowerShell and modern Git; `switch` and `restore` require Git 2.23
or newer. Use a currently maintained Git release. A code block is a step for a
particular state, not an instruction to run every block in this document.

Run commands one at a time and inspect each result. Windows PowerShell does not
automatically stop after a native Git command fails; check `$LASTEXITCODE`
immediately if the outcome is unclear. Stop before the next modifying command on
an unexpected nonzero result. Some inspection commands deliberately use nonzero
status for an answer, as explained in their procedure. Do not paste Bash `&&`
chains into Windows PowerShell 5.1.

Replace sample branch names with your coordinated names. Values read with
`Read-Host` are entered without extra quote characters; the commands quote variables
so paths containing spaces are passed as one argument. Do not type angle-bracket
placeholders literally into PowerShell. No example needs a fixed drive or username.

## 2. Git and GitHub fundamentals

Think of the working files as your desk, the index as the exact packet you have
selected, and a commit as a recorded version of that packet. Git does not commit
everything on the desk automatically.

| Term | Practical meaning |
| --- | --- |
| Git | Local version-control software; many actions work without a network |
| GitHub | Hosting, access control, and review service for a remote repository |
| Repository / clone | Project history and refs plus a local working checkout; a clone is another repository copy |
| Working directory / worktree | Files you currently edit; one repository can have multiple worktrees, but you do not need them to contribute |
| Index / staging area | Exact proposed contents of the next commit |
| Commit | Recorded tracked content, parent history, author metadata, and message |
| Branch | A movable name pointing to a commit; a new commit normally moves the current branch |
| HEAD | The checked-out commit, usually through a branch; detached HEAD has no current branch name |
| Remote | A named repository connection; its name is local configuration |
| `origin` | Conventional name assigned to the source remote by a normal clone; verify its URL |
| Local `main` | Your local branch; it can be old or differ from GitHub |
| `origin/main` | Your last-fetched remote-tracking record of main, not a live connection |
| Upstream / tracking configuration | Which remote branch a local branch uses for some comparisons and default operations; it is not necessarily main |
| Fetch | Download objects and update remote-tracking information without merging your current files |
| Pull | Fetch followed by integration into the current branch; options/configuration can select merge or rebase |
| Push | Ask a remote to update named refs from local history; it does not automatically merge a development branch into main |
| Merge | Combine histories; may move a pointer by fast-forward or create a merge commit |
| Rebase | Replay commits onto another base, producing new commit identities; not our default shared-history synchronization |
| Pull Request / PR | A proposed branch change reviewed against a base branch on GitHub |
| Merge conflict | Git cannot choose the combined result for some paths; human resolution is needed |

The ordinary lifecycle is:

```text
edit files -> select changes in index -> local commit -> development branch push
-> GitHub development branch -> Pull Request -> reviewed integration into main
```

A commit is not a remote backup until published to the intended remote. A branch
push is not a PR merge. Downloading main updates does not publish your edits.
For precise terminology see the [Git glossary](https://git-scm.com/docs/gitglossary).

## 3. Install and identify yourself

**Purpose:** obtain Git, a terminal, and the agreed engine. This is contributor
setup guidance, not a requirement to install an IDE or editor plugin.

1. Install Git for Windows from the [official download](https://git-scm.com/install/windows).
   Choose command-line availability for PowerShell; retain supported credential
   management unless your environment requires another approved setup.
2. Open PowerShell or a PowerShell terminal in your editor. Reopen the terminal
   after installation so its PATH refreshes.
3. Check installation:

```powershell
git --version
```

Expect a version string. If Git is not recognized, fix installation/PATH before
continuing; do not create another repository to solve a missing executable.

### Commit identity is not authentication

Your commit name/email identify authored history. They do not grant GitHub access.
Use your own agreed display name and a GitHub-verified email or GitHub-provided
no-reply address; commit metadata can become public. Inspect existing values first:

```powershell
git config --global --get user.name
git config --global --get user.email
```

No output/nonzero status can simply mean the setting is absent. If you want the
same identity as the default for all repositories on this account, set it explicitly:

```powershell
$CommitName = Read-Host 'Your public commit display name'
$CommitEmail = Read-Host 'Your verified or GitHub no-reply commit email'
git config --global user.name "$CommitName"
git config --global user.email "$CommitEmail"
```

These are global user settings and affect other repositories without local
overrides. If that is inappropriate, skip this change and set repository-local
identity after cloning instead. Do not copy a teammate's identity. See
[GitHub Git setup](https://docs.github.com/en/get-started/git-basics/set-up-git).

After choosing either setup, inspect the effective values rather than assuming
the write succeeded:

```powershell
git config --get user.name
git config --get user.email
```

Neither value should be blank, and both must identify the actual contributor.
Inside a clone, repository-local configuration can override global values; check
again there before committing. `git config --show-origin --get user.email` can
help identify an unexpected source locally. Do not share personal configuration
paths in a public troubleshooting log. Identity still does not authenticate you.

Install/open **Godot 4.7.2** and verify its version in the editor's About display
before allowing project conversion. Use the [README technology/setup](../README.md#technology)
for the project's engine and renderer baseline. Coordinate upgrades; a newer
installed engine is not permission to migrate shared files.

## 4. Authenticate and obtain access

For this repository, the standard clone URL is:

```text
https://github.com/AzureZephyry/withering-away-jam.git
```

Use your own GitHub account and the repository permissions assigned to it. Git
for Windows includes Git Credential Manager; supported HTTPS authentication can
open a browser for sign-in and two-factor authentication when required. Do not
put passwords/tokens in a command, URL, source file, screenshot, or shared log.
Public cloning may work without sign-in and does not prove write permission.
[GitHub's credential guidance](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git)
is the detailed reference for current setup.

SSH is optional, not mandatory. If you choose it, follow
[GitHub's SSH instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
and keep private keys private. Signing into GitHub in one browser does not by
itself prove that your terminal's Git credentials are correct.

| Failure class | First check | Safe response |
| --- | --- | --- |
| Authentication failed | Is the credential helper using the intended account? | Follow official helper/sign-in troubleshooting; never share credentials |
| Permission denied / write access missing | Does that account have permission for the destination? | Request access or an approved fork/PR route; do not bypass controls |
| Repository not found | Exact URL, repository visibility, account access | Ask a maintainer to confirm identity/access; it does not prove the repository was deleted |
| Could not resolve host / timeout | Network/DNS/connectivity | Fix connectivity and retry a read; do not rewrite history |

If a fork is the agreed route, fork on GitHub, clone your fork, and identify the
team repository as a separately named upstream remote. In that arrangement
`origin` means your fork, unlike this handbook's shared-clone examples. Inspect
both URLs, fetch main from the team remote, push only your fork branch, and open
a PR to the team repository's main. Have a maintainer confirm the mapping before
adapting commands; a fork is not permission to access or expose private material.
See [GitHub forks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/about-forks).

## 5. Clone once and verify the copy

**Before:** Git works; choose a local parent directory you control. There must not
already be a repository or valuable folder at the intended clone destination.
Cloning creates a directory and repository; it does not update an existing clone.

```powershell
$ParentFolder = Read-Host 'Existing parent folder for your clone'
Set-Location -LiteralPath "$ParentFolder"
Get-Location
Test-Path -LiteralPath 'withering-away-jam'
```

Inspect the location. If `Test-Path` is true, stop and inspect that folder. If it
is an existing clone, use the companion; if it contains other work, preserve it
and choose a different unused destination. Do not overwrite it or clone inside it.

**Only with an unused destination:**

```powershell
git clone https://github.com/AzureZephyry/withering-away-jam.git
```

Continue only if clone succeeded, then:

```powershell
Set-Location -LiteralPath 'withering-away-jam'
git rev-parse --show-toplevel
git remote -v
git branch --show-current
git status --short --branch --untracked-files=all
```

Expect the root of this clone, the intended team URL for fetch/push, the remote's
default branch (currently main), and no unexpected modified/untracked project
files. If the location, URL, branch, or content differs, diagnose before editing.
Cloning into a partially created folder after a failed download is not recovery;
inspect and preserve it first.

A downloaded ZIP is a file snapshot, not a normal Git clone with its `.git`
history/remotes. Do not initialize/replace an uncertain folder as a shortcut.
Preserve any ZIP-based edits outside the new clone and coordinate transferring
only reviewed changes into a proper clone.

If you skipped global identity setup, **inside the verified clone only** use:

```powershell
$CommitName = Read-Host 'Your public commit display name'
$CommitEmail = Read-Host 'Your verified or GitHub no-reply commit email'
git config --local user.name "$CommitName"
git config --local user.email "$CommitEmail"
git config --get user.name
git config --get user.email
```

This changes this repository's configuration, not all your repositories. Expect
your chosen effective identity. Resolve unexpected values before committing.

## 6. Import and run Godot

**Purpose:** verify that the clone can be used as a Godot project. **Before:** the
repository identity/version is confirmed, and initial status has been recorded.

1. Open Godot 4.7.2 Project Manager, choose Import, and select the clone's
   `project.godot`.
2. Open the project and allow resource import to finish. Inspect import/parser
   errors instead of assuming a successful clone proves resource validity.
3. Run F5 for the configured main opening, or open an intended laboratory and use
   F6. See [README setup and controls](../README.md#getting-started).
4. Stop the running scene and inspect Git status/diffs after the editor saves or
   imports. Generated cache files should follow the repository's ignore rules;
   source metadata changes still require review.

If resources fail to load, preserve error details and inspect dependency/UID
paths using [chapter 17](#17-godot-files-and-shared-resources) and the companion's
Godot conflict guidance. Do not delete resources or regenerate identities blindly.
Save/close Godot before branch switching or integration so an editor holding older
scene state cannot save over the newly checked-out files.

## 7. Choose a development branch

Normal work belongs on a coordinated personal development branch or a focused
feature/fix/docs branch. A personal branch can hold successive tasks, but a focused
branch can make review easier. Agree on the scope and base; naming does not assign
permanent ownership. Do not create duplicates simply because an existing branch
needs synchronization.

**New work is different from recovery.** Creating a branch from fetched main
starts new work; it does not repair an existing branch with unique commits or
save unfinished files. Do not replace that branch merely because it is behind
or diverged. Use the [companion's diagnosis](GIT_EXISTING_CONTRIBUTORS.md#2-establish-the-actual-repository-condition),
[preservation](GIT_EXISTING_CONTRIBUTORS.md#4-backup-and-preservation), and
[existing-branch update](GIT_EXISTING_CONTRIBUTORS.md#10-updating-an-existing-development-branch)
procedures. Replacing the development line requires a separately reviewed plan.

Inspect first:

```powershell
git branch
git branch -r
git branch -vv
git status
git fetch origin
git rev-parse origin/main
```

Fetch updates remote-tracking refs, not your branch/files. If fetch fails or main
does not exist, stop; do not base new work on an assumed current main. If you have
unfinished work or an operation in progress, use the companion before switching.

### New focused branch from verified main

**Before:** clean worktree/index, no operation in progress, valuable ignored files
preserved, Godot closed, current origin/main inspected, and an agreed unused name.

```powershell
$NewBranch = 'feat/interaction-improvements'
git check-ref-format --branch "$NewBranch"
git branch --list "$NewBranch"
git branch -r --list "origin/$NewBranch"
```

The first command must accept the name; both lists should be empty for a new
branch. If a name exists, inspect/reuse the intended branch or agree on another
name; do not delete an existing branch to make the example work.

**Only after those checks:**

```powershell
git switch --no-track -c "$NewBranch" origin/main
git branch --show-current
git status --short --branch
```

Expect the chosen local branch at the fetched main commit and no pending edits.
`--no-track` avoids accidentally giving a new feature branch `origin/main` as its
upstream; the first explicit development-branch push will establish tracking.
If switching fails, stop and inspect; never add a force option. See
[Git branch tracking](https://git-scm.com/docs/git-branch).

### Existing local or remote development branch

For a **verified existing local** branch, with the same clean/preservation gates:

```powershell
$ExistingBranch = 'dev/contributor-name'
git branch --list "$ExistingBranch"
```

If that is the intended existing local branch, switch without implicit guessing:

```powershell
git switch --no-guess "$ExistingBranch"
git branch -vv
```

If it exists **only on origin**, fetch and inspect its commits first. Only when
the local name is absent, the remote branch is verified, and it is the agreed base:

```powershell
git switch --track -c "$ExistingBranch" "origin/$ExistingBranch"
git branch -vv
```

Expect a local branch tracking the intended same-name remote. If Git reports the
branch is already checked out in another worktree, inspect `git worktree list`;
do not force it or remove that checkout. Existing divergent branches need the
companion, not this creation procedure.

## 8. Start a session deliberately

**Purpose:** know what is current before adding work. These inspections do not
repair anything; fetch only refreshes remote information.

```powershell
git rev-parse --show-toplevel
git branch --show-current
git status --short --branch --untracked-files=all
git branch -vv
git fetch origin
git rev-list --left-right --count origin/main...HEAD
```

For that exact comparison, the first count is main-only commits and the second
is current-branch-only commits. A clean status does not mean current or ready for
review. The branch's own upstream is a separate comparison.

If there is dirty work, an unfinished operation, missing refs, or divergence,
preserve work and follow [the companion](GIT_EXISTING_CONTRIBUTORS.md). Do not
run an unexplained pull. If current main is already contained and no other remote
reconciliation is needed, no merge is required just because you fetched. Coordinate
overlapping files/tasks before beginning edits.

## 9. Make a focused change

Work on the agreed objective, identify its dependencies, and avoid unrelated
refactoring or asset replacement. Two contributors can edit the same system, but
they should agree on which paths/properties each changes and the order of review.

For example, separate public Input Map and Autoload additions can both belong in
`project.godot`; accepting one entire version may remove the other. Likewise a
Player node change can affect hosting scenes and scripts that use its node paths.
Coordinate the intended combined behavior before resolving overlaps.

Run the affected scenes in Godot, check import/parser/runtime errors, and verify
the behavior claimed by your change. Shared panel/font/typewriter changes need
their relevant opening and exploration consumers checked. Use
[Project structure](PROJECT_STRUCTURE.md) to find dependencies and specialized
guides for system contracts. A prototype's successful test is not proof of a whole
chapter or unrelated system working.

## 10. Read status and differences

```powershell
git status
git status --short
git diff --stat
git diff
git diff --cached --stat
git diff --cached
git ls-files
```

`status` explains the branch and operation state. In ordinary short status, the
first column describes the index, the second the worktree. Conflict codes need
their own interpretation; do not treat them as ordinary edits.

| Example | Meaning |
| --- | --- |
| ` M path` | Modified working file, not staged |
| `M  path` | Modified version staged |
| `MM path` | Staged version plus additional unstaged edits |
| `A  path` | New path staged for addition |
| ` D path` / `D  path` | Unstaged / staged deletion |
| `?? path` | Untracked; not part of the next commit until added |
| `UU path` | One unmerged conflict form; resolve the operation deliberately |
| `!! path` | Ignored, shown only when ignored-file reporting is requested |

`git diff` compares worktree to index; `git diff --cached` compares index to HEAD.
Neither automatically displays untracked-file content. `git ls-files` lists
tracked/index paths, not every file on disk. See [Git status](https://git-scm.com/docs/git-status).

For a particular reviewed file:

```powershell
$ReviewPath = Read-Host 'Repository-relative file path to inspect'
git diff -- "$ReviewPath"
git diff --cached -- "$ReviewPath"
```

Inspect new files directly as well. For suspected ignored material, use
`git status --short --ignored --untracked-files=all` and
`git check-ignore -v -- "$ReviewPath"`. Ignored files can still be valuable.
An ignored rule does not stop a tracked file's changes being staged. Never assume
an import/metadata change is disposable solely because software generated it.

## 11. Stage only intended work

**Purpose:** assemble one coherent change. **Before:** correct development branch,
known existing index, completed relevant validation, and all intended public files
reviewed. Staging changes the index; it does not publish or erase working edits.

First inspect what is already staged. If unrelated staging exists, preserve it
and separate responsibilities; do not replace somebody else's index choices.

```powershell
git diff --cached --name-status
git diff --cached
```

Stage one reviewed path at a time or an explicit reviewed list:

```powershell
$ReviewedPath = Read-Host 'Reviewed public file to stage, relative to the repository'
git add -- "$ReviewedPath"
```

Repeat only for intended dependencies. For a script addition, include its required
UID; for an asset, inspect the source and corresponding import metadata. For
example, the existing GameState feature consists of script, UID, guide, and a
public Autoload registration—not just a script copied in isolation. This is a
dependency example, not permission to stage that system for an unrelated task.

**Binary review is a separate gate.** `git diff --cached` may report only that
binary files differ; it does not show their visual or audible substance. Preview
the exact staged asset version, not a later unstaged version with the same name,
and complete the [asset checks](#binary-assets-need-content-and-permission-review).
A familiar filename or successful whitespace check does not establish content,
quality, provenance, or permission to distribute it. Inspect diffs/assets in an
appropriate private local session; do not copy confidential content into logs.

If a tracked file mixes a public change with personal settings, whole-file staging
would include both. Stop for a carefully reviewed partial-staging plan if you
cannot prove separation. `git add -p` is an option for understood hunks, not a
guarantee of privacy; read the resulting staged file and full diff.

Before committing, require all four checks:

```powershell
git diff --cached --name-status
git diff --cached --check
git diff --cached
git status
```

Expect only approved paths/content; whitespace check should exit successfully
without findings. Investigate any unexpected file, missing dependency, unrelated
removal, secret, or conflict before committing. Later working edits are not included
unless you stage them again. See [Git add](https://git-scm.com/docs/git-add).

### Unstage one mistaken path without discarding its edits

**Before:** this repository has a HEAD commit, the path's staged content has been
reviewed, and restoring that path's index to HEAD will not erase another intended
partial-staging choice. Record/coordinate such choices first.

```powershell
$MistakenPath = Read-Host 'One mistakenly staged path to unstage'
git restore --staged -- "$MistakenPath"
git diff --cached --name-status
git status --short
```

The working file remains; the path's index entry returns to HEAD. For a newly
added file this usually leaves it untracked. This is not the same as restoring the
working file, reverting a commit, or resetting history. If the state differs or
pre-existing index choices need preservation, stop and use the companion. See
[Git restore](https://git-scm.com/docs/git-restore).

## 12. Create a coherent local commit

**Before:** the staged review in chapter 11 passed; identity is correct; no
unresolved operation exists; the commit represents one reviewable objective.
If something unrelated is staged, unstage it deliberately before committing.
New or changed binary assets must have passed the separate content/permission
review, with the staged version matching the version actually inspected.

Example message for an actual matching change—not an existing historical claim:

```powershell
git commit -m 'fix: restore camera after interaction'
```

A commit records the index and moves the current local branch. It does not upload
working changes or push GitHub. Messages should name the concrete result, such as
`feat: add approved scene transition`, `docs: update interaction guide`, or
`refactor: simplify shared scene setup`, when those accurately describe the work.

Verify the recorded result:

```powershell
git log -1 --format=fuller
git show --stat HEAD
git show --format=fuller HEAD
git status
```

Expect the intended message/author and only the reviewed files/content. Remaining
uncommitted edits may be intentional; they are not in that commit. If identity,
hooks, signing, or another check prevents committing, read the error and stop to
resolve that cause. Do not bypass required checks. If an accidental commit was
made, use the companion before amending or rewriting anything that may be shared.
For binary files, inspect the committed version and its dependencies as well;
the text shown by `git show` cannot substitute for that content review.

## 13. Push the intended development branch

**Purpose:** publish reviewed local commits to the intended development branch,
not main. **Before:** commit verified, exact branch agreed, no accidental private
history, correct remote/access, and relationship to the destination understood.
Working files need not be clean for Git to push commits, but unfinished work is
not uploaded and must not be mistaken for part of the publication.

Set the example to your agreed development name, then inspect:

```powershell
$PublishBranch = (Read-Host 'Agreed development branch to publish').Trim()
if ([string]::IsNullOrWhiteSpace($PublishBranch)) { throw 'An explicit development branch is required.' }
git check-ref-format --branch "$PublishBranch"
if ($LASTEXITCODE -ne 0) { throw 'Invalid branch name.' }
git branch --show-current
git rev-parse HEAD
git remote -v
git branch -vv
git fetch origin
git branch -r --list "origin/$PublishBranch"
```

The current branch must equal `$PublishBranch`, not be detached or main. A new
destination should be absent; if it unexpectedly exists, inspect it rather than
overwriting another contributor's branch. For an existing destination, compare:

```powershell
git rev-list --left-right --count "origin/$PublishBranch...HEAD"
git log --oneline "HEAD..origin/$PublishBranch"
git log --oneline "origin/$PublishBranch..HEAD"
```

The destination must contain no unintegrated remote-only commits for this normal
fast-forward publication. If it does, reconcile through the companion first.

### Review outgoing history before any push

The index, final file tree, and outgoing commit history are **separate review
surfaces**. Suppose commit A adds a private file and commit B deletes it. A final
tree comparison may show no file, but publishing history containing A can still
expose its contents. A clean status, successful synchronization, or valid
fast-forward does not certify privacy. Deleting the file later is not remediation.

First verify the fetch and push URLs refer to the same intended repository:

```powershell
git remote get-url --all origin
git remote get-url --push --all origin
```

If they point to different repositories or multiple push destinations, stop for
an exact remote/ref mapping; do not audit one repository and push to another.
Fork users must adapt `origin` to the verified publication remote from
[chapter 4](#4-authenticate-and-obtain-access). Its development destination is
not necessarily the team main. Fetch must have succeeded, the destination's
existence/current tip must be confirmed against the server, and relevant history
must be available. A stale remote-tracking ref, shallow history, restricted fetch
mapping, or inaccessible ref requires investigation, not a guessed baseline.

Record the exact proposed tip; stop on any failed inspection:

```powershell
$PublishTip = (git rev-parse --verify 'HEAD^{commit}').Trim()
if ($LASTEXITCODE -ne 0) { throw 'Proposed commit is unavailable.' }
git ls-remote --heads origin "refs/heads/$PublishBranch"
```

A successful listing with no matching ref means a new destination; a network or
permission error does not. If it exists, its full hash must match the fetched
destination used below. If it was deleted or advanced since fetching, stop and
refresh/diagnose before selecting the review set.

**Existing verified remote branch:** inspect everything reachable from the
proposed tip but not from that destination's recorded tip:

```powershell
$DestinationTip = (git rev-parse --verify "refs/remotes/origin/${PublishBranch}^{commit}").Trim()
if ($LASTEXITCODE -ne 0) { throw 'Verified destination snapshot is unavailable.' }
git log --topo-order --reverse --format='%H %P' "$DestinationTip..$PublishTip"
git log --format='%H' --name-status --root -m --no-renames "$DestinationTip..$PublishTip"
```

`D..T` means commits reachable from T excluding those reachable from D. This
includes side histories brought by merges, even when the final tip removed their
files. It may conservatively include commits already on another server branch;
it is the new history for **this destination**, not an exact transfer-byte list.
Do not restrict this audit to today's files, first-parent history, or a short
recent-commit limit. `origin/main..HEAD` answers this question only when main is
the actual verified publication destination.

**New remote branch:** there is no destination tip to subtract. Review its full
reachable history, including root commits and merged histories:

```powershell
git log --topo-order --reverse --format='%H %P' $PublishTip
git log --format='%H' --name-status --root -m --no-renames $PublishTip
```

Creating a branch can expose old local history, not just the latest patch.
Already-published ancestry can reuse a trustworthy prior review, but do not
assume all ancestry is public or safe because the branch starts near main.
As an **additional triage view**, after verifying the fetched remote refs:

```powershell
git rev-list $PublishTip --not --remotes=origin
```

This lists commits not reachable from locally known remote-tracking branches of
that remote. It is not a complete server inventory or privacy certificate: fetch
scope can omit refs, stale refs can exclude history incorrectly, and tags/hidden
refs are not represented by that option. Do not exclude other remotes, local
branches, or stashes as though their contents were already safely published to
this server. This triage does not replace the full new-branch review.
See [Git traversal options](https://git-scm.com/docs/git-rev-list).

The commands above show identifiers and changed paths, **not a content audit**.
In a private local history viewer, inspect each relevant commit's actual patch
and versions of added/modified/deleted files. `git show` can inspect a selected
commit or historical file locally; review deleted content from its earlier
version too. Inspect merge-result trees against their parents, root-commit
contents, commit messages/metadata, and historical binary assets where relevant.
Neither a path-only list nor one combined merge diff proves those contents safe.
Use [binary asset review](#binary-assets-need-content-and-permission-review) for
historical assets as well. Do not dump suspected secrets into shared terminals,
CI output, public logs, screenshots, or support messages.

**Stop publication** on private material, unexpected paths/history, incomplete
history, or uncertainty about the review set. Consult the maintainer through a
private channel for a preservation/remediation plan. Actual exposed credentials
require prompt revocation/rotation and appropriate incident handling; deletion
in a later commit is insufficient. Do not automatically rewrite history or force
push. See [Git revision ranges](https://git-scm.com/docs/gitrevisions) and
[GitHub sensitive-data handling](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).

### Preview, publish, and verify the exact destination

**Only after branch, URL, destination, content, and outgoing-history checks**,
confirm HEAD still equals `$PublishTip`, then preview the exact ref update.
If the proposed tip or remote destination changes, repeat the relevant review;
do not silently publish a different commit:

```powershell
$CurrentPublishTip = (git rev-parse --verify 'HEAD^{commit}').Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($PublishTip) -or
    $CurrentPublishTip -ne $PublishTip) { throw 'Proposed tip changed; repeat the publication review.' }
git push --dry-run --no-follow-tags origin "HEAD:refs/heads/$PublishBranch"
```

Read the target URL and branch. A dry run is a preview, not a lock or proof the
next push will succeed. For a new branch, or when intentionally establishing the
verified upstream, publish only after the preview is correct:

```powershell
git push --no-follow-tags -u origin "HEAD:refs/heads/$PublishBranch"
```

`-u` establishes tracking for this branch. With the checked-out branch name equal
to `$PublishBranch`, `git push --no-follow-tags -u origin "$PublishBranch"` is a
same-name form; do not use a
name referring to another local branch by mistake. The explicit examples use
`--no-follow-tags` because `push.followTags` configuration could otherwise add
annotated tags even with a branch refspec. Tags need a separate content/metadata
and destination review; they are not part of this branch-only workflow.
For subsequent publications to that verified destination:

```powershell
git push --no-follow-tags origin "HEAD:refs/heads/$PublishBranch"
```

Plain `git push` is optional only after verifying its upstream and effective push
configuration/preview. It can be affected by push defaults, refspecs, and remote
overrides; do not infer the target from the word `origin` in status. If uncertain,
use the explicit destination above instead of changing global defaults. See
[Git push refspecs and defaults](https://git-scm.com/docs/git-push).

Verify receipt:

```powershell
git rev-parse HEAD
git ls-remote origin "refs/heads/$PublishBranch"
git branch -vv
```

Expect the remote ref's hash to match the intended pushed commit at that moment;
also inspect the branch on GitHub. If another contributor advanced it meanwhile,
fetch and inspect whether your commit is included. On rejection, network failure,
permission failure, or an unexpected target, stop and diagnose; never add force.

## 14. Prepare and review a Pull Request

**Before:** the intended development branch is published and its included history
and files are reviewed. A synchronized branch is not automatically integration-ready.

1. On GitHub open a PR to the team repository. Set **base** to main and **compare**
   to the intended development branch, including correct repository/account for forks.
2. Review both the commit list and **Files changed**. A long-lived branch can
   include old/unrelated work even when today's change is small.
3. Describe the problem/result, meaningful tests actually performed, dependencies,
   limitations, and relevant documentation. Do not claim unperformed tests passed.
4. Request the agreed reviewer(s). Draft status is appropriate while incomplete;
   ready-for-review status is not an approval.
5. Respond with focused corrective commits, retest affected behavior, push only
   the intended branch, and inspect the PR again.

Local inspections to help review, after fetching:

```powershell
git log --oneline origin/main..HEAD
git diff --stat origin/main...HEAD
git diff origin/main...HEAD
```

The three-dot diff compares the merge base to HEAD; it is a proposed branch patch,
not proof of the final integrated tree. Two-tip comparison `git diff origin/main HEAD`
answers a different question. Maintainers must also consider current main changes,
conflicts, and an actual combined result where needed. Squash history can leave
old branch commits listed again; do not rewrite a shared branch casually to hide
the symptom. See [GitHub branch comparisons](https://docs.github.com/en/pull-requests/reference/branches).

If unrelated changes appear, stop integration and coordinate separating the work;
do not assume the PR title limits what will merge. Follow
[GitHub's PR creation guidance](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)
for current UI details. Required checks/reviews and repository permissions still apply.

## 15. Integrate accepted work

Contributors prepare, test, document, publish a development branch, and respond to
review. Maintainers verify approval, scope, current main, dependencies, combined
behavior, and the repository's permitted integration method before merging.

**Maintainer gates:** inspect unique commits and actual file changes; confirm no
private/unrelated material; verify relevant Godot behavior and documentation;
resolve review findings; obtain required approval; recheck conflicts/checks against
current main. A newer main may require another candidate test or review.

Use the agreed GitHub integration process. Merge commit, squash, and rebase methods
have different history effects and may not all be enabled. Do not bypass rules or
choose a method merely to conceal problematic history. See
[GitHub merge methods](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/about-merge-methods-on-github).

**After integration:** verify the PR's merged state, resulting commit, and intended
files on main. Fetch and inspect locally without changing your current branch:

```powershell
git fetch origin
git log -5 --oneline origin/main
git show --stat origin/main
```

Identify the actual integration commit if main has advanced again. A squash/rebase
can change hashes; absence of an original feature SHA in ancestry does not alone
prove missing implementation. Conversely, ancestry alone does not prove an older
implementation survived later changes. Inspect the resulting tree and behavior.
Only then report publication, and notify affected contributors through the team's
agreed channel. Coordinate their synchronization; do not alter their clones for them.

## 16. Stay synchronized

Main and your own remote development branch can advance independently. Fetch
refreshes knowledge; it does not bring those changes into your current files.
Compare both relationships. A branch can be clean, ahead of its upstream, and
missing main changes at the same time.

If HEAD is an ancestor of the desired source and the preservation gates pass,
a fast-forward can move the branch without a merge commit. If each side has unique
commits, integration needs a deliberate plan. `git pull` can fetch and then merge
or rebase according to configuration; it is not our diagnostic shortcut for an
uncertain clone. Explicit `pull --ff-only` is limited to the correct verified
upstream and does not resolve divergence. See [Git pull](https://git-scm.com/docs/git-pull).

The [existing-contributor companion](GIT_EXISTING_CONTRIBUTORS.md) provides the
separate procedures for own-remote updates, main integration, dirty work,
divergence, temporary candidate branches, and recovery. Do not run every procedure.
Fetch at sensible checkpoints and before review; stop to preserve unfinished work
before an operation that changes its base.

## 17. Godot files and shared resources

### Repository rules actually inspected

| Material | Current handling and reason |
| --- | --- |
| `.godot/` | Ignored project cache, including imported cache data; not a source asset |
| Root `/android/` | Ignored by this repository's current rule; this does not mean every arbitrary Android-related source should be discarded |
| `.gd`, `.tscn`, `.tres`, shaders, `project.godot` | Source/scripts/scenes/resources/settings; review intended changes and dependencies |
| Script/shader `.uid` files | Required resource identities are tracked; keep with their scripts/resources |
| Source PNGs/fonts and adjacent `.import` metadata | Tracked source/import settings; not the same as `.godot/imported/` cache |
| `.gitattributes` | `* text=auto eol=lf`, normalizing files Git identifies as text to LF |
| Large binary assets | Review content/size/permission; the repository declares no LFS tracking patterns or `.lfsconfig` at this inspection |

Shared `.gitignore` rules are versioned. Repository-local exclusions and a user's
global ignore rules may also hide untracked files; they do not protect changes
to tracked files or remove sensitive content already committed. In a linked
worktree, resolve metadata paths with Git rather than assuming `.git` is a directory.
Inspect the actual index/history before publication. See [Git ignore rules](https://git-scm.com/docs/gitignore).

Do not ignore all generated-looking files. Godot's import sidecars contain useful
settings, while imported cache lives separately. See the official
[import process](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/import_process.html).
Script/shader UID sidecars support stable identity; preserve them when moving files
and inspect references. See [Godot UID guidance](https://godotengine.org/article/uid-changes-coming-to-godot-4-4/).

Installed Git LFS software or local filters do not establish project LFS policy.
Do not introduce LFS, migrate history, or change attributes as part of a routine
asset contribution. Coordinate any future large-asset storage decision first.

The existing attributes already establish text line endings; do not change global
line-ending defaults or renormalize the entire project to solve a local warning.
Inspect actual diffs and coordinate necessary changes. Read
[Git attributes](https://git-scm.com/docs/gitattributes) and
[Godot version-control guidance](https://docs.godotengine.org/en/4.7/tutorials/best_practices/version_control_systems.html).

### Binary assets need content and permission review

For PNG sprite sheets, dialogue artwork, audio, fonts, and other binary resources,
a text diff usually cannot reveal the actual image, sound, or glyphs. Review the
exact proposed asset using an appropriate viewer or Godot, alongside its staged
identity and resource metadata:

- Confirm the intended file/version and original source; compare it with the
  accepted version rather than trusting a familiar filename. A hash can identify
  bytes, but does not prove authorship, quality, or permission.
- Establish authorship/provenance and permission to use **and distribute** it.
  Check the applicable license or contributor agreement and any attribution
  requirements. Do not invent rights; unresolved permission blocks publication.
  An existing established permission can suffice; not every asset needs a new
  license document.
- Preview sprites/UI at the intended pixel scale, listen to audio, and inspect
  font rendering. Check required import settings, filtering, dimensions, and
  associated `.import`/UID/resource references as applicable.
- Determine whether this replaces existing artwork/audio. Preserve originals
  unless replacement is explicitly accepted, and coordinate conflicting versions.
- Open dependent scenes/resources and test affected behavior; check that a new
  resource did not silently change other consumers or introduce missing paths.

Record real validation and any limitations with the contribution. If the index
and working file differ, preview the staged version separately without replacing
the working file. A clean text merge or successful import alone is not asset
approval. Repeat the relevant checks if the asset changes after review.

### Why shared files need semantic review

- `project.godot` combines main scene, display, Input Map, Autoload, and other
  settings. Merge the intended public settings, not one contributor's whole file.
  Personal additions in a tracked file are not protected by an ignore pattern.
- `.tscn` files combine node hierarchy, script attachment, subresources, resource
  IDs, UID/path references, and connections. A text merge can be syntactically
  accepted by Git yet break runtime node paths or remove behavior.
- A shared Player, SpriteFrames, panel, or typewriter has multiple consumers.
  Check every affected host; do not validate only the scene you edited.
- Original artwork/audio and binary resources need agreed versions or deliberate
  edits; Git cannot combine image pixels as it combines text. Preserve both
  candidates outside the project while coordinating when necessary.
- Moving/renaming resources requires checking UID sidecars, scene references,
  preloads, node paths, and signals. Do not regenerate IDs just to clear an error.

After integration, let Godot import, open affected resources/scenes, check parser
and runtime errors, inspect Autoload/Input Map/main scene, and run affected entry
points. Verify movement/collisions, animation, camera, and dialogue if their shared
dependencies changed. Close the game and review any additional editor-generated
diffs before publishing. See the companion for combined shared-file conflicts.

## 18. Maintain relevant documentation

Meaningful accepted changes require evaluating their documentation impact and
reviewing the relevant guide with the implementation. Follow the
[README maintenance mapping](../README.md#keeping-the-documentation-accurate).

Architecture/file changes affect [Project structure](PROJECT_STRUCTURE.md); approved
runtime/story-flow changes affect [Game flow](GAME_FLOW.md); important decisions
affect [Design decisions](DESIGN_DECISIONS.md). Update [Team progress](TEAM_PROGRESS.md)
and [Development history](DEVELOPMENT_HISTORY.md) when confirmed status or an enduring
published milestone materially changes. Interaction/animation/state contracts
belong in their specialized guides; contributor-policy changes belong in this
handbook and affected companion procedures.

Do not rewrite every document for each test or trivial edit. Preserve evidence:
accepted, implemented locally, tested, committed, and published are different
states. Do not record experiments as completed milestones or claim a failed push
was publication.

## 19. Coordinate concurrent work

Discuss overlapping scene/settings/resource edits before starting, especially
shared infrastructure. Agree on interfaces, intended public settings, affected
paths, and a review order; use small coherent commits and avoid unrelated cleanup.
Assignment tables help find collaborators, not prohibit future cross-system work.

Share the relevant branch/commit, reproducible steps, exact error, and affected
files when handing off. Remove secrets and personal details before sharing logs.
Announce meaningful main updates so others can fetch and plan synchronization.
Use the team's agreed communication channel; this guide does not require a new
platform. Respect review feedback, give conflicts time, and preserve both people's
work while deciding the combined result.

## 20. Diagnose before repairing

Begin with the inspection commands in chapter 8. `git status` without `--short`
is particularly useful for operation-in-progress instructions. Do not stack more
mutation commands onto an unexplained failure.

| Symptom | What to inspect first | Next step |
| --- | --- | --- |
| Not a Git repository / wrong folder | Location and known clone directory | Locate the existing clone; do not initialize over uncertain files |
| Missing/wrong remote or access error | Remote URLs, account, permission, network | [Authentication](#4-authenticate-and-obtain-access) |
| Empty branch name / detached HEAD | `git status`, HEAD, recent log | Preserve any commits; companion recovery before switching |
| Dirty/untracked files would be overwritten | Full status, diff, valuable ignored files | Companion preservation before synchronization |
| Conflict / unfinished merge | Full status, unmerged paths, operation identity | Companion conflict/interrupted-operation chapters |
| Behind or diverged | Own upstream and main comparisons separately | Companion branch-state procedure |
| Non-fast-forward rejection | Correct push destination and freshly fetched destination commits | Companion reconciliation; no force shortcut |
| Missing Godot scene/UID/resource | Actual path, UID and scene/script dependencies, engine errors | [Godot checks](#17-godot-files-and-shared-resources) and companion |

For a request for help, share sanitized diagnostics and what you intended. Never
delete lock files, branches, worktrees, or repository metadata merely because a
generic error suggests a problem. The companion includes a symptom index and
safe escalation package.

## 21. Contributor routines

| Moment | Short routine and detailed reference |
| --- | --- |
| First setup | Install/authenticate → clone/verify → import Godot → create/track agreed development branch; chapters 3–7 |
| Start a session | Root/branch/status → fetch → compare own remote and main → preserve/plan if needed; chapter 8 and companion |
| Before committing | Test relevant behavior → update affected docs → explicit paths → complete staged review/whitespace check; chapters 9–12 |
| Before pushing | Verify local commit/history/privacy → branch/upstream/URL/destination → preview → normal explicit push → remote verification; chapter 13 |
| Before PR | Correct repository/base/compare → inspect unique commits and file diff → record real tests/limits → request review; chapter 14 |
| Before integration | Approval/checks → current main/conflicts → tested combined content/dependencies → permitted method → verify main; chapter 15 |
| After meaningful main change | Notify collaborators → fetch → inspect changes → controlled synchronization → test; chapter 16 and companion |
| Return after absence | Preserve unfinished work and diagnose before resuming; companion returning-contributor procedure |

These checklists navigate the detailed gates; they do not authorize running every
command in sequence or ignoring an unexpected result.

### Worked first contribution: one public documentation correction

This is hypothetical, not a real task or publication record. Suppose the team
accepts a correction to one public README paragraph, with no gameplay change:

1. [Clone and verify](#5-clone-once-and-verify-the-copy) the team repository after
   setup/authentication; [import Godot](#6-import-and-run-godot) to confirm the
   baseline. An existing clone takes the companion route instead of cloning again.
2. Agree on an unused focused name such as `docs/clarify-setup`, then
   [create a new branch](#7-choose-a-development-branch) from verified fetched main.
3. Edit only the approved paragraph. [Inspect status and the diff](#10-read-status-and-differences),
   check accuracy/links, and preserve unrelated local changes.
4. [Stage only README.md and inspect the complete index](#11-stage-only-intended-work),
   then [commit](#12-create-a-coherent-local-commit) with a matching message such
   as `docs: clarify setup instructions`. Inspect the resulting commit.
5. [Review outgoing history](#review-outgoing-history-before-any-push), including
   the full new-branch ancestry, and verify the remote/destination before the
   preview and explicit normal branch push. Confirm GitHub received the intended tip.
6. [Open a PR](#14-prepare-and-review-a-pull-request) from that branch to the team
   repository's main. Review commits/files, describe the checks actually done,
   and obtain the agreed review and any required checks.
7. A permitted maintainer [integrates the accepted change](#15-integrate-accepted-work).
   Verify the merged PR and resulting main content; account for changed commit
   IDs under squash/rebase. Only then describe the correction as published to main.

These steps reuse the detailed prerequisites above; the example does not grant
permission to publish an unrelated change or bypass a repository rule.

## 22. Command reference by effect

| Class | Examples | Effect and condition |
| --- | --- | --- |
| Inspection | `git status`, `git diff`, `git log`, `git show`, `git branch -vv`, `git ls-files`, `git rev-parse` | Describe files/history/refs; interpret the exact arguments |
| Remote inspection | `git ls-remote origin` | Contacts remote and reads advertised refs; credentials/network may be needed |
| Remote-reference update | `git fetch origin` | Downloads objects/updates remote-tracking information; does not integrate your current branch |
| Index modification | `git add -- path`, `git restore --staged -- path` | Changes proposed commit contents; requires reviewed paths and awareness of prior staging |
| Worktree/ref modification | `git switch`, `git merge`, `git pull`, stash save/apply | May replace files and/or move refs; use only the state-specific prerequisites |
| Local history creation/change | `git commit`, rebase/cherry-pick | Records staged work or produces/replays commits; not equivalent operations |
| Remote publication | `git push` | Updates specified remote refs after permission/fast-forward checks; never assume a destination |

An inspection can fail when a ref/path is missing. Nonzero exit status is not
always data loss: for example an ancestry test uses status to answer a question.
Do not run a modifying command merely to make an expected diagnostic exit code
become zero. Use official `git help`/manuals when semantics are uncertain.

## 23. Commands that need special care

The following are risk explanations, not a repair script. Legitimate advanced
uses require exact state inspection, preservation, coordination, and appropriate
approval. Beginner synchronization should follow the companion's preservation-safe
procedures instead.

| Command/pattern | Why it is not an ordinary shortcut |
| --- | --- |
| `git reset --hard` | Replaces tracked index/worktree content and can move the current ref; can destroy unfinished edits |
| `git clean` | Can delete untracked files, and with additional options ignored material too; a Git branch cannot recover files never committed |
| `git switch -f` | Can discard changes blocking a switch rather than preserving them |
| `git push --force` / forced refspecs | Can replace remote history and overwrite teammates' work; lease variants are still history rewrites requiring review |
| `git rebase` | Replays commits with new identities; inappropriate as a cosmetic rewrite of shared published history |
| `git cherry-pick` | Replays selected changes into new commits; does not integrate all ancestry/dependencies automatically |
| `git merge -s ours` | Records ancestry while keeping the current tree, not the other side's implementation; can hide lost legitimate changes |
| `git checkout --ours` / `git checkout --theirs` | Whole-side choices can lose valid settings/resources; side meaning depends on operation, especially rebase |
| `git add .` / `git add -A` | Broad staging can include unrelated, personal, deleted, or generated content; review explicit paths instead |
| `git restore --worktree` | Replaces working files; not the same as index-only unstaging |
| Broad stash of ignored files | Can remove local configuration/assets from the worktree; an external verified backup and explicit plan may be needed |

There is no universal “just pull,” “just stash,” “take theirs,” or “reset to main”
procedure. If data, history, or the expected combined implementation is uncertain,
preserve what exists and use [the companion](GIT_EXISTING_CONTRIBUTORS.md) before
proceeding.

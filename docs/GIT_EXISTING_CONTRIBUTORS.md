# Git companion for existing contributors

This is the existing-repository companion to the authoritative
[Git collaboration handbook](GIT_WORKFLOW.md#1-purpose-and-shared-policy).
Its shared policies apply throughout this guide. Start with the parent if you
need installation, authentication, Git fundamentals, first-commit instructions,
review policy, or permission guidance. Start with [README](../README.md) for
Godot setup and controls.

## Contents

1. [When to use this companion](#1-when-to-use-this-companion)
2. [Establish the actual repository condition](#2-establish-the-actual-repository-condition)
3. [Working-tree cleanliness](#3-working-tree-cleanliness)
4. [Backup and preservation](#4-backup-and-preservation)
5. [Inspecting branch relationships](#5-inspecting-branch-relationships)
6. [Clean branch, no synchronization needed](#6-clean-branch-no-synchronization-needed)
7. [Branch behind main](#7-branch-behind-main)
8. [Branch with unique commits](#8-branch-with-unique-commits)
9. [Diverged branches](#9-diverged-branches)
10. [Updating an existing development branch](#10-updating-an-existing-development-branch)
11. [Handling uncommitted work](#11-handling-uncommitted-work)
12. [Merge conflicts](#12-merge-conflicts)
13. [Godot-specific conflict resolution](#13-godot-specific-conflict-resolution)
14. [Replaced or obsolete implementations](#14-replaced-or-obsolete-implementations)
15. [Interrupted operations](#15-interrupted-operations)
16. [Non-fast-forward push rejection](#16-non-fast-forward-push-rejection)
17. [Local and remote branch confusion](#17-local-and-remote-branch-confusion)
18. [Temporary synchronization branches](#18-temporary-synchronization-branches)
19. [Rebase, cherry-pick, and history rewriting](#19-rebase-cherry-pick-and-history-rewriting)
20. [Recovering accidentally staged changes](#20-recovering-accidentally-staged-changes)
21. [Recovering accidental commits](#21-recovering-accidental-commits)
22. [A successful merge that breaks Godot](#22-a-successful-merge-that-breaks-godot)
23. [Returning after an absence](#23-returning-after-an-absence)
24. [Troubleshooting by symptom](#24-troubleshooting-by-symptom)
25. [Guided scenarios](#25-guided-scenarios)
26. [Pre-synchronization checklist](#26-pre-synchronization-checklist)
27. [Post-synchronization checklist](#27-post-synchronization-checklist)
28. [Safe escalation](#28-safe-escalation)

## 1. When to use this companion

Use this when you already have a clone or worktree and need to understand its
condition before updating, publishing, or recovering. A clean checkout can have
old history; a dirty checkout can contain valuable work that GitHub has never
received. Neither condition should be guessed from the editor or a branch name.

**I already have the repository. What should I do first?**

```text
Confirm repository, branch, remotes, status, HEAD and upstream (chapter 2)
  |
  +-- Wrong repository or unexpected branch? Stop; identify the intended copy.
  +-- Merge/rebase/cherry-pick active, conflicts, detached HEAD? Chapter 15.
  +-- Modified/staged/untracked/valuable ignored work? Chapters 3, 4 and 11.
  |
Fetch, then compare separately with own upstream and origin/main (chapter 5)
  |
  +-- Own upstream advanced? Reconcile it deliberately first (chapter 10).
  +-- Current branch already contains main? No main merge needed (chapter 6).
  +-- Branch is an ancestor of main? Consider a reviewed fast-forward (chapter 7).
  +-- Both sides have unique commits? Inspect, preserve and plan (chapters 8–9).
  +-- Push rejected? Diagnose the destination and history (chapter 16).
```

This is a decision tree, not an instruction to execute every command below.
Commands under **Conditional action** change something; read their prerequisites
first. Commands under **Inspect** do not intentionally alter project content.
Fetch changes repository metadata and remote-tracking references, not your
checked-out branch or files. None of these chapters grants integration permission
or changes the parent's review rules.

**Remote assumption:** examples using `origin/main` assume `origin` points to the
authoritative team repository. In a fork workflow, `origin` may be your fork and
a separate remote such as `upstream` may point to the team. Verify fetch/push URLs
and adapt both team-main and own-development references **before** following a
synchronization procedure. The name `origin` alone proves nothing. Do not change
remote configuration automatically; consult the parent's
[authentication and fork route](GIT_WORKFLOW.md#4-authenticate-and-obtain-access)
when the mapping is unclear.

### Find your situation

| Situation | Start here |
| --- | --- |
| Unfinished edits, valuable untracked or ignored files | [Inventory](#3-working-tree-cleanliness), [backup](#4-backup-and-preservation), [handling unfinished work](#11-handling-uncommitted-work) |
| Behind team main | [Relationships](#5-inspecting-branch-relationships), [simple fast-forward](#7-branch-behind-main) |
| Unique commits or divergence | [Unique work](#8-branch-with-unique-commits), [divergence](#9-diverged-branches) |
| Own remote development branch advanced | [Own-upstream reconciliation](#10-updating-an-existing-development-branch) |
| Merge conflict | [Conflict state](#12-merge-conflicts), [Godot resolution and testing](#13-godot-specific-conflict-resolution) |
| Interrupted operation or uncertain detached state | [Operation diagnosis](#15-interrupted-operations) |
| Rejected push | [Destination and remote history](#16-non-fast-forward-push-rejection) |
| Returning after an absence | [Returning-contributor procedure](#23-returning-after-an-absence) |
| Suspected private content, even if deleted later | [Parent outgoing-history review](GIT_WORKFLOW.md#review-outgoing-history-before-any-push), [safe escalation](#28-safe-escalation) |

Examples such as `dev/contributor-name`, `feat/interaction-improvements` and
`feat/sync-main-review` are illustrative. They are not guaranteed to exist.
Branch naming does not assign permanent gameplay ownership. Coordinate edits
with current collaborators, including when working across different systems.

Use a current supported Git for Windows. `git switch` and `git restore` require
Git 2.23 or newer. In PowerShell, quote names such as `'@{upstream}'`; otherwise
the shell may interpret them. Replace sample branch names before mutation.
Do not paste angle-bracket placeholders into a command.
Run native Git commands one at a time and inspect the result before the next
step. Windows PowerShell does not automatically stop a command block when Git
returns a nonzero exit code; the explicit guards below cover selected critical
steps, not every possible failure. A diagnostic exit code such as ancestry test
`1` has a documented meaning, so interpret it rather than treating all nonzero
codes identically.
Inspect diagnostic output in a private local session: diffs, stash patches,
history metadata, and paths may contain confidential material. Sanitize anything
shared for help; do not send raw suspected secrets to public logs or screenshots.

## 2. Establish the actual repository condition

**Purpose:** identify the copy, branch, saved history, and unpublished work.
**Prerequisite:** open PowerShell in the intended repository; do not switch
branches to make its output fit an expectation.
**Safety:** this inspection does not stage, commit, or change checked-out files.
Avoid sharing remote URLs publicly until you have checked them for credentials.

**Inspect:**

```powershell
git rev-parse --show-toplevel
git remote -v
git branch --show-current
git rev-parse HEAD
git status --short --branch --untracked-files=all
git status
git branch -vv
git log --oneline --decorate -12
git worktree list --porcelain
```

Check these results before proceeding:

| Output | Expected meaning | Stop condition |
| --- | --- | --- |
| Repository root | The intended local copy of Withering Away | Wrong location or `not a git repository` |
| Remotes | Intended fetch/push destinations; the team repository is `AzureZephyry/withering-away-jam` | Unexpected remote, credentials in URL, or fork mistaken for team repository |
| Current branch | The development branch you intend to update | Blank means detached HEAD; another branch means investigate |
| HEAD | A full commit identifier to record with your backup notes | Unknown or unresolvable commit |
| Long status | Also reports operations/conflicts | Any interrupted operation goes to chapter 15 |
| `branch -vv` | Current branch marked `*`, its upstream and last fetched ahead/behind summary | Wrong or missing upstream must be understood, not silently replaced |
| Worktrees | Other checkouts sharing branch/ref storage | Do not switch or update a branch checked out in another worktree |

**Conditional action — refresh remote information:** only after verifying the
remote and obtaining access. If an operation is interrupted, record its current
state first; fetching can wait until the recovery plan is clear.

```powershell
git fetch origin
```

Check that fetch succeeded before using new remote information:

```powershell
git rev-parse --verify origin/main
git branch -vv
```

**Expected outcome:** the remote main resolves and comparisons use the fetched
snapshot. No local branch has moved. If access, network, remote, or ref errors
occur, stop synchronization. Existing remote-tracking references can be stale.
Do not reclone, rename remotes, or change authentication settings as a guess.

## 3. Working-tree cleanliness

Short status normally has two columns: the first describes the index and the
second describes the working copy. `M ` is staged modification; ` M` is unstaged;
`MM` has both. `A ` is staged addition, `D` a deletion, `??` untracked, and
unmerged combinations such as `UU` need conflict resolution. Long status explains
the current operation. See the official [status format](https://git-scm.com/docs/git-status#_short_format).

**Inspect — inventory before preservation:** run from the repository root.

```powershell
git status --short --branch --untracked-files=all
git diff --stat
git diff
git diff --cached --stat
git diff --cached
git ls-files --others --exclude-standard
git ls-files --others --ignored --exclude-standard
git stash list
```

**Expected outcome:** you can explain every modification, staged hunk, addition,
deletion and valuable ignored file. The two diff commands cover tracked changes,
not the contents of untracked files. Open those separately. Ignored listings may
be lengthy; inspect relevant directories, including hidden files, without
publishing a personal inventory.

Clean means no staged/unstaged tracked changes or reportable untracked files.
It does not mean ignored files do not exist, or that the branch is current.
Git ignores do not hide changes to already tracked files. A new asset can be
legitimate even though Git has never tracked it. A tracked deletion may be
intentional or accidental; do not restore it without asking.

**Failure/stop:** unknown changes, conflict states, or files written by a running
editor require investigation. Save/close Godot and other programs before copying
or integrating affected files so they cannot overwrite a reviewed state. Do not
use cleanup or index flags to manufacture a clean status. Use chapter 4 first.

## 4. Backup and preservation

Choose protection based on the actual files and history. One mechanism rarely
protects all of them.

| Method | Protects | Limits and verification |
| --- | --- | --- |
| External file copy with manifest | Selected tracked, untracked and ignored file bytes, including new assets and local notes | Must include every intended path; verify hashes and a recovery copy; does not itself save Git history or staged hunk boundaries |
| Local reviewed commit | Exactly reviewed staged content and its parent history | Can accidentally capture private/unrelated content; untracked/ignored files outside the commit remain unprotected; local is not GitHub |
| Named local branch at recorded HEAD | Committed history reachable from that name | No uncommitted file protection; same disk failure risk; not an external backup |
| Stash | Selected tracked changes; optional untracked files | Local recovery record; ignored files omitted by ordinary stash and `-u`; applying can conflict; do not delete existing stashes |
| External repository/history backup | Committed history when made with suitable Git-aware tools | Worktree `.git` can point elsewhere; file copying that pointer alone is not a full repository backup; stash reflogs need separate care |

### External file backup procedure

**Purpose:** preserve exact file content independently of a merge or stash.
**Prerequisites:** complete the inventory in chapter 3; save/close writers;
choose a private backup location outside every repository/worktree and prepare
an explicit list of all valuable existing files. Include new assets, required
metadata, local documentation, ignored material and any files changed during a
failed operation. Record intended deletions separately. This procedure makes
no changes to source files or Git state.

This is a **selective file-byte backup**, not an automatic full-worktree backup.
Fill the initially empty `$filesToSave` with your complete inspected inventory;
the example refuses to create a folder while that list is empty. Use ordinary
repository-relative file paths, not directories, rooted paths, alternate data
streams, or wildcard patterns. Existing backups are never overwritten.

This copy does not preserve all Git history, staged/unstaged hunk boundaries,
uninventoried ignored files, or deletions as copied files. It does not promise
symbolic/hard-link identity, permissions, timestamps, alternate streams, or other
special filesystem metadata. Record deletions separately and use the additional
patches/history-preservation methods where needed. If coverage cannot be proved,
stop for a suitable reviewed backup method rather than guessing an inventory.

```powershell
$filesToSave = @(
    # Fill in all inventoried repository-relative file paths as quoted entries.
)
if ($filesToSave.Count -eq 0) { throw 'No files selected; complete the backup inventory first.' }
if (@($filesToSave | Where-Object { $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_) }).Count -ne 0) {
    throw 'Every inventory entry must be a nonempty relative file path.'
}
function Assert-PlainFileSystemPath([string]$path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
    while ($null -ne $item) {
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'Symbolic links, junctions and other reparse points need a separate backup plan.'
        }
        if ($item.PSIsContainer) { $item = $item.Parent } else { $item = $item.Directory }
    }
}
$repoOutput = git rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { throw 'Open the intended repository first.' }
$repoRoot = [IO.Path]::GetFullPath($repoOutput.Trim())
Assert-PlainFileSystemPath $repoRoot
$resolvedBackup = Resolve-Path -LiteralPath (Read-Host 'Existing external backup folder') -ErrorAction Stop
if ($resolvedBackup.Provider.Name -ne 'FileSystem') { throw 'Choose an ordinary filesystem folder.' }
$backupParent = [IO.Path]::GetFullPath($resolvedBackup.ProviderPath)
if (-not (Test-Path -LiteralPath $backupParent -PathType Container)) { throw 'Backup parent must be a folder.' }
Assert-PlainFileSystemPath $backupParent
$worktreeListing = @(git -c core.quotePath=false worktree list --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect registered worktrees.' }
$worktreeRoots = @($worktreeListing |
    Where-Object { $_.StartsWith('worktree ') } |
    ForEach-Object {
        $rootText = $_.Substring(9)
        if ($rootText.StartsWith('"')) { throw 'Escaped worktree paths need a separately reviewed backup.' }
        [IO.Path]::GetFullPath($rootText)
    })
if ($worktreeRoots.Count -eq 0) { throw 'No worktree roots were identified.' }
foreach ($root in $worktreeRoots) {
    Assert-PlainFileSystemPath $root
    $prefix = $root.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if ($backupParent -eq $root -or $backupParent.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Choose a backup location outside all worktrees.'
    }
}
$backupRoot = Join-Path $backupParent ('withering-away-files-' + [guid]::NewGuid().ToString('N'))
if (Test-Path -LiteralPath $backupRoot) { throw 'Backup already exists; choose a new destination.' }
New-Item -ItemType Directory -Path $backupRoot -ErrorAction Stop | Out-Null
$repoPrefix = $repoRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$backupFilesRoot = [IO.Path]::GetFullPath((Join-Path $backupRoot 'files'))
$backupFilesPrefix = $backupFilesRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$manifest = foreach ($relative in $filesToSave) {
    if ([IO.Path]::IsPathRooted($relative) -or $relative -match '[:*?\[\]]') {
        throw 'Inventory requires plain relative file paths without wildcards or streams.'
    }
    $source = [IO.Path]::GetFullPath((Join-Path $repoRoot $relative))
    if (-not $source.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Backup inventory contains a path outside the repository.'
    }
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing file: $relative" }
    Assert-PlainFileSystemPath $source
    $destination = [IO.Path]::GetFullPath((Join-Path $backupFilesRoot $relative))
    if (-not $destination.StartsWith($backupFilesPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Backup destination escapes the files folder.'
    }
    if (Test-Path -LiteralPath $destination) { throw "Repeated backup destination: $relative" }
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force -ErrorAction Stop | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -ErrorAction Stop
    $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256 -ErrorAction Stop).Hash
    $copyHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256 -ErrorAction Stop).Hash
    if ([string]::IsNullOrWhiteSpace($sourceHash) -or [string]::IsNullOrWhiteSpace($copyHash)) {
        throw "Backup hash is unavailable: $relative"
    }
    if ($sourceHash -ne $copyHash) { throw "Backup verification failed: $relative" }
    [pscustomobject]@{ Path = $relative; SHA256 = $sourceHash }
}
$manifest | Export-Csv -LiteralPath (Join-Path $backupRoot 'manifest.csv') -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
if (@($manifest).Count -ne $filesToSave.Count) { throw 'Backup inventory count differs.' }
$backupRoot
```

The location check covers this repository's **registered worktrees**, not every
unrelated clone on the machine. Manually verify the backup parent is outside
other repositories too. Lexical containment checks are supplemented by rejecting
reparse points along inspected existing paths; this is not a full filesystem
security audit. Unusual paths, links, cloud placeholders, special metadata, or
files changing during the copy may need another reviewed method. A partially
created folder after any failure is not a verified backup. Do not label it safe.

**Verify recoverability before any synchronization:** inspect `manifest.csv`
against your original inventory, including hidden/ignored files. In a second
new folder outside the repository, copy the backup's `files` directory and
compare every copied file's SHA-256 with that manifest; open representative
scripts, scenes and binary assets there. Do not import that test folder into
Godot if doing so would rewrite files you are checking. Confirm intended
deletions in your notes. Keep the verified backup until integration and recovery
of unfinished work are both confirmed.

For tracked staged/unstaged distinctions, keep two additional binary-capable
patches **inside the newly created external backup folder**:

```powershell
foreach ($patchName in @('unstaged.patch', 'staged.patch')) {
    if (Test-Path -LiteralPath (Join-Path $backupRoot $patchName)) { throw 'Patch backup already exists; do not overwrite it.' }
}
git diff --binary --output="$backupRoot/unstaged.patch"
if ($LASTEXITCODE -ne 0) { throw 'Could not record unstaged changes.' }
git diff --cached --binary --output="$backupRoot/staged.patch"
if ($LASTEXITCODE -ne 0) { throw 'Could not record staged changes.' }
```

Git writes these files directly; this avoids changing patch encoding through
PowerShell output redirection. Patches omit untracked/ignored files, so they
supplement the verified file copy. Record branch, HEAD, status, stash identifiers
and the inventory in external notes. A copy of an unresolved working file is
valuable but is not by itself a complete backup of Git's conflict index.

**Failure/stop:** missing file, path/count mismatch, permissions, active writers,
copy/hash failure, symbolic links/junctions, files outside the inspected root,
or uncertainty about coverage means the backup is not verified. Stop before
integration or cleanup. Ask for an appropriate full backup when this selection
recipe is insufficient. Do not restore a backup over current work automatically;
recover into a separate folder first and review the differences.

### A reviewed local WIP commit

**Purpose:** preserve a coherent, safe subset of real work in local history.
**Prerequisites:** ordinary attached development branch, no interrupted operation,
known existing index, no secret/private/unrelated content in the selected hunks,
and permission to create the commit. A WIP commit is not an exception to content
review. Follow [exact staging and review](GIT_WORKFLOW.md#11-stage-only-intended-work)
and inspect the whole index before committing.

**Outcome:** recorded implementation is recoverable from its commit; the branch
may still be dirty. Reinspect status and back up remaining work separately.
Do not push a WIP merely to make it a backup. If safe separation is unclear, use
an external backup and stop for help rather than commit everything.

### A stash, when appropriate

**Prerequisites:** ordinary branch, no conflicts/operation, known index, external
backup verified, and a deliberate decision to temporarily remove **all** tracked
and untracked changes included by the following command. Do not use this block
when unrelated work must stay in place. Review `git stash list` first.

```powershell
git stash push --include-untracked -m "Before reviewed branch synchronization"
```

This changes the working copy/index. `--include-untracked` includes untracked
files but not ignored files. `--all` would also remove ignored content; it is not
the default preservation recipe here. Inspect the resulting entry and status:

```powershell
git stash list
git stash show --stat --include-untracked 'stash@{0}'
git stash show --patch --include-untracked 'stash@{0}'
git status --short --untracked-files=all
```

Record the actual stash entry and object ID with your external notes. Stash
entries are shared across a repository's worktrees. Confirm
that this is the newly created stash; a failed or empty stash operation may
leave a previous entry at index zero. Never assume index zero stays the same
after more stash operations. See the [stash reference](https://git-scm.com/docs/git-stash).

**Restore later only:** synchronization is complete, the destination branch is
verified, index/worktree are clean, and the reviewed stash has not already been
applied. Set `$savedStash` to the recorded full object ID, then:

```powershell
$savedStash = Read-Host 'Full object ID of the verified stash to apply'
git stash show --stat --include-untracked $savedStash
```

After confirming that output, apply it once:

```powershell
git stash apply $savedStash
```

Inspect status/diffs and test restored work. `apply` keeps the stash; ordinary
`apply` does not promise to reconstruct the original staged split. Restoring the
index with `--index` needs a separate reviewed plan. Keep the stash and backup
until all content is accounted for. If application conflicts or fails partway,
stop; do not apply it again or drop it. Record which paths restored. This is a
stash recovery state, not automatically an active merge; `git merge --abort`
is not its universal undo. See chapter 15.

## 5. Inspecting branch relationships

These are separate references:

| Reference | Meaning |
| --- | --- |
| Current local development branch / `HEAD` | Your checked-out committed history |
| Its upstream, often `origin/dev/contributor-name` | A configured comparison/default pull target; verify it |
| `origin/main` | Last fetched snapshot of the team's main, if origin is the team remote |
| Local `main` | Another local branch; fetching does not automatically update it |
| Remote development branch | Actual branch on GitHub, which may advance after fetching |

**Inspect:** after a successful fetch and repository verification:

```powershell
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git rev-list --left-right --count '@{upstream}...HEAD'
git rev-list --left-right --count origin/main...HEAD
git log --oneline origin/main..HEAD
git log --oneline HEAD..origin/main
git log --graph --oneline --decorate --all -30
```

No-upstream errors are information, not permission to invent a tracking target.
If the first command fails, do not run the upstream comparison; investigate
chapter 17. Main comparisons remain valid if `origin/main` is verified.

For `origin/main...HEAD`, the first number is commits only on main's side, the
second only on your side. `4 2` means four main-side and two local-side commits.
For `'@{upstream}...HEAD'`, the same order refers to your upstream instead.
Thus `0 3` against upstream can coexist with `5 3` against main. Neither count
measures changed lines or whether two different commits contain equivalent work.
See [revision set/count semantics](https://git-scm.com/docs/git-rev-list).

**Inspect — ancestry test:**

```powershell
git merge-base --is-ancestor origin/main HEAD
$LASTEXITCODE
```

Exit `0` means main is an ancestor of/equal to HEAD; `1` means it is not; a higher
code is an error. Test the reverse order to determine whether HEAD can move
forward directly to main. These tests print no explanatory success text.
[Git documents the exit codes](https://git-scm.com/docs/git-merge-base#Documentation/git-merge-base.txt---is-ancestor).

History and content need different inspections. `git diff origin/main...HEAD`
shows feature-side changes since the merge base; `git diff origin/main HEAD`
compares the two tip trees. Review both where prior merges/squashes make ancestry
alone misleading. An equivalent patch can exist on main under another commit ID.
Stop when commit counts, content and expected history do not agree.

## 6. Clean branch, no synchronization needed

**Purpose:** avoid unnecessary merges. **Prerequisites:** verified branch,
successful fetch, no operation/conflicts, clean tracked/index/untracked state,
and separately understood valuable ignored files.

**Inspect:** chapter 5 comparisons. Main-side count `0` and a successful
`git merge-base --is-ancestor origin/main HEAD` establish that the branch
already contains fetched main. A positive local-side count can be legitimate
unpublished feature commits; review them before any push.

**Outcome:** no main synchronization command is needed. Confirm your own
upstream relationship independently; main being contained says nothing about
new commits on that remote development branch. Continue the normal development
workflow only after that check. If upstream advanced or unique commits are
unexpected, use chapters 8–10 instead.

## 7. Branch behind main

**Diagnose first:** compare main with HEAD and review `HEAD..origin/main`.

| Main-side / local-side count | Meaning | Path |
| --- | --- | --- |
| Positive / zero | HEAD is an ancestor of fetched main | Reviewed fast-forward may be appropriate |
| Positive / positive | Diverged; both have unique commits | Chapter 9; do not treat it as a simple update |
| Zero / any | Main already contained | Chapter 6 |

**Conditional action — simple fast-forward from main.** Prerequisites: your
ordinary development branch is current; its own upstream has been inspected
and reconciled or deliberately does not exist; work/index are clean; no active
operation; all valuable ignored files backed up; HEAD is verified ancestor of
`origin/main`; fetched changes are expected and synchronization is coordinated.
Save/close Godot before updating scenes/resources.

```powershell
git merge --ff-only --no-overwrite-ignore origin/main
```

**Effect/outcome:** the checked-out development branch, index and working files
move to fetched main without a merge commit. GitHub and local `main` do not move.
Inspect status, HEAD and affected scenes afterward using chapter 27.
`--no-overwrite-ignore` refuses a merge that would overwrite ignored files;
it complements, rather than replaces, your backup.

**Failure/stop:** non-fast-forward refusal, local/untracked/ignored overlap,
unexpected files, or resource failure means inspect the new state; do not retry
with force, remove protection flags, discard files or substitute plain pull.
See [merge options](https://git-scm.com/docs/git-merge#_options).

## 8. Branch with unique commits

**Inspect:** after fetch, compare commit history and feature-side changes:

```powershell
git log --oneline origin/main..HEAD
git diff --stat origin/main...HEAD
git diff origin/main...HEAD
```

Review individual suspicious commits with `git show` using their actual hashes.
Ask: is each change intentional, unpublished, still needed, already represented
by a squash, or obsolete? Include shared settings, resources and documentation
in this review. A branch can legitimately contain multiple approved features;
its name does not limit who can work on them.

**Outcome:** an inventory of unique work and an integration plan. Preserve
commits even when their implementation will be superseded. A history entry
remaining reachable does not require keeping its old code in the final tree.
If a commit contains unrelated experiments, use chapter 21; if implementations
were replaced, use chapter 14. Do not discard commits merely to get zero counts.
An `ours` merge strategy is not normal synchronization: it can record ancestry
while excluding the incoming implementation entirely.

## 9. Diverged branches

**Purpose:** combine legitimate work while protecting both histories.
**Prerequisites:** chapters 2–5 complete; current branch and upstream known;
uncommitted/untracked/ignored content preserved and removed from the integration
working state through an explicitly reviewed method; no operation/conflicts.
Synchronization is distinct from approval to integrate your feature into main.

Follow the decision points in order:

1. Verify repository/remotes, current branch and HEAD. Record them externally.
2. Preserve unfinished work using chapters 4 and 11; confirm a clean integration
   state. A temporary branch alone does not save unfinished files.
3. Fetch. Compare against **both** own upstream and main using chapter 5.
4. If own upstream has independent commits, inspect those first. A local branch
   already behind its own remote cannot be made push-ready by merging main alone.
5. Review unique commits and the complete feature-side diff; identify shared-file
   overlap with main using `git diff --name-only HEAD...origin/main` and
   `git diff --name-only origin/main...HEAD`. Matching names indicate likely
   coordination points, not a complete prediction of conflicts.
6. Agree which implementations must survive. Stop for obsolete systems, unclear
   ownership of changes, or unverified dependencies.
7. Use a temporary candidate as described in chapter 18 when integration needs
   review. Incorporate the verified own-upstream snapshot first, validate it,
   then incorporate the inspected main snapshot. If that ordering is unsuitable
   for the actual history, review a different plan before mutation.
8. Resolve conflicts with chapters 12–14. Validate each completed merge and the
   combined project; a clean textual merge still needs Godot tests.
9. Review the candidate's full history and intended PR diff. Confirm original
   work and both fetched tips are ancestors; inspect the resulting files too.
10. Promote the original branch only after validation/approval by the
    fast-forward procedure in chapter 18. Never replace its tip blindly.
11. Re-fetch and recheck its own remote branch. If that remote moved, stop and
    reconcile again. Push only the verified development destination through
    [the parent push procedure](GIT_WORKFLOW.md#13-push-the-intended-development-branch).
12. Verify GitHub's resulting branch tip and PR contents. Publishing the branch
    does not integrate it into main. Do not claim main publication until verified.

**Expected outcome:** original branch advances through preserved history to a
tested result that includes the intended main and remote development changes.
**Failure/stop:** anything not matching that plan goes to chapter 15 or 28.
Do not reset, rewrite published history, force-push, or add unrelated changes to
make a divergence message disappear.

## 10. Updating an existing development branch

There are three different actions:

| Action | What moves | Typical procedure |
| --- | --- | --- |
| Fetch remote information | Remote-tracking refs and Git metadata | Chapter 2 |
| Incorporate your own remote branch | Current local development branch/files | Conditional fast-forward below or candidate merge |
| Incorporate main | Current local development branch/files | Chapter 7 or 9 after own-upstream diagnosis |

**Inspect:** set this illustrative name to the actual verified development
upstream, after reading `git branch -vv` and the upstream command in chapter 5.

```powershell
$remoteDevelopment = 'origin/dev/contributor-name'
git rev-parse --verify $remoteDevelopment
git rev-list --left-right --count "$remoteDevelopment...HEAD"
git log --oneline "HEAD..$remoteDevelopment"
```

If the remote-side count is positive and local-side is zero, a fast-forward is
possible. If both are positive, use a reviewed candidate merge with that remote
tip; if remote-side is zero, there is no own-upstream update to integrate.

**Conditional action:** current branch is the intended development branch,
upstream verified, fetch succeeded, working copy/index clean, no operation,
valuable ignored files backed up, and HEAD is an ancestor of the verified remote
development tip. Update from the already fetched snapshot:

```powershell
git merge --ff-only --no-overwrite-ignore $remoteDevelopment
```

**Outcome:** your branch now includes that remote development history; inspect
status and test affected files before separately comparing against main.
On refusal or unexpected content, stop; do not change the upstream to suppress
the symptom.

`git pull --ff-only` fetches then allows only a fast-forward integration of the
configured pull target. It can succeed for a behind branch or do nothing when
that target is already contained; it refuses divergence. It is appropriate only
after verifying branch, target, clean state and preserved local files. The
explicit fetch/inspect/merge route above gives you a review point and an ignored
file overwrite guard. Plain pull may merge or rebase according to configuration;
do not use it as an unexplained universal update. See the
[pull reference](https://git-scm.com/docs/git-pull).

## 11. Handling uncommitted work

**Decision:** should this work remain local, become a reviewed commit, or be
temporarily parked? Inventory staged, unstaged, untracked and ignored content
separately. New textures and required sidecars are not expendable merely because
they are untracked.

1. Keep a verified external backup of all valuable content first (chapter 4).
2. If the changes form a coherent safe unit and committing is permitted, stage
   only inspected public hunks and make a local WIP commit using parent policy.
3. If everything included by a stash may be temporarily removed, follow the
   reviewed stash procedure. Back up ignored files separately. Do not stash
   unrelated work belonging to someone else without coordination.
4. If unrelated or private local changes need to remain, do not merge through
   them merely because Git might allow it. Ask for a specific separation plan.
   Partial staging does not remove unstaged content from the working copy.
5. Re-run the full inventory. Only proceed when the integration state and
   recovery path are known. Preserve the recorded WIP/stash/backup identifiers.

A new branch made from the current HEAD records committed history only. Switching
branches can carry dirty files along or fail on overlap; it is not a backup.
Reapplying unfinished work after synchronization is a separate integration step
and can conflict. Validate that restored work before resuming development.
If unsure whether files may be removed temporarily or what will return, stop.

## 12. Merge conflicts

A merge conflict means Git cannot choose a combined result automatically. It
pauses with unmerged paths; this is not permission to choose one developer's
entire file. Shared settings and scenes frequently require a deliberate combined
result.

**Inspect — actual merge state:**

```powershell
git status
git diff --name-only --diff-filter=U
git diff
git rev-parse --verify MERGE_HEAD
```

During a normal merge of the recorded remote snapshot into the current candidate,
`HEAD` is the candidate's pre-merge side and `MERGE_HEAD` is the incoming side.
For that merge, **ours** is the current pre-merge branch and **theirs** is incoming.
During a rebase, **ours** is the rebased-onto side, including work already replayed,
while **theirs** is the commit currently being replayed. Those labels do not mean
the same developer's work in every operation; stash conflicts also need their
own diagnosis. See [Git's explanation of ours/theirs](https://git-scm.com/docs/git-checkout#Documentation/git-checkout.txt---ours).
Conflict markers in a fictional text file might look like:

> ```text
> <<<<<<< HEAD
> Use the current panel's speaker label.
> =======
> Preserve the new panel's text margins.
> >>>>>>> incoming-branch
> ```

The correct outcome might need both behaviors. The marker labels identify the
sides, not which side is newer or approved. Inspect surrounding code, node paths,
resource dependencies and the shared ancestor when needed. A `diff3`/`zdiff3`
style can also show an ancestor block beginning `|||||||`; do not leave it in the
result. Binary conflicts have no useful text-marker editing workflow.

**Conditional resolution procedure:** only for a confirmed merge you intentionally
started from a preserved clean state, with its expected incoming tip known.

1. Compare both implementations and agree on intended behavior.
2. Edit each conflicted file deliberately. Preserve required content from both;
   do not accept an entire side just because a merge tool offers a button.
3. Inspect status and the result. For a resolved existing file, set the sample
   path below to that one actual file. A deletion/rename resolution needs its
   own reviewed path handling; do not paste this example over it.

```powershell
$resolvedFile = 'scenes/gameplay/bedroom_playable.tscn'
git diff -- $resolvedFile
git diff --check
```

**Conditional stage:** only after reviewing that resolution and confirming no
unrelated content in this file; preserve any pre-existing index work.

```powershell
git add -- $resolvedFile
```

Repeat per deliberately resolved file, not by staging the whole repository.
Then inspect the complete index and remaining unmerged paths:

```powershell
git diff --name-only --diff-filter=U
git diff --cached --name-status
git diff --cached
git diff --cached --check
git grep -n -I -E '^(<<<<<<< |=======|>>>>>>> |\|\|\|\|\|\|\| )' -- '*.gd' '*.tscn' '*.tres' 'project.godot'
```

Marker matches require inspection; legitimate separators can also match. No
matches normally gives `git grep` exit 1, not an error. This scan covers tracked
listed text types, not every possible file; inspect all resolved content.
Confirm affected Godot scenes/resources load and behavior works using chapter 13.
After testing, recheck that Godot did not serialize additional changes, review
the full staged diff, and confirm the index has no unresolved paths or secrets.

**Conditional complete:** only with a real `MERGE_HEAD`, all resolutions reviewed,
required tests passed, and permission to record this merge:

```powershell
git merge --continue
```

**Outcome:** a merge commit with the intended parents. Inspect it and status;
do not assume publication. If validation cannot pass, preserve the current
resolution and stop for chapter 15 recovery or reviewer help. Do not use
`merge --continue` for a stash/rebase/cherry-pick conflict.

## 13. Godot-specific conflict resolution

Read the [shared-resource policy](GIT_WORKFLOW.md#17-godot-files-and-shared-resources)
and [architecture map](PROJECT_STRUCTURE.md) before resolving shared files.
Git's text merge cannot validate a Godot node hierarchy, resource identity,
animation contract, collision layout or Input Map.

| Area | Inspect before combining | Validate afterward |
| --- | --- | --- |
| `project.godot` | Autoload names/paths, Input Map action event lists, startup scene, viewport/render settings; distinguish intentional changes from editor serialization | One valid section per setting group, required actions retained, correct startup and valid Autoload UID/path |
| GameState | `GameState` registration and `scripts/game_state.gd.uid` identity | Autoload loads before consumers; registration/API/event semantics intact |
| Shared Player | `scenes/player.tscn`, hosting scenes' movement script attachment, collision shape, sprite/helper and camera relationships | Movement, normalized diagonals, collision, facing, camera and interaction lock/restoration in affected laboratories |
| `.tscn` / `.tres` | Nodes, parents, script references, signal connections, external/subresource IDs and every corresponding property reference | No duplicate/conflicting IDs, broken NodePaths, missing shapes/materials or unintended inherited overrides |
| Scripts / `.gd.uid` | Script and its committed identity sidecar, renamed paths and UID references | Correct script loads; no duplicate/missing identities or unattached controller |
| SpriteFrames | `assets/characters/albert/albert_frames.tres`, sheet paths, frame regions, direction names, timing and mirroring | Correct frames/idle/walk behavior; original artwork preserved |
| Texture `.import` files | Source asset and tracked import settings/identity alongside it | Correct texture import and filtering; no missing texture or unexpected import changes |
| Binary assets/resources | Provenance, permission to distribute, authoritative source, intended revision, and dependent scenes | Preview/listen to the exact proposed version; use the parent's [binary asset checks](GIT_WORKFLOW.md#binary-assets-need-content-and-permission-review), since a text diff cannot validate binary content |

The repository tracks required `.gd.uid` and texture `.import` files. Its
`.gitignore` excludes `.godot/` and root `/android/`; do not apply blanket advice
to ignore every import or UID file. The generated `.godot` cache differs from
source-side import settings. Godot recommends sharing project sources and
relevant metadata while excluding generated caches; see
[Godot version-control guidance](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html).

The current `.gitattributes` requests LF for text Git recognizes. Keep focused
edits; do not mix whole-file line-ending changes with conflict resolution.
No committed LFS patterns or `.lfsconfig` establish a repository LFS workflow;
coordinate a policy change before introducing it.

Do not recreate resource IDs, delete UID sidecars, copy whole scenes over newer
ones, or duplicate Autoload sections merely to silence Git. If both sides add
resources with colliding local scene IDs, a knowledgeable reviewer must reconcile
the declarations **and all references**. Preserve original artwork and authoring
intent; coordinate any binary replacement.

### Post-merge Godot validation

**Prerequisites:** intended resolution saved, conflict markers removed, external
backup available, Godot 4.7.2, and a known test scope. Stop for unresolved engine
or graphics failures instead of repeatedly restarting or changing drivers.

1. Open the intended `project.godot` and wait for imports. Record new parser,
   import or missing-dependency errors distinctly from pre-existing warnings.
2. Inspect Autoload, Input Map and main scene when their configuration changed.
3. Open affected scenes and inspect script attachments, NodePaths, signals,
   resource references, inherited overrides and collisions.
4. F5 tests `scenes/story/dream_story.tscn`; F6 tests an open laboratory. The opening and
   playable rooms are separate entry points; do not infer a transition exists.
5. Run only relevant approved checks: movement/animation/collision, affected
   cameras/UI, E/Space reveal/advance, interaction movement locking/restoration,
   and GameState consumers if changed. Use linked system guides for detail.
6. Stop the game, save only intentional changes, and inspect status/diffs again.
   Do not automatically stage editor-generated modifications.

**Outcome:** a tested candidate with recorded limits, not merely no Git conflicts.
If testing is unavailable, say so and keep integration pending where required.
Any behavior regression goes to chapter 22 before pushing.

## 14. Replaced or obsolete implementations

Older feature code can conflict with a newer shared implementation even when
Git produces no textual conflict. For example, a fictional branch may still
contain its own dialogue controller after main established a shared one.
Do not assume both should run or that the old branch is disposable.

**Procedure:** preserve its commits and external unfinished files; inspect
feature-side history and both implementations; list behavior present only in
the older version; coordinate with current developers; determine whether to
port needed behavior, retire superseded code in a reviewed change, or postpone
integration. Check dependencies and test the proposed resulting tree.

**Outcome:** a written, approved content plan that accounts for historical work
and current behavior. History can retain old commits while the resulting tree
uses the newer system. A successful ancestry test alone cannot prove that work
was integrated correctly. If the content relationship is uncertain, stop.

Exceptional reconciliation that records history while deliberately excluding an
implementation needs explicit expert review of the exact repository state.
This guide does not supply an `ours`-strategy shortcut. It also does not instruct
deleting, resetting or force-updating the old branch.

## 15. Interrupted operations

**Purpose:** identify the operation before choosing recovery.
**Prerequisites:** do not start another merge, pull, stash application, or branch
switch. Save an external copy of files edited since the operation began.

**Inspect:**

```powershell
git status
git branch --show-current
git rev-parse HEAD
git diff --name-only --diff-filter=U
git reflog -12
```

Reflog records local reference movements; it is a diagnostic aid, not an external
backup or a guarantee that uncommitted files can be recovered. Long status is
the first source for whether a merge, rebase or cherry-pick is active. Blank
branch output can be intentional detached HEAD during an operation; do not
create or switch a branch until that is understood. Git's internal paths must
be resolved with `git rev-parse --git-path`, especially in worktrees; do not
assume `.git` is an ordinary directory. See
[revision/path inspection](https://git-scm.com/docs/git-rev-parse).

| Actual state | Continue only when | Recovery boundary |
| --- | --- | --- |
| Merge in progress | Expected merge identified, every path resolved/staged, tested result reviewed | Chapter 12 completion; abort discussion below |
| Rebase in progress | Original plan, current replayed commit and resolved result understood | Expert-reviewed `rebase --continue`/abort plan; do not treat sides as an ordinary merge |
| Cherry-pick in progress | Picked commit, intended destination and conflict resolution verified | Expert-reviewed continuation/abort plan; inspect whether earlier picks already completed |
| Stash apply left conflicts | Recorded stash, partially restored files and original clean baseline known | Preserve all versions and review a specific recovery; no automatic merge abort or second application |
| Detached HEAD without operation | Why it is detached and whether new commits exist are known | Preserve any new commit through a reviewed named reference before leaving; chapter 17 |
| Unmerged paths but no recognized operation | Cause and required content are established | Stop; no universal continue or abort command |

**Conditional merge abort:** only if `git status` and a resolvable `MERGE_HEAD`
confirm an actual merge is in progress, the pre-merge state is known, all edits
made since it began are backed up, and you have chosen to abandon that merge:

```powershell
git merge --abort
```

**Expected outcome:** Git attempts to reconstruct the pre-merge state; verify
status, HEAD and backup contents afterward. It may not recover pre-existing
dirty work exactly, particularly if changed again during the merge. An autostash
can introduce additional restoration conflicts. If abort fails or content is
missing, stop and retain the backup; do not escalate to destructive reset.
[Git's abort warning](https://git-scm.com/docs/git-merge#Documentation/git-merge.txt---abort)
explains why starting a merge with dirty work is discouraged.

Abort is not always necessary: a well-understood operation can be continued
after resolution/review. Neither action is a general undo for arbitrary local
edits. For rebase/cherry-pick recovery, review the operation's own instructions
with an experienced contributor before mutation; do not paste merge commands.

## 16. Non-fast-forward push rejection

GitHub can reject a normal branch update when it would discard remote history.
The remote may have advanced since fetch, your branch may have diverged, or you
may have selected the wrong destination. Permission/ruleset failures are a
different problem. See [GitHub's explanation](https://docs.github.com/en/get-started/using-git/dealing-with-non-fast-forward-errors).

**Inspect:** preserve the exact rejected command/error, then verify branch,
remote URLs, configured upstream and push destination. Do not repeat it with
force. Fetch only from the verified remote, then compare the actual destination
with HEAD using chapters 5 and 10. Inspect both unique history and file diff.

**Recovery:** if the destination is correct, reconcile legitimate remote work
through a fast-forward or reviewed candidate merge as its history requires.
Test, review the full PR diff and the parent's
[outgoing-history privacy gates](GIT_WORKFLOW.md#review-outgoing-history-before-any-push),
then retry the approved normal development-branch push. If the remote moves
again, inspect again. A dry run does not reserve the remote tip; rejection can
still happen between checking and pushing.

**Outcome:** verified published development tip without overwriting others.
If authorization, branch protection or repository permissions block it, follow
the required review/access route in the parent. Do not bypass rules, change the
target to main, or rewrite remote history. See
[push update rules](https://git-scm.com/docs/git-push#_description).

## 17. Local and remote branch confusion

**Inspect first:** chapter 2, upstream comparison in chapter 5, and current
GitHub branch existence. A local branch is not deleted when its remote branch
is removed; a fetched branch is not automatically checked out locally.

| Situation | Investigation | Conditional next step / stop |
| --- | --- | --- |
| Local branch exists; remote does not | Unique commits, previous PR, exact remote name and access | Verify it is intended unpublished work before a first push; no automatic publication |
| Remote exists; local does not | Fetch success, branch names, other worktrees | With clean preserved state and permission, create a tracking local branch using the parent; do not recreate an existing local name |
| Wrong upstream | `branch -vv`, upstream resolution, actual intended destination | Coordinate and deliberately change tracking only after confirmation; not as a divergence fix |
| Wrong branch checked out | HEAD, status, unfinished work and active operation | Stop; preserve work before any deliberate switch |
| Local main differs from origin/main | Compare both directions; inspect local unique commits | Do not reset main or merge feature work into it as troubleshooting |
| Branch renamed locally | Current name, upstream and PR source branch | A local rename does not necessarily rename GitHub's branch; coordinate names/destination |
| Remote branch removed | Confirm merged/closed PR and latest server state | Preserve local work; do not automatically delete branch or recreate remote |
| Unpublished commits | Review `upstream..HEAD` and PR/base diff | Keep them reachable; decide intended scope before sync/push |

For a genuinely missing local branch, follow
[choosing a development branch](GIT_WORKFLOW.md#7-choose-a-development-branch),
not an ad hoc reset. `git switch` can refuse a branch checked out in another
worktree; do not override that protection. See the
[switch reference](https://git-scm.com/docs/git-switch).

## 18. Temporary synchronization branches

Use a candidate when both sides changed, shared-resource conflicts need review,
or obsolete implementation makes the result uncertain. A simple verified
fast-forward does not require a temporary branch. A candidate protects the
original branch **pointer** while you integrate; it is not an external backup
and shares the current working directory.

Choose the history operation before creating a candidate:

| Relationship and review need | Appropriate choice |
| --- | --- |
| Incoming tip already contained | No update for that snapshot |
| Current tip is an ancestor of incoming, no unique history needs combining | [Simple fast-forward](#7-branch-behind-main) or [own-upstream update](#10-updating-an-existing-development-branch), after preservation, review, and validation prerequisites |
| Both tips have unique commits, shared files need combined review, or old/new implementations require reconciliation | Reviewed candidate with an agreed integration plan |
| A review pause and explicit merge commit are deliberately accepted even though a fast-forward is possible | The controlled candidate merge below, with its extra history entry understood |

The pause is a chosen review technique, not mandatory for every synchronization.
Do not create needless merge commits as a universal safety measure, or substitute
rebase/reset/squash merely to avoid one. Whichever route is chosen, validate the
result before publication and preserve the original work.

### Create a reviewed candidate

**Prerequisites:** ordinary original development branch; no merge/rebase/pick;
complete preservation; clean working/index/untracked state; valuable ignored
files backed up; Godot closed; successful fetch; inspected main/upstream tips;
approved integration plan; candidate name does not already exist. All sample
names below must be replaced with your verified intended names.

**Inspect and record:**

```powershell
$developmentBranch = 'dev/contributor-name'
$candidateBranch = 'feat/sync-main-review'
$actualBranch = (git branch --show-current).Trim()
if ($actualBranch -ne $developmentBranch) { throw 'Wrong starting branch.' }
$originalHead = (git rev-parse HEAD).Trim()
$mainSnapshot = (git rev-parse --verify origin/main).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Main snapshot is unavailable.' }
git branch --list $candidateBranch
git status
```

Stop if the candidate name exists. Check the actual upstream separately; when
there is one, record its full hash as `$upstreamSnapshot` after reviewing the
chapter 5 comparisons. If it is missing, do not invent a remote development
branch. Record these hashes externally so they survive a closed shell.

**Conditional create:** only after confirming the prerequisites and empty
candidate-name output:

```powershell
git switch --no-track -c $candidateBranch $originalHead
```

**Outcome:** HEAD is attached to a new local candidate at the original tip.
The original branch has not moved. No GitHub branch was created. If the command
fails, inspect status/branches before any retry. Do not use an option that resets
an existing branch.

### Incorporate one verified snapshot at a time

**Prerequisites:** candidate checked out, clean state, snapshot hash reviewed,
no operation, integration approval and author identity available. Set
`$incomingSnapshot` to the recorded **own-upstream** tip first if it has commits
missing from the candidate; otherwise omit that merge. Later repeat for the
recorded main tip if it is still missing. Do not merge both blindly in one block.

**Inspect — choose exactly one recorded, reviewed incoming commit:**

```powershell
$incomingSnapshot = (Read-Host 'Full recorded hash of the single incoming tip to merge').Trim()
if ($incomingSnapshot -notmatch '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
    throw 'Use a full recorded commit hash, not an empty or guessed reference.'
}
git cat-file -e "$incomingSnapshot^{commit}"
if ($LASTEXITCODE -ne 0) { throw 'Incoming commit is unavailable.' }
git merge-base --is-ancestor $incomingSnapshot HEAD
$LASTEXITCODE
```

If exit `0`, that snapshot is already contained: skip it. If exit `1`, test the
reverse relationship before choosing an update; on any other error, stop:

```powershell
git merge-base --is-ancestor HEAD $incomingSnapshot
$LASTEXITCODE
```

Exit `0` here means a fast-forward is possible. Prefer the simple route when
its review needs and prerequisites fit; if already on a candidate, keep the
original tip preserved and use the same verified fast-forward principles there,
then validate before promotion. Exit `1` after both tests means neither tip
contains the other, so reconcile through the reviewed candidate plan. An explicit
review-pause merge for a fast-forwardable tip needs deliberate agreement about
the extra merge commit. Only with that choice or genuine reconciliation:

```powershell
git merge --no-ff --no-commit --no-overwrite-ignore $incomingSnapshot
```

**Effect:** updates candidate working files/index and pauses before creating the
merge commit, or pauses for conflicts. `--no-ff` is used here with `--no-commit`
so a possible fast-forward does not bypass the review pause. This intentional
candidate workflow can create a merge commit where a direct update could have
fast-forwarded; use chapter 7/10 for trivial updates instead.
`--no-commit` pauses before a **merge commit**, but cannot pause a fast-forward
by itself. `--no-ff` requests the merge commit even when a fast-forward is
possible. `--no-overwrite-ignore` refuses ignored-file overwrites; it is not a
backup, rollback of arbitrary changes, or protection against unrelated tools.

Inspect complete changes; resolve conflicts with chapter 12; validate with
chapter 13; verify no unrelated/editor/private content. If a merge is actually
pending and approval to record it is present, complete it using chapter 12's
`git merge --continue` procedure. Reinspect after completion before another
incoming snapshot. If the merge refused before starting, do not assume
`MERGE_HEAD` exists. Use chapter 15 for actual state-specific recovery.
Inspect status, HEAD, the index and operation markers first; without a pending
merge, neither `git merge --continue` nor `git merge --abort` is the right next
command. An already-contained no-op also creates no pending merge. Never infer
state solely from a nonzero exit code. See [Git merge semantics](https://git-scm.com/docs/git-merge).

### Validate and promote the original branch

**Inspect:** after all intended merges completed and candidate tests passed:

```powershell
git status
git log --graph --oneline --decorate -20
git diff --stat "$originalHead..HEAD"
git diff "$originalHead..HEAD"
git diff origin/main...HEAD
git merge-base --is-ancestor $originalHead HEAD
$LASTEXITCODE
git merge-base --is-ancestor $mainSnapshot HEAD
$LASTEXITCODE
```

Also test the recorded upstream snapshot when applicable. All required ancestry
tests must return `0`; review actual resulting files and PR diff as well.
Record the tested candidate's full tip as `$reviewedCandidateHead` after
confirming the current branch is still the candidate:

```powershell
if ((git branch --show-current).Trim() -ne $candidateBranch) { throw 'Wrong candidate branch.' }
$reviewedCandidateHead = (git rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Candidate tip is unavailable.' }
```

**Prerequisites for promotion:** explicit acceptance of the candidate, no
unfinished operation, clean current state, valuable ignored files protected,
original branch still at `$originalHead`, no other worktree using that branch,
and candidate still at `$reviewedCandidateHead`. Re-fetch before promotion and
inspect whether main or the development upstream advanced. If either has new
required changes, revise/test the candidate before proceeding.

**Inspect the original tip without moving it:**

```powershell
git rev-parse $developmentBranch
git rev-parse $candidateBranch
git worktree list --porcelain
```

If hashes match the recorded accepted state, conditionally switch:

```powershell
git switch $developmentBranch
```

Check branch, HEAD and status again. **Promotion advances the original local
development branch to the accepted candidate commit.** It does **not** push to
GitHub, merge the feature into shared main, restore parked/stashed unfinished
edits, verify unreviewed history for private content, publish/delete the temporary
branch, or automatically update local main. Those are separate decisions and
steps. Afterward, inspect the resulting branch and follow the parent's complete
[pre-push history/content review](GIT_WORKFLOW.md#13-push-the-intended-development-branch).

**Only if still clean, correct, and at the recorded original tip**, promote by
fast-forward to the reviewed commit:

```powershell
if ([string]::IsNullOrWhiteSpace($reviewedCandidateHead) -or
    $reviewedCandidateHead -notmatch '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
    throw 'The full reviewed candidate commit hash is required.'
}
git cat-file -e "$reviewedCandidateHead^{commit}"
if ($LASTEXITCODE -ne 0) { throw 'Reviewed candidate commit is unavailable.' }
$candidateTipNow = (git rev-parse --verify "$candidateBranch^{commit}").Trim()
if ($LASTEXITCODE -ne 0 -or $candidateTipNow -ne $reviewedCandidateHead) { throw 'Candidate branch changed.' }
$promotionBranch = (git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $promotionBranch -ne $developmentBranch) { throw 'Wrong development branch.' }
$promotionHead = (git rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($originalHead) -or
    $promotionHead -ne $originalHead) { throw 'Original development tip changed or was not recorded.' }
$promotionStatus = @(git status --porcelain --untracked-files=all)
if ($LASTEXITCODE -ne 0 -or $promotionStatus.Count -ne 0) { throw 'Integration state is not clean.' }
foreach ($marker in @('MERGE_HEAD', 'CHERRY_PICK_HEAD', 'REVERT_HEAD', 'rebase-merge', 'rebase-apply')) {
    $markerPath = (git rev-parse --git-path $marker).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect operation state.' }
    if (Test-Path -LiteralPath $markerPath) { throw 'An operation is still in progress.' }
}
git merge-base --is-ancestor $originalHead $reviewedCandidateHead
if ($LASTEXITCODE -ne 0) { throw 'Accepted candidate does not preserve the original history, or inspection failed.' }
git merge --ff-only --no-overwrite-ignore $reviewedCandidateHead
```

**Outcome:** original development branch advances to the accepted candidate
without rewriting either history. Inspect chapter 27, check the remote
development relationship once more, and use the parent's approved push process.
Do not push the temporary branch or main by accident.
A candidate can retain historical commits not visible in its final diff. A
verified fast-forward establishes ancestry only; synchronization and promotion
do not certify outgoing-history privacy. Review that history independently.

**Failure/stop:** if any original/candidate/remote tip changed, clean-state check
fails, branch switching is refused, or fast-forward fails, stop and inspect;
do not replace the original tip, bypass another worktree, or force-push. Keep
the candidate and external backup. Cleanup is a separate later decision after
confirming no unique needed work; this procedure does not delete it.

## 19. Rebase, cherry-pick, and history rewriting

These are distinct operations, not synonyms for synchronization:

- **Merge** joins histories, retaining existing commit identities. The resulting
  tree must still be reviewed for intended behavior.
- **Rebase** replays commits onto another base, usually creating new identities.
  It can be useful for a deliberately managed unpublished branch, but can disrupt
  collaborators who already built on the old published commits.
- **Cherry-pick** applies selected commit changes to another branch as new
  commits. Selection can omit dependencies and duplicate work already merged.
- **Reset** can move branch/index/working state depending on mode. It is not an
  ordinary preservation or conflict-resolution step.
- **Revert** records a new corrective change. It retains history but still needs
  dependency, conflict and gameplay review; reverting a merge has extra semantics.

Beginners should prefer the preservation-first merge/fast-forward workflows.
Do not rebase a shared published branch merely for a tidier graph, use a force
push to suppress rejection, or use a strategy that pretends incoming work was
incorporated without reviewing it. No advanced mutation recipe is supplied here.
If one is needed, coordinate an exact plan with the maintainer using chapter 28,
including preserved refs/files, collaborators, expected resulting tree, review,
testing and recovery. See [commands needing special care](GIT_WORKFLOW.md#23-commands-that-need-special-care).

## 20. Recovering accidentally staged changes

**Purpose:** remove an unintended path from the index without discarding its
working file. **Prerequisites:** normal branch with an existing HEAD; no
merge/rebase/cherry-pick/conflict; review existing staged work first. Partial
staging requires hunk-level care rather than unstaging an entire unrelated file.

**Inspect:**

```powershell
git diff --cached --name-status
git diff --cached
git status --short
```

**Conditional action:** set this sample to the exact incorrectly staged file
whose **entire staged difference** should be removed:

```powershell
$mistakenFile = 'scenes/gameplay/bedroom_playable.tscn'
git restore --staged -- $mistakenFile
```

**Expected outcome:** index for that path returns to HEAD; working-copy bytes
remain. A newly added file becomes untracked. Confirm status, working diff and
remaining staged diff. For one mistaken hunk mixed with intended staged hunks,
review `git restore --staged --patch -- path` interactively with someone who
understands the split; do not unstage the whole repository blindly.
[Restore's `--staged` option](https://git-scm.com/docs/git-restore#Documentation/git-restore.txt---staged)
changes the index; adding `--worktree` or using restore without this option has
different effects and can discard file edits.

Unstaging is not restoring a working file, reverting a commit, or resetting
history. If in an active operation, or the path/index is unfamiliar, stop rather
than apply this normal-branch recipe.

## 21. Recovering accidental commits

**Inspect:** record HEAD, status, actual commit contents and branch relationships.
Use `git show --stat HEAD` and `git show HEAD`, then fetch the verified remote
when appropriate and compare the destination history. Do not assume a commit is
unpushed because the current upstream looks behind; it may be published through
another branch, PR or cherry-pick. Ask collaborators if uncertain.

| Situation | Safe next decision |
| --- | --- |
| Local accidental commit, not published | Preserve its hash/history and working content; review whether a new correction, split on another branch, or narrowly authorized rewrite is suitable |
| Already pushed | Coordinate a corrective commit/PR and tests; do not rewrite shared history automatically |
| Unrelated files in feature PR | Inspect the whole base/head diff and each commit; coordinate separating work, do not delete paths blindly or make main absorb the accident |
| Credential/secret committed | Stop publication; revoke/rotate exposed credentials immediately, inform the maintainer securely, and follow repository incident handling |

Deleting a credential in a later commit does not remove it from history or
invalidate copies. Cleanup may require coordinated history work and hosting
support; do not post the secret in an issue, chat log or command. Follow
[GitHub's sensitive-data guidance](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository).

**Outcome:** a reviewed correction preserving legitimate work, with verified
remote status. If publication extent, affected collaborators or dependencies
cannot be established, stop for chapter 28 rather than rewrite, amend, reset or
force-push on instinct.

## 22. A successful merge that breaks Godot

**Purpose:** diagnose content/integration defects after Git reports success.
**Prerequisites:** retain pre-merge commit/hash and backup; do not continue
publishing a broken candidate or make destructive rollback guesses.

1. Record the merged commit, parents, branch and exact runtime/import errors.
2. Inspect `git show --stat HEAD` and the changes relative to the recorded
   pre-merge tip. A merge commit's default display may omit changes; compare
   against the relevant parent explicitly when investigating.
3. Trace affected scenes/resources using [Project structure](PROJECT_STRUCTURE.md)
   and their `ext_resource`/`sub_resource` references.
4. Check filenames/case, paths, UID sidecars/references and missing source assets.
5. Check Autoload names/paths, Input Map actions and startup scene configuration.
6. Check node parents, NodePaths, script attachments, signals and shared resource
   overrides. A valid file can still attach the wrong controller.
7. Run the affected scene(s) in Godot 4.7.2; inspect parser/import/runtime errors,
   collisions, input and camera/UI behavior as relevant. Stop on engine failure.
8. Compare source differences and recorded behavior with the known working
   baseline. Do not reset the current tree or launch another copy through a
   destructive checkout just to compare. An isolated comparison requires its
   own deliberate preservation plan.
9. Identify a narrow corrective change, coordinate it with relevant developers,
   and review/test it before publication. Do not replace the entire newer file.
10. Repeat affected regression checks and inspect status afterward.

**Outcome:** demonstrated cause and tested repair plan, or an honest unresolved
report. No parser error is not proof of correct gameplay. If the problem cannot
be isolated, stop integration and share the sanitized evidence from chapter 28.

## 23. Returning after an absence

**Purpose:** return to current work without losing old unfinished changes.
**Prerequisites:** use the existing copy; do not clone repeatedly to avoid
understanding its history.

1. Complete chapter 2 before opening/saving scenes in Godot. Identify old local
   work, active operations, branches and upstreams.
2. Inventory and back up unfinished tracked, untracked and ignored files; record
   unpublished commits and existing stashes.
3. Fetch the verified remote and compare separately with your own remote branch
   and main. Inspect new main-side commits and their file changes.
4. Read [README](../README.md), [Team progress](TEAM_PROGRESS.md),
   [Design decisions](DESIGN_DECISIONS.md), and the relevant system guides.
   Check what is published versus proposed or accepted but unpublished.
5. Coordinate changes to shared files and systems, especially where an older
   implementation was superseded. Current responsibilities can change.
6. Select the matching fast-forward/candidate workflow; preserve unique commits
   and separately restore unfinished files with review.
7. Validate the synchronized baseline in Godot before adding a new feature.

**Outcome:** known history, preserved old work, tested current baseline, and an
agreed next task. Missing dependencies, unclear old work, active recovery, or
unknown integration status means stop and escalate, not start a new branch of
guessed repairs.

## 24. Troubleshooting by symptom

These are starting points, not universal fixes. Record the exact message and
failed command, then use the linked chapter. Avoid publishing sensitive output.

| Symptom | Meaning and safe first diagnostic | Do not assume / stop point |
| --- | --- | --- |
| `Your branch is behind` | Last fetched upstream has commits; inspect chapter 5 and [10](#10-updating-an-existing-development-branch) | Upstream is not automatically main; fetch may be stale |
| `Your branch and origin/... have diverged` | Both sides have unique commits; inspect both ranges, [9](#9-diverged-branches) | Not permission to reset or force-push |
| `Your local changes would be overwritten` | Target overlaps unfinished tracked work; status/diffs, [11](#11-handling-uncommitted-work) | Stop mutation; do not discard files to continue |
| `Untracked working tree files would be overwritten` | New local files overlap incoming paths; inventory/backup, [4](#4-backup-and-preservation) | Untracked does not mean disposable |
| `CONFLICT (content)` | Git paused on content it cannot combine; long status, [12](#12-merge-conflicts) | Identify operation; no blind whole-side choice |
| `You have not concluded your merge` | A merge remains active; status/MERGE_HEAD, [15](#15-interrupted-operations) | Do not begin another pull or merge |
| `non-fast-forward` | Destination history not safely replaced by your tip; inspect rejected destination, [16](#16-non-fast-forward-push-rejection) | Do not force or change destination as a workaround |
| `No upstream branch` | Current branch lacks configured tracking; `branch -vv`, [17](#17-local-and-remote-branch-confusion) | Do not set it to main without a reason |
| `Detached HEAD` | HEAD points at a commit rather than normal attached branch; status/reflog, [15](#15-interrupted-operations) | Could be an active rebase; preserve new commits before leaving |
| `Permission denied` | Could be repository/authentication/filesystem access; inspect command/error and remote, [28](#28-safe-escalation) | Do not expose credentials or bypass repository rules |
| `Not a git repository` | Wrong directory or missing/unavailable Git metadata; root/location check, [2](#2-establish-the-actual-repository-condition) | Do not initialize another repository over the files |
| `Nothing to commit` | Index has no new commit to record; inspect status, ignored/untracked and current branch, [3](#3-working-tree-cleanliness) | Not proof work is on GitHub or the intended copy is open |
| `Everything up-to-date` | Requested push had no ref update; inspect exact remote/ref and GitHub tip, [16](#16-non-fast-forward-push-rejection) | Uncommitted changes were not pushed; verify correct destination |
| `Unrelated histories` | Git found no common ancestor; inspect roots/remotes/history, [28](#28-safe-escalation) | Stop; do not automatically override this protection |
| `Repository not found` | Wrong URL, missing repository or insufficient access; inspect URL privately, [2](#2-establish-the-actual-repository-condition) | Do not assume your files are lost or credentials need posting |
| `Cannot lock ref` | Another writer, stale ref state, permissions or another metadata issue; record full error, active processes and worktrees, [28](#28-safe-escalation) | Stop competing commands; do not delete lock files blindly |
| Godot cannot load a scene after merging | Text merge may have broken resources/paths; error text and changed files, [22](#22-a-successful-merge-that-breaks-godot) | Git success is not functional validation; do not delete identities/cache as a guessed repair |

## 25. Guided scenarios

All branch names and counts below are fictional examples, not commands executed
against the team repository. Use the actual diagnostics before choosing a path.

### Scenario A: clean branch already contains main

`dev/contributor-name` is clean. After fetch, `origin/main...HEAD` reports `0 2`
and upstream comparison reports `0 2`. Review the two local commits; if expected,
main is already contained and own upstream has nothing missing locally. No merge
is needed. Test/review the intended feature and follow normal branch publication.
Do not merge main simply because fetch downloaded data.

### Scenario B: dirty branch needs new main updates

There are scene edits, a new texture with import metadata, and valuable ignored
local content. Inventory staged/unstaged/untracked/ignored files; verify an
external copy. Choose a safe reviewed WIP or stash only for appropriate content.
If local changes must stay mixed in place, stop for a separation plan. With a
known clean integration state, fetch/compare and choose chapter 7 or 9. Restore
unfinished work separately and test it; never assume a stash covered ignored work.

### Scenario C: feature commits and new main commits

`origin/main...HEAD` reports `4 3` for `feat/interaction-improvements`. Review all
three feature commits, four main commits and overlapping files. Inspect its own
upstream separately. Preserve files/commits, build a chapter 18 candidate, merge
the missing verified main snapshot, resolve/test, review and approve. Promote
the original only by verified fast-forward; re-fetch its remote before pushing.

### Scenario D: both local and remote development branch changed

Own-upstream comparison reports `2 1`; main comparison reports `5 2`. Main is
not the first comparison's target. Review the two upstream commits and local
commit; agree on their combined behavior, merge upstream into a candidate first,
test, then incorporate main if needed. Re-fetch before promotion/push. If a
collaborator advanced the remote again, stop and revise rather than force.

### Scenario E: two contributors changed project.godot

One added an Autoload while another added an Input Map action. A conflict does
not justify selecting an entire file. Inspect both changes and relevant shared
Player references, preserve each valid setting in the right section, and review
every resource/UID dependency. Open Godot, check Autoload/Input Map/startup,
run affected scenes and shared movement/interaction tests. Stage only deliberate
resolutions, complete the merge, and inspect editor changes afterward.

### Scenario F: old dialogue implementation was replaced

A branch's dialogue code predates a shared framework on main. Preserve its
commits and unfinished files. Compare behavior, identify anything uniquely
needed, and coordinate with current developers. Agree whether to port that
behavior or retire superseded code in a reviewed change. Do not run both systems
blindly, discard history, or hide the decision behind an `ours` merge strategy.

### Scenario G: pushed branch has unrelated PR changes

A PR from `feat/scene-transition` shows unrelated artwork/configuration edits.
Inspect the PR base, unique commits and actual full file diff. Determine whether
the wrong base, mixed commits or unintended staging caused it. Preserve the
published history and coordinate a correction or separately reviewed branch
plan; no automatic history rewrite. Do not assume a new delete commit fixes all
dependencies or exposes no secrets. Check the corrected PR diff before review.

### Scenario H: Git succeeded but Godot resources broke

Merge reports success, but a scene's script UID no longer resolves. Record the
merge/parents and exact error, inspect script path and sidecar plus scene
references, compare against the known working versions. Check shared settings
and dependencies before a minimal reviewed correction. Run relevant scenes and
regressions, inspect status, and keep publication pending until verified. Do not
regenerate identities or overwrite whole scenes as an unexplained fix.

## 26. Pre-synchronization checklist

- [ ] Correct repository root, copy and attached development branch.
- [ ] Correct fetch/push remotes and understood repository access.
- [ ] Recorded HEAD and verified upstream, including a deliberate no-upstream case.
- [ ] No unresolved merge/rebase/cherry-pick or unknown detached state.
- [ ] Index, tracked edits/deletions, untracked and valuable ignored files inventoried.
- [ ] External backup verified by inventory, hashes and recovery copy; existing
      backups/stashes preserved; unpublished commits remain reachable.
- [ ] Clean integration state achieved through an explicitly reviewed method.
- [ ] Godot/other writers saved and closed before changing affected resources.
- [ ] Successful fetch; own-upstream and main relationships inspected separately.
- [ ] Unique commits, resulting diff and shared-file overlap understood.
- [ ] Appropriate fast-forward or candidate merge plan, expected tips and recovery
      checkpoints agreed; no unapproved history rewriting.
- [ ] Relevant collaborators informed where edits overlap or implementations differ.

If any item is unknown, inspect or ask before mutation. A checklist is not a
substitute for reading the actual status and diff.

## 27. Post-synchronization checklist

- [ ] Correct original branch and expected HEAD/history/parents.
- [ ] Intended fetched main and own-upstream snapshots present; expected file
      content verified even where prior squashes make ancestry insufficient.
- [ ] Unique legitimate work preserved; obsolete code disposition reviewed.
- [ ] No unplanned scene/resource/artwork replacement or identity regeneration.
- [ ] No unmerged paths or unresolved conflict markers; complete diff reviewed.
- [ ] Godot loads/imports affected resources; required scenes and behavior tested.
- [ ] Test limitations and pre-existing warnings recorded honestly.
- [ ] Restored unfinished work reviewed separately; stash/backup retained until
      every intended file and staging distinction is accounted for.
- [ ] Status contains only understood modifications; index contains only intended
      public changes; no sensitive material or unintended caches/generated output
      staged. Required source-side metadata remains included with its dependencies.
- [ ] Fetched remote development state rechecked, correct publication destination
      understood, and any new remote work reconciled before an approved push.
- [ ] Outgoing commit history and final tree reviewed separately through the
      [parent's complete pre-push procedure](GIT_WORKFLOW.md#review-outgoing-history-before-any-push).
      Candidate ancestry, clean status, and fast-forward eligibility are not
      privacy approval; an earlier private file remains a concern after deletion.
- [ ] After publication, exact remote tip and full PR diff verified; main publication
      claimed only after integration into main is confirmed.
- [ ] Relevant teammates notified through the ordinary coordination channel after
      approved publication; documentation status updated when meaningful and authorized.

Keeping an unneeded temporary candidate, backup or stash briefly is safer than
deleting unique work. Cleanup requires its own deliberate verification.

## 28. Safe escalation

Stop before changing history when the state or intended result is unclear.
Provide a **sanitized** information package:

- What you were trying to accomplish and the intended destination branch.
- Repository identity and current branch; HEAD and relevant baseline hashes.
- Exact command that failed, its error text and whether anything changed afterward.
- `git status` and `git branch -vv` output.
- Separate own-upstream and main ahead/behind counts, with reference order stated.
- Whether staged, unstaged, untracked, ignored or unpublished work exists; how it
  has been backed up and verified, without exposing private file contents.
- Whether merge/rebase/cherry-pick/stash recovery or detached HEAD is involved.
- Whether GitHub advanced since your last successful fetch and the verified tips.
- Relevant Godot import/parser/runtime error, affected scenes/resources, and tests
  performed versus tests unavailable.

Remove access tokens, credentials, personal paths, private configuration and
sensitive content from URLs, screenshots, diffs and logs before sharing. Share
secret incidents through an appropriate private channel, never by pasting the
secret into public support. Do not ask someone to approve a guessed destructive
command without showing the diagnosed state and preservation plan.

For permissions, contribution policy, commits, PR review and integration, return
to [the parent handbook](GIT_WORKFLOW.md). For what the game currently implements,
use [README](../README.md), [Project structure](PROJECT_STRUCTURE.md),
[Team progress](TEAM_PROGRESS.md), and [Design decisions](DESIGN_DECISIONS.md).
Asking before an uncertain mutation protects both your work and the team's.

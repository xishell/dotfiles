# 📝 Git Plugin (OMZP::git) Cheat Sheet

This cheat sheet lists the **most useful aliases and functions** provided by the
Oh My Zsh **git plugin** (via `OMZP::git` in Zinit).

---

## 🔑 Core

- `g` → `git`
- `grt` → `cd` to repo root
- `current_branch` → print current branch
- `git_main_branch` → detect main (`main`, `master`, …)
- `git_develop_branch` → detect develop (`develop`, `dev`, …)

---

## ➕ Add & Commit

- `ga` → `git add`
- `gaa` → `git add --all`
- `gapa` → `git add --patch`
- `gav` → `git add --verbose`
- `gc` → `git commit --verbose`
- `gca` → `git commit --all --verbose`
- `gcmsg "msg"` → commit with message
- `gcam "msg"` → commit all with message
- `gc!` → amend last commit
- `gwip` → quick WIP commit (`--wip-- [skip ci]`)
- `gunwip` → undo last WIP commit
- `gunwipall` → recursively reset all WIP commits

---

## 🌿 Branch

- `gb` → list branches
- `gba` → list all branches
- `gbd` / `gbD` → delete branch
- `gbda` → delete merged branches (except main/develop/current)
- `gbr` → list remote branches
- `gbm` → rename/move branch
- `gco <br>` → checkout
- `gcb <br>` → checkout new branch
- `gcB <br>` → checkout/overwrite branch
- `gcd` → checkout develop branch
- `gcm` → checkout main branch
- `gsw <br>` → switch branch
- `gswc <br>` → create branch with switch

---

## 🔄 Fetch, Pull & Push

- `gf` → fetch
- `gfa` → fetch all + tags (parallel if Git ≥2.8)
- `gfo` → fetch origin
- `gl` → pull
- `gpr` → pull --rebase
- `gpra` → pull --rebase --autostash
- `ggl` → pull origin current branch
- `ggu` → pull --rebase origin current branch
- `gp` → push
- `gpoat` → push all branches + tags
- `ggp` → push origin current branch
- `gpsup` → push and set upstream
- `gpf` → push --force-with-lease
- `ggf` → push force current branch

---

## 🔀 Merge & Rebase

- `gm` → merge
- `gms` → merge --squash
- `gmff` → merge --ff-only
- `grb` → rebase
- `grbi` → interactive rebase
- `grbm` → rebase onto main
- `grbd` → rebase onto develop

---

## 📊 Status, Diff & Log

- `gst` → status
- `gss` → short status
- `gsb` → short + branch
- `gd` → diff
- `gds` → diff staged
- `gdca` → diff cached
- `gdv` → diff in vim
- `glg` → log with stats
- `glgp` → log with patch
- `glol` → pretty log (oneline, relative time, author)
- `glods` → pretty log (short date, author, decorations)
- `glo` → log oneline
- `glog` → log graph oneline
- `gloga` → log graph all branches

---

## 📦 Stash, Tag & Worktree

- `gsta` → stash
- `gstp` → stash pop
- `gstl` → stash list
- `gsts` → stash show patch
- `gta` → tag annotate
- `gts` → tag sign
- `gtv` → tag list sorted
- `gwt` → worktree
- `gwta <dir>` → worktree add
- `gwtls` → list worktrees
- `gwtrm` → remove worktree

---

## 🛠 Other

- `gcf` → list config
- `gcount` → shortlog summary
- `gignored` → list ignored files
- `gfg <pat>` → search tracked files
- `gsh` → show
- `gsps` → show + signature
- `gpristine` → reset + clean
- `gwipe` → hard reset + clean
- `groh` → reset hard to origin/<current>

---

## 🚨 Deprecations

The following aliases are deprecated and will warn when used:

- `gup` → use `gpr`
- `gupv` → use `gprv`
- `gupa` → use `gpra`
- `gupav` → use `gprav`
- `gupom` → use `gprom`
- `gupomi` → use `gpromi`

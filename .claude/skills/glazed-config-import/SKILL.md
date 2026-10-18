---
name: glazed-config-import
description: Trigger a glazed config backup run, wait for the `config-staging` branch to receive the new commits, then merge them into the current branch with a merge commit (`--no-ff`) and delete `config-staging`. Use when the user asks to pull, import, sync or refresh the glazed host configs into git (`glazed/hosts`), to "run glazed and merge config-staging", or wants a fresh device config in the working tree after a network change, even if they never name the branch.
---

# Import glazed config backups via config-staging

glazed's `backup` workflow ends with a `github` publish step that commits redacted device configs to `glazed/hosts` on the `config-staging` branch of `ruby-no-kai/rubykaigi-net` (commits by `rk-cat[bot]`). This skill triggers a run, waits for that branch to move, and brings the commits into the current branch with a `--no-ff` merge, so the import shows as one merge commit.

## Procedure

1. Check the live branch: `git branch --show-current`. If it is the default branch (`master`), stop and ask. Require a clean `glazed/hosts` (`git status --short glazed/hosts`), since the merge must not collide with local edits.

2. Record the branch tip before triggering, so a change can be detected:

   ```bash
   BEFORE=$(git ls-remote origin refs/heads/config-staging | cut -f1)
   ```

   Empty means the branch does not exist yet (fine; wait for it to appear).

3. Release device sessions first. Some devices (NEC IX, for one) allow a single config session, so an open `misc/ssh_cli.rb` session makes glazed's fetch fail with `CONFIG process is occupied` and that node's commit never appears. List sessions with `ruby misc/ssh_cli.rb list` and close those for the target nodes (`ruby misc/ssh_cli.rb -s NODE close`). Sessions are the user's working state, so close only the ones for nodes being backed up, and tell the user.

   Then start the state machine. Use `"node"` for one device or `"all_nodes": true` for everything. Keep `"immediate": true`: without it the node waits out the 60 s debounce (up to 10 min) before running, and this skill is blocking on the result anyway. Drop it only when the user explicitly wants the normal debounced schedule.

   ```bash
   aws stepfunctions start-execution --region ap-northeast-1 \
     --state-machine-arn arn:aws:states:ap-northeast-1:005216166247:stateMachine:glazed \
     --input '{"signals":[{"node":"wlc-01.venue","source":"manual","immediate":true,"workflows":["backup"]}]}'
   ```

   Note the execution ARN it prints. If another execution is already waiting, this one only records the signal and ends at once; the waiting one performs the run. An execution reaching SUCCEEDED is not proof a node was backed up either, because a node's fetch can fail inside a successful execution. The evidence is that node's commit on the branch.

4. Wait until every requested node has its commit. The publish writes one commit per node, subject `glazed: <node>`, so the tip moves after the first node and a changed tip does not mean the run is done. Poll every 15 s, up to about 10 minutes (debounce, fetch and publish take a while):

   ```bash
   NODES="wlc-01.venue"   # or the full list from glazed/glazed.jsonnet for all_nodes
   for i in $(seq 40); do
     git fetch -q origin config-staging 2>/dev/null
     MISSING=""
     for n in $NODES; do
       git log --format=%s "$BEFORE"..origin/config-staging 2>/dev/null | grep -qx "glazed: $n" || MISSING="$MISSING $n"
     done
     [ -z "$MISSING" ] && break
     sleep 15
   done
   echo "missing:$MISSING"
   ```

   With an empty `BEFORE` (branch did not exist), use `origin/config-staging` alone as the range. Foreground `sleep` is blocked here, so run the loop with `run_in_background` or use Monitor with an until-loop.

   A node can stay missing legitimately: when its config did not change the publish commits nothing. Tell that apart from a failure by checking `/aws/lambda/glazed` logs for the node (`CONFIG process is occupied` means an open session, so close it and re-trigger just that node). Do not merge or delete while a node is unexplained; report which are missing and why. After the last commit lands, wait one more poll interval and confirm the tip is stable.

5. Fetch and merge, always with a merge commit:

   ```bash
   git fetch origin config-staging
   git merge --no-ff --no-edit origin/config-staging
   ```

   The bot's commits are imported unchanged; never rebase or squash. If the merge conflicts, run `git merge --abort`, then stop and report. When the current branch already contains the tip, git says "Already up to date" and there is nothing to import. If signing fails with `Inappropriate ioctl for device`, ask the user to unlock their signing key rather than skipping the signature.

6. Before deleting, check that no execution of this state machine is still waiting, since its publish may recreate or miss the branch and its commits would then not be part of this import:

   ```bash
   aws stepfunctions list-executions --region ap-northeast-1 \
     --state-machine-arn arn:aws:states:ap-northeast-1:005216166247:stateMachine:glazed \
     --status-filter RUNNING --query 'executions[].[name,startDate]' --output text
   ```

   Executions asleep in the debounce are common after earlier manual triggers. If any are running, tell the user and either wait for them to finish (then repeat step 5 for what they publish) or skip deletion and say so.

   Only after the merge succeeded and nothing is pending, delete the branch so the next run starts clean:

   ```bash
   git push origin --delete config-staging
   git branch -D config-staging 2>/dev/null   # local copy, if any
   ```

   Use `-D` only for the local branch, since a worktree branch such as `purge-config-staging` is unrelated and must be left alone. Do not push the merged result; commit and push stay with the user's request.

7. Report the commits imported (`git log --oneline HEAD^1..HEAD^2 -- glazed/hosts`) and the files changed (`git diff --stat HEAD^1 HEAD`).

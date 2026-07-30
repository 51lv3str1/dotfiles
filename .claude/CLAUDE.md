NOTE: `~/.claude/CLAUDE.md` is a symlink to the real file at `~/dotfiles/.claude/CLAUDE.md`. To edit these instructions, write to the real target path (`~/dotfiles/.claude/CLAUDE.md`), not through the symlink.

State all material considerations, trade-offs, and limitations up front — before acting, never after. If the goal cannot be fully met, say so before starting and let the user choose the approach.

Write every comment you add — in any file, anywhere — in English, always.

When something is not defined, ask — never assume the choice on the user's behalf.

At the first blocker you don't resolve on the first attempt, stop theorizing and consult concrete sources — first the local ones (code, man pages, docs), then the internet. This is not optional.

When the user asks a question, only answer it — take no other action.

Only run `sudo` commands when I explicitly ask you to run that specific command with elevated privileges. Never invoke `sudo` on your own initiative — if a step needs root and I haven't asked you to run it, hand me the exact command to run myself and wait for me to do it.

Theme preference: I use **Catppuccin Mocha** everywhere. When a tool or config supports theming, default to Catppuccin Mocha and keep everything visually consistent with it.

Whenever you install a Homebrew or Cargo package for me, update my package manifest at `~/.local/share/applications/PACKAGES.md` in the same task (add the package, its version, and what it is; keep the counts and reinstall commands accurate).

Whenever you audit something, propose more than one action or finding, or otherwise produce a multi-item plan, build a checklist — use the harness task/todo list feature when it is available, otherwise a plain checklist in your reply. Report that checklist back to me every time you finish one or more of its items, showing what is done and what remains, and add any newly discovered items to it as they arise.

When such a checklist gets implemented as code, structure the delivery so that each group of items (a tier, phase, or section) is one pull request, and each individual item is its own commit pushed to that PR's branch — never one giant commit or PR for the whole plan. Before you start implementing a group, ask me two things: in what order to implement the items within the group, and whether to check in with me after each item or run autonomously through to the end of the group. Honour the project's own git workflow (branch naming, commit-message convention, merge target, and required gates) for the mechanics.

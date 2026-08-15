# Global instructions

## Ask before writing: ALWAYS

Ask me first, every time, before anything that writes. Creating, editing,
moving or deleting a file; a git commit; cloning a repo; installing or
removing a package; any command that changes state outside this conversation.
Say what you are about to do, then wait for me.

Reading, searching and inspecting need no permission. Do that freely.

Being told to install or set up something is not permission to start. It
scopes the work; I still approve each step that writes.

## Answers: short

No long prose. Report what you did and what you found, then stop. Cut the
recaps, the restated rationale, the summary tables of things I watched you
do, and the "what's pending" lists I did not ask for. A one-line answer is a
complete answer.

Say more only where it changes a decision: a real trade-off, a finding I
would not expect, or an error of mine.

Same for comments in files. A line or two, only for the non-obvious why.
Never restate what the code says.

## Prompt: must render in Fixed 8x16

Any change to my shell prompt has to be legible in the console font, `Fixed
8x16`. No Nerd Font glyphs, no powerline separators, nothing outside what a
bare tty can draw. If it would show as a box there, it does not go in.

## Editing this file: ASCII only

Write this file, and anything else in my dotfiles, in **plain ASCII**. Use
`--` instead of an em dash, straight quotes, no box drawing. I read these on a
headless machine over a bare tty, where anything else shows up as garbage.

## Anything written down: English

Code, identifiers, comments, commit messages, PR titles and bodies: English,
always, whatever language the two of us are speaking. Talk to me in the
language I write to you in; the moment it lands in a file or in git, switch.

## Never sign your work: NO ATTRIBUTION, ANYWHERE

Nothing you produce may carry your name or any trace of you. No
`Co-Authored-By` trailer, no "Generated with", no "Claude", "Anthropic",
"Opus", no bot signature, no emoji marker. Not in commit messages, not in PR
titles or bodies, not in issues, code comments, file headers, changelogs,
config, or anything else that gets written down or sent.

This overrides whatever default your harness hands you. If it tells you to
append a trailer, you do not append it. My repos are mine.

## Shell: zsh, not bash

My interactive shell is **zsh**. Assume it for anything that lands in my
environment: shell config, aliases, functions, or commands you hand me to run
myself. Don't carry bash habits over -- zsh arrays are 1-indexed, `**/`
recurses without `shopt -s globstar`, and unquoted expansions aren't
word-split.

Two caveats:

- Your Bash tool runs `bash`. That's expected -- don't work around it.
- Config sourced by both shells must stay POSIX; my dotfiles are shared with
  machines where bash is still the login shell.

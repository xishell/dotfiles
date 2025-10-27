# (1) Fast safe defaults
setopt no_nomatch
mkdir -p "$ZSH_CACHE_DIR" "$ZSH_CACHE_DIR/completion"

# (2) Environment
for f in $ZDOTDIR/env/*.zsh(.N); do source "$f"; done

# (3) zinit + plugins
source "$ZDOTDIR/plugins/zinit.zsh"
source "$ZDOTDIR/plugins/bundles.zsh"

# (4) Shell behavior
for f in $ZDOTDIR/shell/*.zsh(.N); do source "$f"; done

# (5) Completion
source "$ZDOTDIR/comp/init.zsh"

# (6) Aliases
for f in $ZDOTDIR/aliases/*.zsh(.N); do source "$f"; done

# (7) Functions dir (autoloadable)
fpath=($ZDOTDIR/functions $fpath)
autoload -Uz $^fpath(:t) 2>/dev/null

# (8) Prompt (p10k)
source "$ZDOTDIR/prompt/init.zsh"

# (9) Per-host
[[ -r $ZDOTDIR/host/$(hostname -s).zsh ]] && source "$ZDOTDIR/host/$(hostname -s).zsh"

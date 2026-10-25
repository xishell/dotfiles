# direnv 2.37 ignores DIRENV_LOG_FORMAT, so wrap the hook to drop its
# loading/export noise (keeps real errors)
eval "$(direnv hook zsh)"
_direnv_hook() {
  trap -- '' SIGINT
  eval "$(direnv export zsh 2> >(grep -vE 'direnv: (loading|export )' >&2))"
  trap - SIGINT
}

# Resolve real dotfiles dir (this script may be reached via symlink)
_zshrc_dir="${${(%):-%x}:A:h}"

# Source common config fragments in numeric order
for _f in "$_zshrc_dir"/.zshrc.d/*.zsh(N); do
    source "$_f"
done

# Source OS-specific fragments
case "$OSTYPE" in
    darwin*) _zshrc_os="$_zshrc_dir/.zshrc.d/os.darwin" ;;
    linux*)  _zshrc_os="$_zshrc_dir/.zshrc.d/os.linux"  ;;
esac
if [ -n "$_zshrc_os" ]; then
    for _f in "$_zshrc_os"/*.zsh(N); do
        source "$_f"
    done
fi

unset _f _zshrc_dir _zshrc_os

# ccache for ESP-IDF builds
export IDF_CCACHE_ENABLE=1


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/elliot/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/elliot/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/elliot/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/elliot/google-cloud-sdk/completion.zsh.inc'; fi

# --- Completions early; prime compinit once via zinit helpers ---
zinit ice depth"1" wait"0" lucid blockf atload"zicompinit; zicdreplay"
zinit light zsh-users/zsh-completions

# --- Suggestions & syntax (defer a bit) ---
zinit ice depth"1" wait"1" lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

zinit ice depth"1" wait"2" lucid
zinit light zsh-users/zsh-syntax-highlighting

# --- fzf-tab (you already use its styles below) ---
zinit ice depth"1" wait"0" lucid
zinit light Aloxaf/fzf-tab

# --- Oh-My-Zsh git plugin for OMZP::git aliases you like ---
zinit ice wait"0" lucid svn
zinit snippet OMZ::plugins/git

# Optional OMZ libs (if you used any of their helpers)
zinit ice wait"0" lucid svn
zinit snippet OMZ::lib/termsupport

# --- Prompt (Powerlevel10k) ---
zinit ice depth"1" wait"0" lucid
zinit light romkatv/powerlevel10k

# --- Handy extras you mentioned/implicitly use ---
# zoxide adds 'z'—you’re eval’ing; we’ll still keep eval in integrations for your cd override
zinit ice depth"1" wait"0" lucid
zinit light ajeetdsouza/zoxide

# direnv (keep eval hook in integrations for project envs)
zinit ice depth"1" wait"0" lucid
zinit light direnv/direnv

# fzf (bindings are via brew; we keep your eval in integrations)
zinit ice depth"1" wait"0" lucid
zinit light junegunn/fzf

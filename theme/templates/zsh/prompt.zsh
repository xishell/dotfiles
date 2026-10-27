# pure prompt colours: dir cyan, branch purple, ❯ green / red on error
zstyle :prompt:pure:path                  color '{{ cyan }}'
zstyle :prompt:pure:git:branch            color '{{ magenta }}'
zstyle :prompt:pure:git:branch:cached     color '{{ red }}'
zstyle :prompt:pure:git:dirty             color '{{ yellow }}'
zstyle :prompt:pure:git:arrow             color '{{ cyan }}'
zstyle :prompt:pure:git:stash             color '{{ cyan }}'
zstyle :prompt:pure:git:action            color '{{ yellow }}'
zstyle :prompt:pure:prompt:success        color '{{ green }}'
zstyle :prompt:pure:prompt:error          color '{{ red }}'
zstyle :prompt:pure:prompt:continuation   color '{{ comment }}'
zstyle :prompt:pure:execution_time        color '{{ yellow }}'
zstyle :prompt:pure:user                  color '{{ comment }}'
zstyle :prompt:pure:user:root             color '{{ red }}'
zstyle :prompt:pure:host                  color '{{ comment }}'
zstyle :prompt:pure:virtualenv            color '{{ comment }}'
zstyle :prompt:pure:suspended_jobs        color '{{ red }}'

# One line: pure joins its path/git line and the ❯ line with $prompt_newline; an empty
# expansion (%666v, an unset psvar) plus a space puts them side by side
prompt_newline='%666v '

# No blank line between commands: pure prints one before every prompt (a bare `print` in
# prompt_pure_preprompt_render, no option for it), so mute argument-less print while it runs
if (( $+functions[prompt_pure_preprompt_render] )); then
    functions[_ember_pure_preprompt_render]=$functions[prompt_pure_preprompt_render]
    prompt_pure_preprompt_render() {
        print() { (( $# )) && builtin print "$@" }
        _ember_pure_preprompt_render "$@"
        local ret=$?
        unfunction print
        return ret
    }
fi

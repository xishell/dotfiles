# pure prompt colours (Tokyo Night Ember): dir blue, branch magenta, ❯ green / red on error
zstyle :prompt:pure:path                  color '{{ blue }}'
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

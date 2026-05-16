# Status
alias gs='git status --short'
alias gsl='git status'

# Stash
alias gstpm='git stash push -m'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gsta='git stash apply stash@{0}'
alias gsta1='git stash apply stash@{1}'
alias gsta2='git stash apply stash@{2}'
alias gsta3='git stash apply stash@{3}'
alias gstp1='git stash pop stash@{1}'
alias gstp2='git stash pop stash@{2}'
alias gstp3='git stash pop stash@{3}'

# Add & Push
alias gal='git add .'
alias gpo='git push origin'
alias gpom='git push origin main'
alias gpomf='git push origin main --force'

# Restore & Reset
alias gr='git restore'
alias grl='git restore .'
alias grs='git restore --staged'
alias grsl='git restore --staged .'
alias greh='git reset HEAD~1'
alias greh2='git reset HEAD~2'
alias greh3='git reset HEAD~3'
alias greh4='git reset HEAD~4'
alias greh5='git reset HEAD~5'
alias greh6='git reset HEAD~6'
alias greh7='git reset HEAD~7'

# Commit
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'

# Checkout & Switch & Branch
alias gsw='git switch'
alias gswc='git switch -c'
alias glogo='git log --oneline'
# requires fzf
alias gbz='git branch | fzf'
alias gsz='git switch $(gbz)'

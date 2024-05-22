# Git

## Diff with no context

To only see the changes without context:

```sh
git diff --unified=0
# or
git diff -U0
```

```
       -U<n>, --unified=<n>
           Generate diffs with <n> lines of context instead of the usual
           three. Implies --patch.
```

why? quicker glimpse on what has changed
## `rebase --interactive/-i`

### Edit an old commit

create a new "fix-up" commit that, as it's name suggests, fix an old commit with a certain hash of `<OLD_HASH>`.

```sh
git add <changes>
git commit --fixup=<OLD_HASH>
```

Next we do an interactive rebase starting from one commit before `<OLD_HASH>`

```sh
git rebase --interactive --autosquash <COMMIT_BEFORE_OLD_HASH>
```

After executing this command, your default editor will open up, and you then just have to save and quit.

> [!CAUTION]
> Note that these operations will rewrite history and this can be problematic in collaborative environments.
So when you're about to force-push your new commits to the remote repository do it with caution.
## Signing commits with SSH


## Sign Commits (with SSH)

```sh
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/examplekey.pub

# If you don’t want to type the -S flag every time you commit, tell Git to sign your commits automatically:
git config --global commit.gpgsign true
```

To sign:

```sh
# Use the -S flag when signing your commits:
# Note that:
# - If your SSH key is protected, Git prompts you to enter your passphrase.

git commit -S -m "My commit msg"

# To sign the last commit
git commit --amend --no-edit -S
```

### Local verificaiton and allowed users

Signature verification uses the `allowed_signers` file to associate emails and SSH keys.
For reasons why we should do this for ssh signs, read [this](https://blog.dbrgn.ch/2021/11/16/git-ssh-signatures).
To verify commits locally, create an allowed signers file for Git to associate SSH public keys with users:

```sh
touch "~/.ssh/allowed_signers"

# Configure the allowed_signers file in Git:
git config gpg.ssh.allowedSignersFile "~/.ssh/allowed_signers"

# Add your entry to the allowed signers file.
# Declaring the `git` namespace helps prevent cross-protocol attacks.
echo "$(git config --get user.email) namespaces=\"git\" $(cat ~/.ssh/<MY_KEY>.pub)" >> ~/.ssh/allowed_signers

# Repeat the previous step for each user who you want to verify signatures for.
# Consider checking this file in to your Git repository if you want to locally verify signatures for many different contributors.

# Use git log --show-signature to view the signature status for the commits:
```


### Sign Previous commits

Read [this ](https://safjan.com/git-sign-commit-n-commits-back) article for more details.

sign last 5 commits

```sh
git rebase -i HEAD~5
# In the editor change 'pick' to 'edit' for all the commits that you want to
# sign (or any other change). Save and quit

# Git goes over that last commit towards the first commit.

# Do whatever change you want to do on this commmit
git commit --amend --no-edit -S

# Continue rebae
git rebase --continue

# Sign this commit and so on
git commit --amend --no-edit -S
# maybe you also want to tag it (do it after you've signed it)
git tag v3.4.5

git rebase --continue

# ...
```


### Good resources:

- https://docs.gitlab.com/ee/user/project/repository/signed_commits/ssh.html
- https://safjan.com/git-sign-commit-n-commits-back
- https://blog.dbrgn.ch/2021/11/16/git-ssh-signatures/


## Undo

```sh
git restore --staged <file/dir>
```

Note: `git rm --cached <filePath>` does not unstage a file, it actually stages the removal of the file(s) from the repo (assuming it was already committed before) but leaves the file in your working tree (leaving you with an untracked file).
That said, if you used `git rm --cached` on a new file that is staged, it would basically look like you had just unstaged it since it had never been committed before.[1]

In previous versions of git this commands were used as well
```sh
# [1]
git reset -- <filePath> # will unstage any staged changes for the given file(s).

# [2]
# unstages any modifications made to the file since the last commit (but doesn't
# revert them in the filesystem, contrary to what the command name might
# suggest**). The file remains under revision control.
git reset HEAD <file>
```

Refs:
1. [1](https://stackoverflow.com/a/6919257/13041067)
1. [2](https://stackoverflow.com/a/26433550/13041067)

---


---
title: My Notes
author: Ali Bozorgzadeh
lang: en-US
date: |
    Last Updated: May 24, 2024
...

---

# [Git](#git)

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


# [C/C++](#cc)


## Compiler Flags

If you run the following in the command-line
`man gcc | nl | tail -1`,
you get something more than 20k (in my case: 24136).
It's none other than the lines of documentation in the [`gcc`]() man page.

The following is a curated (dynamic) list of c-compiler flags I found from stackoverflow and some other places.

- `-std=c17 -pedantic`
- `-Wall -Wextra`: Essential.
- `-Wfloat-equal`: Useful because usually testing floating-point numbers for equality is bad.
- `-Wundef`: Warn if an uninitialized identifier is evaluated in an #if directive.
- `-Wshadow`: Warn whenever a local variable shadows another local variable, parameter or global variable or whenever a built-in function is shadowed.
- `-Wpointer-arith`: Warn if anything depends upon the size of a function or of void.
- `-Wcast-align`: (\*) Warn whenever a pointer is cast such that the required alignment of the target is increased. For example, warn if a char  is cast to an int * on machines where integers can only be accessed at two- or four-byte boundaries.
- `-Wstrict-prototypes`: Warn if a function is declared or defined without specifying the argument types.
- `-Wstrict-overflow=5`: Warns about cases where the compiler optimizes based on the assumption that signed overflow does not occur. (The value 5 may be too strict, see the manual page.)
- `-Wwrite-strings`: (\*) Give string constants the type const char[length] so that copying the address of one into a non-const char  pointer will get a warning.
- `-Waggregate-return`: Warn if any functions that return structures or unions are defined or called.
- `-Wcast-qual`: (\*) Warn whenever a pointer is cast to remove a type qualifier from the target type.
- `-Wswitch-default`: (\*) Warn whenever a switch statement does not have a default case.
- `-Wswitch-enum`: (\*) Warn whenever a switch statement has an index of enumerated type and lacks a case for one or more of the named codes of that enumeration.
- `-Wconversion`: (\*) Warn for implicit conversions that may alter a value.
- `-Wunreachable-code`: (\*) Warn if the compiler detects that code will never be executed.
- `-Wformat=2`: Extra format checks on printf/scanf functions. [src](https://stackoverflow.com/questions/3375697/what-are-the-useful-gcc-flags-for-c#comment3530351_3376483)
- `-fsanitize={address,thread,undefined}`: enables the AddressSanitizer, ThreadSanitizer and UndefinedBehaviorSanitizer code sanitizers, respectively. These instrument the program to check for various sorts of errors at runtime. [src](https://stackoverflow.com/a/3376416)

All the flags in a format suitable to be put in a `Makefile`.

```make
# Nice Flags! https://stackoverflow.com/a/3376483
# Those marked  sometimes give too many spurious warnings, so I use them on as-needed basis.
# http://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
CFLAGS := -std=c17 -pedantic
CFLAGS += -g #-ggdb
# Essential.
CFLAGS += -Wall -Wextra
# Useful because usually testing floating-point numbers for equality is bad.
CFLAGS += -Wfloat-equal
# Warn if an uninitialized identifier is evaluated in an #if directive.
CFLAGS += -Wundef
# Warn whenever a local variable shadows another local variable, parameter or global variable or whenever a built-in function is shadowed.
CFLAGS += -Wshadow
# Warn if anything depends upon the size of a function or of void.
CFLAGS += -Wpointer-arith
# * Warn whenever a pointer is cast such that the required alignment of the target is increased. For example, warn if a char  is cast to an int * on machines where integers can only be accessed at two- or four-byte boundaries.
CFLAGS += -Wcast-align
# Warn if a function is declared or defined without specifying the argument types.
CFLAGS += -Wstrict-prototypes
# Warns about cases where the compiler optimizes based on the assumption that signed overflow does not occur. (The value 5 may be too strict, see the manual page.)
CFLAGS += -Wstrict-overflow=5
# * Give string constants the type const char[length] so that copying the address of one into a non-const char  pointer will get a warning.
CFLAGS += -Wwrite-strings
# Warn if any functions that return structures or unions are defined or called.
CFLAGS += -Waggregate-return
# * Warn whenever a pointer is cast to remove a type qualifier from the target type.
CFLAGS += -Wcast-qual
# * Warn whenever a switch statement does not have a default case.
CFLAGS += -Wswitch-default
# * Warn whenever a switch statement has an index of enumerated type and lacks a case for one or more of the named codes of that enumeration.
CFLAGS += -Wswitch-enum
# * Warn for implicit conversions that may alter a value.
CFLAGS += -Wconversion
# * Warn if the compiler detects that code will never be executed.
CFLAGS += -Wunreachable-code
# Extra format checks on printf/scanf functions. https://stackoverflow.com/questions/3375697/what-are-the-useful-gcc-flags-for-c#comment3530351_3376483
CFLAGS += -Wformat=2
# enables the AddressSanitizer, ThreadSanitizer and UndefinedBehaviorSanitizer code sanitizers, respectively. These instrument the program to check for various sorts of errors at runtime. https://stackoverflow.com/a/3376416
CFLAGS += -fsanitize={address,thread,undefined}
```

### Useful Resources

- [GCC's documentation on Warning Options](http://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html)
- [Useful GCC Compiler Options](https://gist.github.com/g-berthiaume/74f0485fbba5cc3249eee458c1d0d386)

---

# [Make](#make)

<!-- <hr color="black" width="50%" style="margin: 30px auto;" /> -->

## [Functions for File Names](https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html#index-abspath-1)

Get the info page with `info make <func>`

```make
# https://www.gnu.org/software/make/manual/html_node/Wildcards.html
# $(wildcard pattern)
objects := $(wildcard *.o)  # -> objects = *.o
$(wildcard *.c *.h) # -> all files matching ‘.c’, sorted, followed by all files matching ‘.h’, sorted
objects := $(patsubst %.c,%.o,$(wildcard *.c))


# $(dir names…)
$(dir src/foo.c hacks) # -> 'src/ ./'
# src: https://stackoverflow.com/q/76457244
SUBDIRS := $(dir $(wildcard */Makefile)) # -> Return (depth=1) all directories containing a Makefile


# $(notdir names…)
$(notdir src/foo.c hacks) # -> 'foo.c hacks'


# $(suffix names…)
$(suffix src/foo.c src-1.0/bar.c hacks) # -> '.c .c'


# $(basename names…)
$(basename src/foo.c src-1.0/bar hacks) # -> 'src/foo src-1.0/bar hacks'


# $(addsuffix suffix,names…)
$(addsuffix .c,foo bar) # -> 'foo.c bar.c'


# $(addprefix prefix,names…)
$(addprefix src/,foo bar) # -> 'src/foo src/bar'.


# $(join list1,list2)
$(join a b,.c .o) -> 'a.c b.o'


# $(realpath names…)
# - return the canonical absolute name (no . or .. components nor any repeated /) or symlinks.
# - In case of a failure the empty string is returned.


# $(abspath names…)
# - returns canonical absolute name
# - unlike realpath:
#   - does not resolve symlink
#   - does not care whether file exists (check for existence with wildcard function)
```

<hr color="white" style="margin: 20px auto;" />

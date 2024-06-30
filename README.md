---
title: My Notes
author: Ali Bozorgzadeh
lang: en-US
date: |
    Last Updated: May 25, 2024
...

---

# [Git](#git)

## [Diff with no context](#diff-with-no-context)

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

## [`rebase --interactive/-i`](#rebase---interactive-i)

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

## [Sign Commits (with SSH)](#sign-commits-with-ssh)

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

## [Undo](#undo)

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

- [https://stackoverflow.com/a/6919257/13041067](https://stackoverflow.com/a/6919257/13041067)
- [https://stackoverflow.com/a/26433550/13041067](https://stackoverflow.com/a/26433550/13041067)

## [List staged files](#list-staged-files)

```sh
# --cached/--staged: Changes between the index and your current HEAD.
# --name-only: Show only names of changed files.
git diff --name-only --cached/--staged

# --diff-filter: Only show (filter) staged files that are added (A), modified (M) etc.
# https://stackoverflow.com/a/2299672
# --diff-filter=d: only ignore deleted files (https://stackoverflow.com/questions/33610682/git-list-of-staged-files#comment130876160_33610683)
# you can add --no-pager to prevent the list be shown in a pager
git diff --name-only --cached --diff-filter=AM
```

[src](https://stackoverflow.com/a/33610683)

## [Get entries from config](#get-entries-from-config)

```sh
# To list all the entries (all the key=value)
git config --local/--global/--system --list/-l

# To list only the keys (names)
git config --local --list --name-only


# In case of failure returns non-zero exit code
# To query for the hooksPath
git config --local --get core.hooksPath

# [src](https://stackoverflow.com/a/76535305)
git config --global --list # to display list of all configurations.
git config --global --get  # user.name shows your username.
git config --global --get  # user.email displays your email.
git config --global credential.helper # verify credentials.
git config --global gui.recentrepo    # find your recent repo.
```

## [Show the HEAD and staged version of source](#show-the-head-and-staged-version-of-source)

```sh
# The HEAD version of the file
# you could use any other revision instead of HEAD
git show HEAD:path/to/file

# Files that are stored in the index have a stage number, usually zero.
# (Staging slots 1, 2, and 3 are used during conflicted merges.)
# To refer to the staged copy of the file, use the revision
# `:number:path/to/file`. When the `number` is zero (which usually is),
# one can omit the leading `:0`, leaving `:path/to/file`.
git show :0:path/to/file
git show :path/to/file
```

[src](https://stackoverflow.com/a/60854287)

## [GitHub Search Filters](#github-search-filters-from-krystian-safjans-blog) (from [Krystian Safjan's Blog](https://www.safjan.com/github-search-techniques/))

| Filter           | Search                                                |
|:-----------------|:--------------------------------------------------    |
| __"in:name"__                   | "Ruby-Projects in:name".               |
| __"in:description"__            | "machine learning in:description".     |
| __"in:readme"__                 | "learn ruby in:readme".                |
| __"in:topic"__                  | "mobile development in:topic".         |
| __"org:"__                      | (organization): "org:Microsoft".       |
| __"license:"__                  | "license:Apache-2.0".                  |
| __"stars:>"__                   | "stars:>1000".                         |
| __"forks:>"__                   | "forks:>1000".                         |
| __"language:"__                 | "language:ruby"                        |
| __"Created"__ or __"Updated"__  | "in:date created:>2023-06-01".         |
| __"pushed:>"__                  | "pushed:>2023-03-01 rails"             |

> These techniques can help you quickly find the repositories you need. These search tips can transform the task of searching for repositories into an enjoyable and productive experience.

---

# [C/C++](#cc)

## [Compiler Flags](#compiler-flags)

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

## [Functions for File Names](#functions-for-file-names)

[Documentation: Functions for File Names](https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html#index-abspath-1)

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


## [Suppress printing the current directory](#suppress-printing-the-current-directory)

`--no-print-directory` flag or:

```make
ifndef VERBOSE
MAKEFLAGS += --no-print-directory
endif
```
[src](https://stackoverflow.com/a/8080887/13041067)

or

```make
MAKEFLAGS += $(if $(value VERBOSE),,--no-print-directory)
```

[src](https://stackoverflow.com/a/8080887/13041067)

Note: variable assignment can't occur within an expansion which in turn is due
to how Make parses makefiles.

```make
# error
$(if $(VERBOSE),,MAKEFLAGS += no-print-directory))
```

The only way to include variable assignment (or something else like rule
definition) into an expandable code (`$(if ...)` in above examples) is `eval`
function.

[src](https://stackoverflow.com/questions/8028137/how-to-specify-no-print-directory-within-the-makefile-itself#comment10034695_8080887)


# [Regular Expressions](#regular-expressions)

## [Look around assertions](#look-around-assertions)

### Perl syntax [1]

- `(?=pattern)`: positive look-ahead assertion
- `(?!pattern)`: negative look-ahead assertion
- `(?<=pattern)`: positive look-behind assertion
- `(?<!pattern)`: negative look-behind assertion

### Vim syntax [2]

There are two ways. One specifying the __start__ and __end__ of match:

- mark the start of your match with `\zs`
- mark the end of your match with `\ze`

```
foo \zsbar\ze baz
# matches 'foo bar baz' but not 'foo bar qux' nor 'foo bar' nor 'foo'
```

The other is using Perl-like syntax of assertion (very-magic mode).

- `(atom)@=`: positive look-ahead assertion
- `(atom)@!`: negative look-ahead assertion
- `(atom)@<=`: positive look-behind assertion
- `(atom)@<!`: negative look-behind assertion

For non-very-magic mode escape like: `\(`, `\)`, and `\@`

```
(foo )@<=bar( baz)@=
# matches "bar" in "foo bar baz" not in "foo bar qux" etc.

(mi )@<=casa
# matches "casa" if preceded by "mi "

(mi )@<!casa
# matches "casa" if not preceded by "mi "

dad\.@=
# matches "dad" if followed by a period

dad\.@!
# matches "dad" if not followed by a period
```

### Reference

- [[1]: https://www.perlmonks.org/?node_id=518444](https://www.perlmonks.org/?node_id=518444)
- [[2]: https://vim.fandom.com/wiki/Regex_lookahead_and_lookbehind](https://vim.fandom.com/wiki/Regex_lookahead_and_lookbehind)

### Further Readings

- [Mastering Lookahead and Lookbehind](https://www.rexegg.com/regex-lookarounds.html)


# [Vim](#vim)

## [Macro Tips](#macro-tips)

### Prevent infinite looping

Temporarily disable `wrapscan` option. [(src)](https://stackoverflow.com/a/18750434/13041067)

```
set nowrapscan
# 'wrapscan': Searches wrap around the end of the file. hi
```

### Stop a running macro

Press `C-c`.

### Speed up macro execution

One of the ways to speed up the macro is to make it silent! [(src)](https://stackoverflow.com/a/18750434/13041067)

```vim
:silent! normal 1000@q
:silent! norm 1000@q
```

Another way is to enable `lazyredraw`:

```vim
set lazyredraw
```

### Apply macro in a range or lines matching a /pattern/

```vim
:        0,.   normal @q  " from the beginning of the file to the current line
:        .,$   normal @q  " from current line to end of the file
:        0,$   normal @q  " from the beginning to the end of the file (the whole buffer)
:        %     normal @q  " also, the whole buffer
:silent! 3,5   normal @q  " from line 3 to line 5
:silent! -2,+1 normal @q  " from two line above to one line below the current line
:silent! '<,'> normal @q  " in a selection
:   g/pattern/ normal @q  : all lines matching /pattern/
```

### Editing a macro

Let's say we forgot to go the beginning of the line at the end of the macro `q`.
We can fix it in two ways. [(src)](https://thoughtbot.com/blog/how-to-edit-an-existing-vim-macro)

Yanking it into a register:

- `"qp` paste the contents of the register to the current cursor position
- `I` enter insert mode at the begging of the pasted line
- `^` add the missing motion to return to the front of the line
- `<Escape>` return to visual mode
- `"qyy` yank this new modified macro back into the q register
- `dd` delete the pasted register from the file your editing


 Editing the register visually:

- `:let @q='` open the q register
- `<Cntl-r><Cntl-r>q` paste the contents of the q register into the buffer
- `^` add the missing motion to return to the front of the line
- `'` add a closing quote
- `<Enter>` finish editing the macro


# [FFMPEG](#ffmpeg)

## [Extract subtitle from a video](#extract-subtitle-from-a-video)

```sh
ffmpeg -i Movie.mkv -map 0:s:0 subs.srt
```

- `-i`: Input file URL/path.
- `-map`: Designate one or more input streams as a source for the output file.
- `s:0`: Select the subtitle stream.
  - `0:s:0` would download the first subtitle track. If there are several, use `0:s:1` to download the second one, `0:s:2` to download the third one, and so on.

[(src)](https://superuser.com/a/927507)


# [TeX](#tex)

## [Caption](#caption)

```tex
% ... in the preamble

% For caption settings
\usepackage[labelformat=simple,figurename=Fig.,labelfont=bf,textfont=it]{caption}

% For subfigure captions
\usepackage{subcaption}

% ... in the document

\caption[Short caption that appear in \listoffigures]{Long caption that appear in text}

% A caption that doesn't appear under the figure
\captionlistentry[figure]{Natural Numbers}
\captionlistentry*[figure]{Integers Numbers} % unnumbered

```

## [Vertical Bar of Evaluation](#vertical-bar-of-evaluation)

Encapsulate with `\left.` and `\right\vert_{a}{b}`

```
% in math mode
\left. {some more stuff} \right\vert_{0}^{\infty}
```

This will automatically set the height of the vertical bar.

Or you can use to manually control the height of the vertical bar:

```
% in math mode
{some math stuff}\big\rvert
{some math stuff}\bigr\vert
{some math stuff}\bigg\rvert

{some math stuff}\Big\rvert
{some math stuff}\Bigr\vert
{some math stuff}\Bigg\rvert
```

Note: sometimes under the radical (`\sqrt`) get tall enough that changes the angle of the radical.
In this case my not so much interesting solution is to reduce the height.


## [Underfill problem texttt](#underfill-problem-texttt)


```tex
\texttt{lagrangian/basic} % warning: Underfull \hbox (badness 1360) in paragraph at lines
\texttt{lagrangian\slash basic} % no wraning
```


# [FreeCAD](#freecad)

## [Exporting](#exporting)

### Correct Orientation When Exporting

To get the orientation of the body and no the last action, you have to select the body before
exporting.

### But Paraview uses Y as up axis

FreeCAD by default uses the x-y as the base 2d coordinate and Z as up axis. Paraview, uses Y
as up axis. To fix you must rotate it. To do so, in the combo view select all the things you want to
rotate. Then go to data tab and there double-click on `Placement`. There set the axis of rotation to
`x` (set it to `1.0`) (if you have your body sketched in the front view) and set the `degree` to
`-90`. Finally export it and view the result in paraview.

[src (Although it didn't immediately help and had to try many things out for so long)](https://forum.freecad.org/viewtopic.php?t=13081)


## [Bounding box](#bounding-box)

Not sure how it can be done in FreeCAD yet. As a workaround, export the model to stl/obj and open it
with ParaView and in the properties panel see the span of x, y and z of the geometry.


<hr color="white" style="margin: 20px auto;" />


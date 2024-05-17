#!/usr/local/bin/tcsh
###########################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
###########################################################

# This file sets up the cshell environment

# WARNING: this file is a template only. It should be copied into your $HOME directory and modified to suit you

set autolist
set backslash_quote
set dextract
set dunique
set filec
set lineedit
set matchbeep=nomatch
set history=1000
unset histdup  # I have occasionally had trouble, if this is set to 'erase', with the previous command not getting saved
set savehist=(1000 merge)   # if you append 'lock' then you need to make a mechanism to remove lock file when stuck
set histfile=~/.csh_history
unset autologout
unset glob
set path = ( $path /sbin/ )   # Required on Debian

set HOST=$HOST:ar
setenv HOST $HOST:ar

# Exit from .cshrc if not interactive
# Be aware that gtmtest sometimes invokes tcsh using -c or << which are considered 'interactive'.
# So don't print stuff below unless you're prepared for it to appear in the output of some tests.
if ( ! $?edit ) goto quit

bindkey "^R" i-search-back
bindkey "\e[1;5D" backward-word  # ctrl-left
bindkey "\e[1;5C" forward-word   # ctrl-right

alias ls 'ls --color=auto'
alias ll 'ls -alF'
alias la 'ls -A'

alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'

# Handy git shortcuts
alias gitlog 'git log --graph --pretty=format:"%C(auto)%ad %h%d %s" --date="short"'
alias gitup 'git fetch upstream && git rebase upstream/master'

# USER-SPECIFIC LOCATIONS for YottaDB's gtmtest
setenv mailid berwyn@yottadb.com   # Replace with your email here
setenv build_id 996   # Your build number: any 9xx no.; assigned by YottaDB on their servers: avoids clobbering others' builds
setenv verno V${build_id}_R201   # Change Rxxx to the revision of yottadb you will install and test against
setenv work_dir ~/work   # Where you wish to check out YDB, YDBTest, etc.
setenv gtm_root /usr/library   # Where your (and others') installed binaries go
setenv gtm_test $gtm_root/gtm_test   # Where to hold a copy of $work_dir/YDBTest to run from: it needn't be under $gtm_root
setenv tst_dir /testarea1/$USER   # Where to put the output of your test
setenv r ~/.gtmresults   # Where to create symlink that points to latest test results directory; short name for easy access
setenv gtm_test_com_individual $work_dir/YDBTest-dev/com   # Use your own tester-command scripts, not main YDBTest checkout (useful for when you are developing YDBTest/com separately from writing tests)
setenv force_gtm_test_com_individual   # gtmtest normally re-runs itself from gtmtest.csh in the test source dir. Prevent this.

# Other settings you're less likely to want to change
setenv tst_image dbg   # Select default production/debug build image (dbg/pro) to test against; change later with 'ver' alias
# Ensure gtm_curpro is at least a valid build - set if not already set by /etc/cshrc
if ! ($?gtm_curpro) setenv gtm_curpro $verno   # Subst for current production release used to createdb.csh and by some tests

# set args for gtmtest alias -- select useful ones for a developer
setenv gtmtest_args "-fg -noencrypt -k -nomail -dontzip -stdout 2"
# TEMPLATE: to prevent randomized test settings, use the following for settest_args and/or gtmtest_args
#   (all settings are necessary to avoid test errors)
setenv settest_args "$gtmtest_args -norandomsettings -nospanreg -noco -jnl nobefore -env eall_noinverse=1"

# The following settings are only used if you build using YDBDevOps (private to Yottadb developers)
#setenv ydb_cc_choose_clang 1; setenv CC clang   # Force clang build: it's faster. But be warned: this causes GT.M builds to fail.
#setenv ydb_cc_choose_asan 0   # asan catches address errors but slows down testing by about 10% (according to Sam)

# Set up the environment for running YottaDB's gtmtest
source $gtm_test_com_individual/test_env.csh

# Other Convenience settings

set cdpath = ( $work_dir )   # for convenient access to your repositories
if ( "$HOST" == "berwyn" && $shlvl == 2) then
  cleantests   # example auto-run on your machine: clean all but most recent day's test results the first time tcsh runs
endif

# Show git branch in prompt
setenv GIT_BRANCH "sh -c 'git branch --no-color 2> /dev/null' | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ [\1]/'"
alias precmd 'set prompt="%{\033[34m%}%B%{\033[31m%}%~%b%{\033[36m%}`$GIT_BRANCH`%{\033[0m%}%# "'
set promptchars=">#"   # use '>' prompt for users; '#' for root
# Avoid loss of history if you close your terminal window with your mouse by:
#   Merging history every minute (at next command) so that history from concurrent terminal window is saved
#   It would be better to save every user command, but avoid precmd or postcmd for reasons given here:
#   cf. https://unix.stackexchange.com/questions/88838/preserve-tcsh-history-in-multiple-terminal-windows
#set tperiod = 1   # Most frequent is 1 minute
#alias periodic 'history -M; history -S'

quit:
# Init the cshdebug.csh debugger if it was left on by the parent shell
if ( $?gtm_test_com_individual ) then
	source $gtm_test_com_individual/cshdebug.csh init "$0" "$*"
endif

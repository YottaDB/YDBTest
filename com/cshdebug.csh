#!/usr/bin/env tcsh
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

# Debugging tool to report source file and line number (ish) where errors occur in csh files.
# Source this script to run it.

set __self = "cshdebug.csh"   # Name of this script -- can't determine from $0, since the script is to be sourced
mkdir -p ~/.cshdebug

while ( "$1" =~ "-*" )
	if ( "$1" == "-h" || "$1" == "--help" ) then
		echo "This debugging tool reports source file and line number (ish) where errors occur in csh files."
		echo "BEWARE: the line numbering, does not count lines inside loops nor in skipped IF statements."
		echo "It uses a postcmd alias to do the hard work before every source line runs."
		echo "Be aware that it creates working files ~/.cshdebug/* to record the current line number"
		echo "for each new shell nesting level and new error occurrence. An 'error' count is"
		echo "incremented for any command that returns a nonzero exit code."
		echo "When you 'stop' the debugger, it will print a summary showing where each sub-script"
		echo "stopped running or had an error. The format of each output line is as follows:"
		echo "  <timestamp> <spawn_depth> <error#> <scriptname>:<line_no>: <ending/erroring source line, e.g. exit 1>"
		echo
		echo "Usage: cshdebug.csh [-h|--help] [-k] [-q] [start|stop|init]"
		echo "  No arguments is the same as 'start'."
		echo "  start  Restart debug tracing and set up postcmd to work magic."
		echo "  stop   Prints the source file each csh script sourced after running cshdebug.csh,"
		echo "         and the line number of each nonzero exit code produced,"
		echo "         then removes the record of the errors and restores the original postcmd alias."
		echo "  init <args> Run this on the very last line of .cshrc to enable nested script debugging."
		echo "         Initializes debugging if \$__cshdebug was previously defined by this script."
		echo "         Nested debugging only works if .cshrc is run (i.e. not with tcsh -f)."
		echo '         The <args> passed by .cshrc should be "$0" "$*"'
		echo "         Your .cshrc can check that the \$__cshdebug variable exists if it wants to do anything"
		echo "         special when the debugger is on and has just spawned a new script."
		echo "  -h     Display this help text"
		echo "  -k     Keep debugging trace in ~/.cshdebug/* so 'debug stop' can report multiple times."
		echo "  -q     Run quiet: don't print sourced and spawned lines to the terminal."
		echo
		echo "Several gotchas can occasionally alter the output, but it is usually still useful:"
		echo "* Multiple source statements on one line will reports errors as though all the sourced files"
		echo "  were appended to the first."
		echo "* Errors from the file or terminal that sourced cshdebug.csh in the first place will be"
		echo "  reported as file '_parent_'."
		echo "* Nested sourcing works except that when a sourced file completes, lines run after"
		echo "  it returns to its parent script will be numbered as if they were lines appended"
		echo "  to the child, until another file is sourced. This will be obvious when the line"
		echo "  number exceeds the length of the sourced file. Subtract the sourced files line count."
		echo "* Nested non-sourced scripts work only if the subshell runs .cshrc which must invoke"
		echo "  this script with the 'init' option. Scripts invoked with -f will not work, unless you replace"
		echo "  tcsh in your path with the provided tcshstub.sh file that calls the real tcsh without -f."
		echo "* Code lines that source scripts are detected by searching for 'source ' followed by a filename"
		echo "  that exists. Variable substitution of \$ is performed in the filename before detecting its existence."
		echo "  On rare occasions it might incorrectly detect a sourced file where the 'source <filename> is"
		echo "  quoted in the script but not actually run at that point. But this fact will be obvious in the code."
		echo "* Goto will mess up the line numbering."
		echo "* Any user's postcmd alias will be overwritten during" '`debug` and restored after `debug stop`.'
		exit
	endif
	if ( "$1" == "-k" ) then
		setenv __keeptrace   # use environment variable to propagate to spawned children
		shift
	endif
	if ( "$1" == "-q" ) then
		setenv __quiet   # use environment variable to propagate to spawned children
		shift
	endif
end

if ( "$1" == "stop" ) then
	# prints the source file each csh script sourced after running cshdebug, and the line number of each nonzero
	# exit code produced; then removes the record of the errors and removes the postcmd alias
	unalias postcmd
	if ( $?__postcmd ) then
		alias postcmd "$__postcmd:q"
	endif
	rm -f ~/.cshdebug/log-shlvl${shlvl}-error1-${__self:t}   # remove progress file for this $0 script
	# output the last non-blank line of each log file
	find ~/.cshdebug -maxdepth 1 -name "log-*" -exec sh -c "tac '{}' | grep -m1 '..:..\.... shlvl'" \; \
		| grep -vP "(?<=[ /])${__self}:[0-9]*:" | sort >! ~/.cshdebug/log
	if ( -s ~/.cshdebug/log ) then
		if ( ! $?__quiet ) then
			printf "\033[33m"
			printf "   # The following scripts stopped running or sourced other scripts at the following lines.\n"
			printf "   # Files listed more than once produced more than one nonzero exit codes at the given lines:\n"
			printf "\033[0m"
		endif
		# grep colours the output line number to terminals
		grep --color=auto -P "(?<=[ /])[^ :/]+:[0-9]*:" ~/.cshdebug/log
		if ( ! $?__quiet ) printf "\033[33m   # This report may be searched at ~/.cshdebug/log if you specified -k.\033[0m\n"
	endif
	if ! ( $?__keeptrace ) rm ~/.cshdebug -rf   # do this if you want to clean up debug artifacts after debug stops
	unset __errors __line __source __sourcename __maybe_source __quotecount __cmdline
	unsetenv __cshdebug __quiet __keeptrace
	unsetenv tst_tcsh   # let gtmtest set this up itself (YottaDB-specific)
	exit
endif

if ( "$1" != "start" && "$1" != "" && "$1" != "init" ) then
	echo "Unknown command line option(s) '$*'"
	echo "Try $__self --help"
	exit
endif

# Handle case where the script spawns another tcsh
set __source = "_parent_"   # initialize line of code containing the word 'source'
set __sourcename = "_parent_"   # initialize name of file to be sourced

if ( "$1" == "init" ) then
	if ! ( $?__cshdebug ) exit
	if ( "$2" == "" ) then
		set __source = "_unknown_"
		set __sourcename = "_unknown_"
	else
		set __source = ( $argv[2-]:q )
		set __sourcename = ( $argv[2-]:q )
		# Skip past tcsh options to get to script name
		while ( "$#__sourcename" >= 2 && "$__sourcename[1]" =~ "-*" )
			shift
		end
		set __sourcename = "$__sourcename[1]:q"
	endif
	if ( ! $?__quiet ) printf "   \033[34m\033[1m# \033[0m\033[33mSpawning\033[34m\033[1m: ${__source:q}\033[0m\n" >/dev/tty
else # else 'start':
	# Remove old files and start over
	echo -n >! ~/.cshdebug/log   # create dummy file so we don't get no match error below
	rm ~/.cshdebug/log* -rf
endif


# Make sure required variables exists for first run of postcmd
set __errors = 1
set __line = 0
set __quotecount = 0
if ! ( $?__postcmd ) set __postcmd = "`alias postcmd`"

# Alias to record source file and line number.
# The alias breaks down to this:
# * increment __errors if the previous command returned nonzero
# * increment __line
# * records current line source:line in relevant ~/.cshdebug/log-* file
# * if the command contains 'source ' then:
#     use grep to extract the <filename> after 'source' and if it exists then:
#      reset __line & __source
#      and print "Sourcing $__source" to /dev/tty
# Tech notes:
# * This must use postcmd which triggers every script line, not precmd which triggers only on user-entered lines.
#   Be aware that postcmd actually runs before the command, despite its name
#   (so $? is actually the result of the previous command)
# * This alias mustn't be converted multi-line alias or run a script, lest it count its own lines as line numbers!
# * Any use of \!#:q inside quoted backquotes fails at least when it contains parentheses: hence the need to
#   write it to ~/.cshdebug/cmdline before grepping it
# * Clumsy escaping of double-quotes and backslashes inside backquotes is the only way to get quoted
#   command substitution without errors

unalias postcmd
#set __debug_debugger   # uncomment to debug the debugger by printing lines it suspects might be source lines (before it checks)
alias postcmd 'if ( $? != 0 ) @ __errors++; @ __line++; echo "`date +%M:%S.%3N` shlvl${shlvl} error${__errors} ${__sourcename:q}:${__line}: \!#:q" >>! ~/".cshdebug/log-shlvl${shlvl}-error${__errors}-${__sourcename:t}"; unset __maybe_source; if ( "\!#:q" =~ "*source *" ) set __maybe_source; if ( $?__maybe_source && $?__debug_debugger ) printf "\033[91m[\!#:q]\033[0m\n" >/dev/tty; if ( $?__maybe_source ) echo "\!#:q" >! ~/.cshdebug/cmdline; if ( $?__maybe_source ) set __maybe_source="`set nonomatch; grep -oP \\"((?<=^source\\s)|(?<=[^a-zA-Z-_]source\\s))\\s*[^\\s()\\\\\\"]+\\" ~/.cshdebug/cmdline`"; if ( ! $?__maybe_source ) set __maybe_source; if ( "$__maybe_source" != "" && -f "`set nonomatch; echo \\"$__maybe_source:q\\"`" ) set __line=0; if ( $__line == 0 ) set __sourcename="$__maybe_source:q"; if ( $__line == 0 ) set __source="`head -1 ~/.cshdebug/cmdline`"; if ( $__line == 0 && ! $?__quiet && "$__sourcename:q" !~ "*$__self" ) printf "   \033[34m\033[1m# Sourcing: $__source:q\033[0m\n" >/dev/tty'

setenv tst_tcsh "tcsh"   # override gtmtest's version which includes "-f" (YottaDB-specific)
setenv __cshdebug "on"   # tell subshells .cshrc to init debugger
set __line = 0; find ~/.cshdebug/ -maxdepth 1 -name "log-shlvl*_parent_" -delete   # reset before running user commands

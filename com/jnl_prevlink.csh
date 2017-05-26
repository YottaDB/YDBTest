#!/usr/local/bin/tcsh -f
#
# Prints the name of the previous journal file for the input journal file
# If "-all"      is present, it runs through the chain of previous journal files and prints all their names
# If "-absolute" is present, the file names are printed along with their absolute path names. By default only the filename is printed
#
# e.g.
# -----
# a) jnl_prevlink.csh -f x.mjl                      --> prints the previous link of x.mjl (no absolute pathname)
# b) jnl_prevlink.csh -all -f x.mjl                 --> prints all previous links of x.mjl (no absolute pathname)
# c) jnl_prevlink.csh -all -absolute -f x.mjl       --> prints all previous links of x.mjl with absolute pathnames except x.mjl
# d) jnl_prevlink.csh -all -absolute -f `pwd`/x.mjl --> same as above except that absolute pathname is printed for x.mjl too
#

if ($#argv == 0) then
	echo ""
	echo "$0 [-all] [-absolute] <-f journal-file-whose-prevlink-is-to-be-printed>"
	echo ""
	exit -1
endif

# Note the 1-1 correspondence between opt_array and opt_name_array. Any additions/deletions must be done in both arrays.
set opt_array      = ("\-all" "\-absolute" "\-f*"   )
set opt_name_array = ("isall" "isabsolute" "mjlfile")
source $gtm_tst/com/getargs.csh $argv

if !($?mjlfile) then
	set mjlfile = ""
endif

while ("$mjlfile" != "")
	if ($?isall) then
		if !($?isabsolute) then
			set mjlfile = $mjlfile:t
		endif
		echo $mjlfile
	endif
	set mjlfile = `$MUPIP journal -show=header -forward -noverify $mjlfile |& grep "Prev journal file name" | sed 's/.*Prev journal file name[ 	]*//g'`
	if !($?isabsolute) then
		set mjlfile = $mjlfile:t
	endif
	if !($?isall) then
		echo $mjlfile
		break
	endif
end

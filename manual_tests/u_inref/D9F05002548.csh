#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2005, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# *** READ THE INSTRUCTIONS IN D9F05002548.txt ***
source ${0:h:h:h}/com/setup.csh $*
mkdir -p /testarea1/$user/$gtm_verno/manual_tests/D9F05002548_$$
cd /testarea1/$user/$gtm_verno/manual_tests/D9F05002548_$$
clear

echo $PWD
echo "Replay Setup :"
echo "source ${0:h:h:h}/com/setup.csh $*"

echo "**********************************************"
echo "YOU MAY NEED TO PLAY WITH THE TERM ENVIRONMENT"
echo "**********************************************"
echo "Most OSes faired well enough with xterm, vt420"
echo "and vt320. Use them in that order. Solaris must"
echo "use vt320. However for vt320 to work, the server"
echo "needed to have SunFreeWare terminfo settings"
echo "installed to /usr/local/lib/terminfo"
echo "**********************************************"
echo "Current TERMINAL Settings"
echo "TERM     = '`printenv TERM`'"
echo "TERMINFO = '`printenv TERMINFO`'"
stty -a > tty.before

# Treat screen differently
if ( "screen" != "$TERM" ) then
	if ( "linux" == "$gtm_test_osname" && "xterm" != "${TERM}" ) then
		setenv TERM vt420
		echo "TERM     = '`printenv TERM`'"
	endif
	if ( "sunos" == "$gtm_test_osname" ) then
		echo "Switching to vt320 for Solaris"
		setenv TERM vt320
		if ( -d /usr/local/lib/terminfo ) setenv TERMINFO /usr/local/lib/terminfo
		echo "TERM     = '`printenv TERM`'"
		echo "TERMINFO = '`printenv TERMINFO`'"
	endif
endif
if ( "hpux" == "$gtm_test_osname" ) then
	stty intr '^c'
	stty erase '^?'
endif
stty -a > tty.after
echo ""
echo "***** KNOWN ISSUES ***************************************************************"
echo "* Backspace and DEL are known to cause problems. Use the control-key forms below	*"
echo "* as needed.									*"
echo "*  Backspace	^H	control-H						*"
echo "*  DEL		^? 	control-shift-forward slash				*"
echo "**********************************************************************************"
echo ""
echo "**********************************************************************************"
echo "* A NOTE ABOUT THE INSTRUCTION:	 						 *"
echo "* Wherever user input is expected, the exact input to be given would be displayed	 *"
echo "* The ones between angular braces are the EDITING control characters	 	 *"
echo "* For e.g <ctrl-B> stands for control-B (^B) and <left> stands for left arrow 	 *"
echo "* PRESS return *ONLY* IF SPECIFIED AS <ret>				 	 *"
echo "**********************************************************************************"
echo ""

setenv gtm_principal_editing "NOINSERT:EDITING"
echo "#### Testing for gtm_principal_editing : $gtm_principal_editing ####"
$MUMPS -run noinsert^ttyread
echo ""
echo "Input the following:"
echo "do btest^ttyread<ctrl-A><right><right><right>a"
echo "The display should be 'do atest^ttyread'. Press <ret>"
echo "You should see the following message 'This is routine ATEST'"
$MUMPS -direct
setenv gtm_principal_editing "INSERT:EDITING"
echo "#### Testing for gtm_principal_editing : $gtm_principal_editing ####"
$MUMPS -run insert^ttyread
$MUMPS -run noecho^ttyread
echo ""
echo "Input the following:"
echo "do atest^ttyreadin<ctrl-B><crtl-B><ctrl-K>"
echo "The display should be 'do atest^ttyread'. Press <ret>"
echo "You should see the following message 'This is routine ATEST'"
$MUMPS -direct
setenv gtm_principal_editing "NOEDITING"
echo "#### Testing for gtm_principal_editing : $gtm_principal_editing ####"
$MUMPS -run noedit^ttyread
echo ""
echo "Input the following:"
echo "so<Ctrl-U>do atest^ttyra<left>e<ctrl-E>d"
echo "The display should be 'do atest^ttyread'. Press <ret>"
echo "You should see the following message 'This is routine ATEST'"
$MUMPS -direct
setenv gtm_principal_editing "INSERT:EDITING"
echo "Testing for multiple line read"
echo "Input the following for the next read"
echo "12345678901234567<ctrl-A>a<ctrl-E>b<4 lefts><del>b<ctrl-B><ins>c<ret>"
if($HOSTOS == "SunOS") then
	set STTY='/usr/ucb/stty'
else
	set STTY='/bin/stty'
endif
set oldttysize= ( `$STTY size` )
$STTY columns 15
$MUMPS -run stty^ttyread
$STTY columns $oldttysize[2]
echo "Testing for CTRAP/TERMINATOR"
$MUMPS -run ctrp^ttyread

echo ""
echo ""
echo "Testing nowrap with length=0"
set oldttysize= ( `$STTY size` )
$STTY columns 100
$MUMPS -run nowrap^ttyread
$STTY columns $oldttysize[2]
unsetenv STTY

setenv gtm_principal_editing "INSERT:EDITING"
echo "#### Testing for gtm_principal_editing : $gtm_principal_editing ####"
echo "*** Now checking GDE ***"
echo "**************************************"
echo "Input the following in the GDE> prompt"
echo "show eg<ctrl-B><ctrl-B>r<ctrl-E>ion<ctrl-A><5 right>-<ret>"
echo "**************************************"
echo "Check if the right command is executed.i.e Does it show the regions list?"
echo "**************************************"
echo "Now input the following"
echo " we<ctrl-U>quit<ret>"
echo "**************************************"
echo ""
echo ""
$GDE

setenv gtm_principal_editing "NOINSERT:EDITING"
echo "#### Testing for gtm_principal_editing : $gtm_principal_editing ####"
echo "**************************************"
echo "Input the following in the GDE> prompt"
echo "show -teg<ctrl-B><left><left>r<ctrl-E>ion<ret>"
echo "**************************************"
echo "Check if the right command is executed.i.e Does it show the regions list?"
echo "**************************************"
echo "Now input the following"
echo " we<ctrl-U>wuit<ctrl-A>q<ret>"
echo "**************************************"
echo ""
echo ""
$GDE

setenv gtm_principal_editing "NOEDITING"
echo "#### Testing for gtm_principal_editing : $gtm_principal_editing ####"
echo "**************************************"
echo "Input the following in the GDE> prompt"
echo "quit<ctrl-A><ctrl-E><ctrl-B>"
echo "None of the above EDITING Characters should work. Press <ret>"
echo "GDE-E-ILLCHAR Should be displayed. Now input quit<ret>"
echo "**************************************"
$GDE

echo "*** Now Testing [NO]ESCAPE ***"
unsetenv gtm_principal_editing
echo ""
$MUMPS -run escape^ttyread
echo ""
echo " *** END OF TEST *** "
echo "There should not have been any FAILs"

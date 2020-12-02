#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ( $?HOSTOS == "0" )          setenv HOSTOS `uname -s`        # operating system

unalias ps cp rm ls diff rsh ssh rcp scp awk
setenv grep \grep
setenv df "df -kP"
setenv netstat "/bin/netstat -an"
setenv ssh "ssh -x"
setenv rsh "$ssh"
setenv rcp "scp -q"
setenv atrm atrm
setenv ps "ps -ef"
setenv psuser "ps -fu $USER"
setenv uptime "uptime"
setenv dbx "dbx"
setenv LC_COLLATE C
setenv pflags echo
setenv truss "/usr/bin/truss -E -d"
setenv tst_cmpsilent 'cmp -s'
setenv gcore "/usr/bin/gcore"
if ($?gtm_test_com_individual) then
	setenv tail	"$gtm_test_com_individual/mtailhead.csh -t"
	setenv head	"$gtm_test_com_individual/mtailhead.csh -h"
	setenv rm 	"$gtm_test_com_individual/rm_script.csh"
	setenv kill9	"$gtm_test_com_individual/kill9.csh"
	setenv mkdir	"$gtm_test_com_individual/mkdir.csh"
	setenv kill	"$gtm_test_com_individual/safe_kill.csh"
	setenv cprcp	"$gtm_test_com_individual/cp_remote_file.csh"
else
	setenv tail tail
	setenv head head
	setenv mkdir mkdir
endif
$uptime >&! /dev/null
if ($status) setenv uptime "echo COULD NOT GET LOAD INFORMATION BY uptime"
setenv gtmtest1 "gtmtest1"

setenv tst_tcsh "tcsh -f"
setenv tst_awk "env LC_ALL=C gawk"
setenv tst_od "od"
setenv tst_ls "ls"
setenv lsof  /usr/local/bin/lsof
setenv tst_ld_yottadb "-lyottadb"
setenv convert_to_gtm_chset :
setenv strings "strings"
switch ($HOSTOS)
case "AIX":
   setenv truss "/usr/bin/truss -d"
   setenv ps "eval ps -ef |& cat"
   setenv psuser "eval ps -fu $USER |& cat"
   setenv rsh_to_vms "rsh"
   setenv rcp_to_vms "rcp"
   setenv ci_ldpath "-L "
   breaksw
case "HP-UX":
   setenv truss "/usr/local/bin/tusc -T %x:%X"
   setenv atrm "at -r"
   setenv ps "ps -xef"
   setenv psuser "ps -xfu $USER"
   setenv dbx /opt/langtools/bin/gdb
   setenv rsh_to_vms "remsh"
   setenv rcp_to_vms "rcp"
   setenv ci_ldpath "+b "
   breaksw
case "OSF1":
   setenv truss "/usr/local/bin/truss"
   setenv ps "eval ps -ef |& cat"
   setenv psuser "eval ps -fu $USER |& cat"
   setenv netstat "/usr/sbin/netstat -an"
   setenv rsh_to_vms "rsh"
   setenv rcp_to_vms "rcp"
   setenv dbx "/usr/bin/dbx"
   setenv ci_ldpath "-Wl,-rpath,"
   breaksw
case "SunOS":
   setenv grep /usr/xpg4/bin/grep   # has -f option
   alias grep '/usr/xpg4/bin/grep'   # has -f option
   setenv dbx /opt/SUNWspro/bin/dbx
   setenv SUNW_NO_UPDATE_NOTIFY "TRUE" # Disable Update Notification from dbx in test system
   setenv rsh_to_vms "rsh"
   setenv rcp_to_vms "rcp"
   setenv pflags '/usr/bin/pflags'
   setenv truss '/usr/bin/truss -d'
   setenv ci_ldpath "-R "
   breaksw
case "Linux":
   setenv grep "grep -a"		# Process a binary file as if it were text
   setenv truss "/usr/bin/strace -tT"
   # Normally we could just test $gtm_test_linux_distrib but set_gtm_machtype.csh hasn't been run yet so do this
   # check manually.
   set distrib = `grep -w ID /etc/os-release | cut -d= -f2 | cut -d'"' -f2`
   if ("alpine" == "$distrib") then
	setenv ps "ps -ef"
   else
	setenv ps "ps -efww"		# Double "w" to mean infinite width in ps output display
   endif
   setenv psuser "ps -fwwu $USER"
   setenv rsh_to_vms "rsh"
   setenv rcp_to_vms "rcp"
   setenv ci_ldpath "-Wl,-rpath,"
   setenv gtt_cc_shl_options 	"-c -fPIC"
   if (-e /usr/local/bin/gdb) then
	   setenv dbx /usr/local/bin/gdb
   else
	   setenv dbx /usr/bin/gdb
   endif
   breaksw
case "OS/390":
   # ssh  tends to babble, so turn off extra output with -q
   setenv ssh "$ssh -q"
   setenv rsh "$ssh"
   setenv netstat onetstat
   # xlc wants to use the side deck file for libyottadb.dll on the link line
   setenv tst_ld_yottadb "$gtm_exe/yottadb_symbols.x"
   setenv gtmtest1 "GTMTST1"
   setenv rsh_to_vms "rsh"
   setenv rcp_to_vms "rcp"
   setenv tst_od "od -T"
   setenv tst_ls "ls -T"
   setenv lsof /usr/local/bin/zlsof
   # For grep to work on binary data on z/OS, we need to iconv to appropriate encoding before
   # doing a grep. Also, since grep on binary might show up garbage, usage of $strings should
   # be redirected(stdout/stderr) to appropriate output file.
   setenv strings "iconv -f ISO8859-1 -t IBM-1047"
   if ($?gtm_test_com_individual) then
	   setenv convert_to_gtm_chset "$gtm_test_com_individual/convert_to_gtm_chset.csh"
   endif
   # mtailhead.csh generates SIGPIPE outputs so use system head/tail
   setenv tail tail
   setenv head head
   # if tst_disable_dbx does not exist setup two session debugging variables
   if !($?tst_disable_dbx) then
	   setenv _CEE_RUNOPTS "${_CEE_RUNOPTS} test(all)"
	   setenv _BPX_PTRACE_ATTACH "YES"
	   setenv _CEE_DEBUG_FILENAME31 /bin/dbx31vdbg
	   setenv _CEE_DEBUG_FILENAME64 /bin/dbx64vdbg
   endif
   # Note that bpxtrace -c passes the command to sh -c and output is EBCDIC
   # so this may not work as expected.  -f format -x outputs just one line
   # per system call though the format is different than other platforms.
   # There may be problems doing more than one bpxtrace per user at the same time.
   setenv truss "/bin/bpxtrace -f format -x -c"
   # Hijacking ci_ldpath to add -L$gtm_obj for -lascii (nee -lgtmzos)
   # -blibpath does not work, leaving it in for now
   setenv ci_ldpath "-L$gtm_obj -blibpath"
   breaksw
case "CYGWIN*":
   setenv atrm "echo ""CYGWIN-E-NOAT no at on Cygwin""; exit 1"
   setenv dbx "gdb -nw"
   setenv rsh_to_vms "rsh"
   setenv rcp_to_vms "rcp"
   setenv ci_ldpath "-Wl,-rpath,"
   breaksw
default:
   echo "(Error) Unsupported Operating System while choosing platform tools"
   exit 1
endsw

# For the below env variables, if the corresponding tool is not present on a server,
# the command will just echo the tool name. This prevents test failures
setenv fuser /usr/sbin/fuser
if !(-e $fuser) setenv fuser /sbin/fuser
if !(-e $fuser) setenv fuser /usr/bin/fuser
if !(-e $fuser) setenv fuser /bin/fuser
if !(-e $fuser) then
	echo "TEST-E-FUSER, cannot find fuser. Tests relying on \$fuser will fail"
	setenv fuser echo
endif

if !(-e $lsof) setenv lsof  /usr/sbin/lsof
if !(-e $lsof) setenv lsof  /usr/bin/lsof
if !(-e $lsof) then
	echo "TEST-E-LSOF, cannot find lsof. Tests relying on \$lsof will fail"
	setenv lsof echo
endif

setenv tst_gzip /usr/local/bin/gzip
if !(-e $tst_gzip) setenv tst_gzip /bin/gzip
if !(-e $tst_gzip) setenv tst_gzip /usr/contrib/bin/gzip
if !(-e $tst_gzip) then
	echo "TEST-E-GZIP, Cannot find gzip. The test output will not be zipped."
	setenv tst_gzip echo
endif
setenv tst_gunzip /usr/local/bin/gunzip
if !(-e $tst_gunzip) setenv tst_gunzip /bin/gunzip
if !(-e $tst_gunzip) setenv tst_gunzip /usr/contrib/bin/gunzip
if !(-e $tst_gunzip) then
	echo "TEST-E-GUNZIP, Cannot find gunzip.Tests relying on $tst_gunzip will fail"
	setenv tst_gunzip echo
endif
if ("OS/390" == $HOSTOS) then
	setenv tst_gzip_quiet "/bin/compress -f"
else
	setenv tst_gzip_quiet "$tst_gzip -q"
endif

setenv pstack /usr/bin/pstack
if !(-e $pstack) setenv pstack /usr/ccs/bin/pstack
if !(-e $pstack) setenv pstack echo
if !(-e $gcore) setenv gcore echo

if ($?gtt_cc_shl_options && $?gt_cc_options_common) then
	# gt_cc_options_common env var defined in environment. Add that to all C compiles done by test system.
	# This is needed particularly on the ARM to ensure -march=v7-a (defined in $gt_cc_options_common) is included
	# in the C compiler flags which in turn undefs BIGENDIAN in mdefsp.h. Not doing so could result in Linux on ARM
	# being treated incorrectly as a bigendian platform.
	# But gt_cc_options_common contains Wmissing-prototypes which can cause lots of warnings in the test. Instead
	# of fixing all the test C programs to define prototypes we just disable that benign warning for the test system.
	# Similarly, -Wreturn-type can cause lots of benign warnings (and in turn test failures). Disable that too.
	setenv gtt_cc_shl_options "$gtt_cc_shl_options $gt_cc_options_common -Wno-missing-prototypes -Wno-return-type"
	# Set link flags just like compile flags (needed since we use LTO in a few tests (errors/test_fao, v62001/hash
	# and v62002/zwritesvn subtests) that link directly against libmumps.a instead of libyottadb.so.
	# For that remove the "-c" option (since we are no longer compiling, but linking) and use the rest.
	setenv gtt_ld_shl_options "`echo $gtt_cc_shl_options | sed 's/ -c//g;s/^-c //g'`"
endif

which gpg2 >&! /dev/null
if ($status) then
	setenv gpg "gpg --no-permission-warning"
else
	setenv gpg "gpg2 --no-permission-warning"
endif


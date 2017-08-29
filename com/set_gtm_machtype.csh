#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ( $MACHTYPE == "unknown" ) then
 set MACHTYPE = `uname -m`
endif
set shorthost = $HOST:ar

set os_name = `echo $HOSTOS | sed 's/\///g' | tr '[A-Z]' '[a-z]'`
if ($os_name =~ "cygwin*") then
	set os_name = "cygwin"
endif
set gtm_platform=`echo 'write $piece($zversion," ",4),! halt' | $gtm_exe/mumps -direct | tail -n 1` #BYPASS_OK $tail

# Handle 32 bit testing on a 64 bit x86 machine
set mach_type = `echo $MACHTYPE | sed 's/\///g' | tr '[A-Z]' '[a-z]' | sed 's/i.86/ix86/g'`
if ($mach_type =~ "x86_64*") set mach_type = "x86_64"
if ( ($gtm_platform != "x86_64") && ($mach_type == "x86_64") ) then
        set mach_type = "ix86"
endif
set os_machtype = "$os_name"_"$mach_type"
# get the OS version, needed for aix and sometimes hpux
set os_ver = `uname -v | awk '{print $1}'`#BYPASSOK awk

setenv gtm_test_osname		$os_name
setenv gtm_test_osver		$os_ver
setenv gtm_test_machtype	$mach_type
setenv gtm_test_os_machtype	`echo "HOST_$os_machtype" | tr '[a-z]' '[A-Z]'`

# z/OS is not able to have dynamic file extensions while running in MM access mode
# If multiple processes are accessing the same mapped file, and one process needs to extend/remap the file,
# all the other processes must also unmap the file.
#
# This same comment is in the source code in sr_port/mdef.h.  If this comment is updated, also update the other.
#
# Set a variable for platforms that do support file extensions in MM access method
if ("s390" != $gtm_test_machtype) then
	setenv gtm_platform_mmfile_ext 1
else
	setenv gtm_platform_mmfile_ext 0
endif

# Set the variable for 32 bit architectures. Adding more 32bit platforms isn't likely
if ($gtm_test_machtype == "ix86") then
	setenv gtm_platform_size 32
else
	setenv gtm_platform_size 64
endif

# Some machines do not have V4 versions
set nonomatch = 1 ;set test_found_v4_vers = ($gtm_root/V4*) ; unset nonomatch
if ("$gtm_root/V4*" == "$test_found_v4_vers") then
	setenv gtm_platform_no_V4 1		# This variable is used by cheking its existence ($?gtm_platform_no_V4)
endif

# Some machines do not have dual_site versions
set nonomatch = 1 ; set test_found_ds_ver = ($gtm_root/V5[01]*) ; unset nonomatch
if (($?gtm_platform_no_V4) && ("$gtm_root/V5[01]*" == "$test_found_ds_ver")) then
	setenv gtm_platform_no_ds_ver 1
else
	setenv gtm_platform_no_ds_ver 0
endif

# New platforms have no prior versions (or the current version is the only prior version)
set nonomatch = 1 ; set test_found_priorvers = ($gtm_root/V[456]*) ; unset nonomatch
if ("$gtm_root/V[456]*" == "$test_found_priorvers" || "$test_found_priorvers" == "$gtm_ver") then
	setenv gtm_test_nopriorgtmver 1		# New platform with no prior versions
	# Set gtm_platform_no_compress_ver to 1  for platforms that don't have versions without compression support.
	# Note : The variable name doesnt quite match its usage.
	setenv gtm_platform_no_compress_ver 1
else
	setenv gtm_platform_no_compress_ver 0
endif

# Need a test to figure the condition below at runtime. Until then, do it based on platform
# zOS R10(tcsh 6.14) and (we assume) Cygwin don't support unicode 5.0 and hence 4 byte unicode characters.
# The following tests/subtests are disabled due to this
# 1) unic2m2c2m subtest of call_ins 2) unicode_tests.csh section of xcall 3) dse subtest of unicode 4) basic_io_encoding subtest of unicode_io
if (("s390" == $gtm_test_machtype) || ("cygwin" == "$gtm_test_osname")) set no_4byte_utf8=1
if ($?no_4byte_utf8) then
	setenv gtm_platform_no_4byte_utf8 1
else
	setenv gtm_platform_no_4byte_utf8 0
endif

# Set endianness
setenv gtm_endian `echo -n A | od -h | awk '{if ($2 == "0041") {print "LITTLE_ENDIAN"} else if ($2 == "4100") {print "BIG_ENDIAN"} else {print "ENDIAN_UNDETERMINED"}; exit}'` #BYPASSOK awk
# Set the linux distribution name if the current server is a linux server
# gtm_test_linux_distrib will be set to one of ubuntu, redhatenterpriseserver, debian, centos, fedora, suselinux, arch
# on a linux server. It will be set to "" on other servers
if (-X lsb_release) then
	setenv gtm_test_linux_distrib `lsb_release -is | sed 's/ //g' | tr '[A-Z]' '[a-z]'`
else if (-f /etc/os-release) then
	setenv gtm_test_linux_distrib `awk -F= '$1 == "ID" {print $2}' /etc/os-release`
else
	setenv gtm_test_linux_distrib ""
endif
##### HOST SPECIFIC FUNNIES ####

#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Include path to dynamically load ICU and ZLIB libraries
# /emul/ia32-linux/usr/lib is included to let 32-bit binaries run in UTF8 mode in 64-bit linux boxes

source $gtm_tst/com/is_64bitgtm.csh
set is_current_ver64=$cur_platform_size

# please keep in sync with sr_unix/gtm_test_install.csh and sr_unix/set_library_path.csh
# /opt/openssl/current is a symbolic link on hpux to the latest build - update the symbolic link if a new build is done
if ("$is_current_ver64" == "1") then
        set library_path=(/opt/gcrypt/lib64 /usr/local/lib64 /usr/lib64 /usr/lib/x86_64-linux-gnu /usr/local/lib /usr/lib /usr/local/ssl/lib /opt/openssl/current/lib)
else
        set library_path=(/opt/gcrypt/lib32 /usr/lib32 /emul/ia32-linux/usr/lib /usr/lib/i386-linux-gnu /usr/local/lib /usr/lib)
endif

set new_library_path=()
foreach d ($library_path)
	if (-d $d) set new_library_path=($new_library_path $d)
end
set library_path=($new_library_path)
unset new_library_path

# On lespaul and strato (and whatever future AIX server we have), the encryption plugin for versions between V53004 and
# V62001 depend on libgpgme.so. If that directory is found, append that to libpath. Please read
# /usr/local/lib/legacyaixgpgme/README.txt for information regarding the misconfiguration.
if ( -d /usr/local/lib/legacyaixgpgme ) then
	set library_path=(${library_path} /usr/local/lib/legacyaixgpgme)
endif

set lib_temp=()
if ($HOST:ar !~ {sphere}) set lib_temp=($library_path)
if ($?LIBPATH) then
        set -f lib_temp=(${LIBPATH:as/:/ /} $lib_temp)
endif

set ld_temp=()
if ($HOST:ar !~ {sphere}) set ld_temp=($library_path)
if ($?LD_LIBRARY_PATH) then
        set -f ld_temp=(${LD_LIBRARY_PATH:as/:/ /} $lib_temp)
endif

set lib_temp="$lib_temp"
set ld_temp="$ld_temp"

setenv LIBPATH          "${lib_temp:as/ /:/}"
setenv LD_LIBRARY_PATH  "${ld_temp:as/ /:/}"

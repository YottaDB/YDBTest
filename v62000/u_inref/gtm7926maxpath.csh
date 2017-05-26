#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# This test case provides regression support that validates the maximum path
# allowed for $gtm_dist. Previous code checks incorrectly calculated the length
# of $gtm_dist, a slash and the executables name throughout the code prior to
# using a target. This could lead to situations where libgtmshr.so,
# gtmsecshrdir or a plugin (encryption) library are inaccessible due to path
# limitations.
#
# Going forward, GT.M reserves 50 bytes* for internal paths beyond $gtm_dist to
# support the current maximum path of 47 characters for the encyrption plugin
# library "utf8/plugin/libgtmcrypt_openssl_BLOWFISHCFB.so". Note
# gtmcrypt_entry.c does a realpath() of the encyrption libraries using a buffer
# of size GTM_PATH_MAX prior to dlopen()ing them.
#
# An interesting tidbit about gtmsecshr startup. $gtm_dist/gtmsecshr CDs to
# $gtm_dist/gtmsecshrdir and then executes ./gtmsecshr from that directory.
# Because it does not use the absolute path, it avoids hitting maximum path
# length errors. So as long as $gtm_dist/gtmsecshrdir fits in GTM_PATH_MAX, we
# can always execute $gtm_dist/gtmsecshrdir/gtmsecshr.
#
# * The build scripts need to watch the path lengths after the builds complete
#

# RedHat 6, carmen and titan, excluded (see below) from encryption testing
set hostn = $HOST:r:r:r
if (("carmen" == "$hostn") || ("titan" == "$hostn")) then
	setenv test_encryption "NON_ENCRYPT"
endif
# This test switches DIST directories. Do not rely on the default encryption
# key setup as it depends on $gtm_dist, which will be different between
# dbcreate and the following tests. Instead use gtm_obfuscation_key to have it
# the same across all DISTs.
if ("ENCRYPT" == "$test_encryption") then
        echo "randomstring" >&! gtm_obfuscation_key.txt
        setenv gtm_obfuscation_key $PWD/gtm_obfuscation_key.txt
        setenv encrypt_env_rerun
        source $gtm_tst/com/set_encrypt_env.csh $tst_general_dir $gtm_dist $tst_src >>! $tst_general_dir/set_encrypt_env.log
        if ("TRUE" == "$gtm_test_tls" ) source $gtm_tst/com/set_tls_env.csh
        unsetenv encrypt_env_rerun
endif

$gtm_tst/com/dbcreate.csh mumps  1

$gtm_dist/mumps -run gtm7926maxpath
source testpaths.csh >&! testpaths.out

$gtm_com/IGS $gtm_dist/gtmsecshr "UNHIDE"
cp -r $gtm_dist/* ${max_dist}/ >&! copy_into_max.out
$gtm_com/IGS $gtm_dist/gtmsecshr "CHOWN"
cp -r ${max_dist}/* ${over_dist}/ >&! copy_into_overmax_can_have_errors.outx

set save_gtm_dist = $gtm_dist

# This is the maximum path length allowed so it will pass
env gtm_dist=${max_dist} ${max_dist}/mupip set -region DEFAULT -journal=enable,on,nobefore >&! max_dist.out || cat max_dist.out

# This is over the maximum path length allowed so it will fail
env gtm_dist=${over_dist} ${over_dist}/mupip set -region DEFAULT -journal=off

## ABUSE ##
ln ${max_dist}/mumps ${max_dist}/MUMPS >>& link.log || (cd $max_dist ; ln mumps MUMPS)
env gtm_dist=${max_dist} ${max_dist}/MUMPS -direct >& MUMPS.outx << EOF
write \$zversion
EOF
$grep -q IMAGENAME MUMPS.outx
if ($status) then
	echo "TEST-F-FAIL expected IMAGENAME error not found"
	cat MUMPS.outx
endif

# Clean up
foreach dir (${max_dist} ${over_dist} ${max_dist}/utf8 ${over_dist}/utf8)
	if ( -e $dir ) $gtm_com/IGS $dir/gtmsecshr "RMDIR"
end
# Fix-up permissions. Necessary when copying a version owned by another user
find a* -type d -exec chmod ug+rwx {} +
find a* -type f -exec chmod ug+rw {} +
rm -rf a* && rm -rf max_dist over_dist

$gtm_tst/com/dbcheck.csh

# RedHat 6 Woes
# This test fails to open the encryption libraries when using the safe
# $PWD/max_dist directory. The failure signature follows:
#
#	%GTM-E-CRYPTDLNOOPEN, Could not load encryption library while opening encrypted file /testarea1/e1020505/V990/tst_V990_dbg_19_140815_161712/v62000_0/gtm7926maxpath/mumps.dat. Failed to find symbolic link for /testarea1/e1020505/V990/tst_V990_dbg_19_140815_161712/v62000_0/gtm7926maxpath/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb/cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc/dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
#	%GTM-I-MUSTANDALONE, Could not get exclusive access to /testarea1/e1020505/V990/tst_V990_dbg_19_140815_161712/v62000_0/gtm7926maxpath/mumps.dat
#	%GTM-E-MUNOFINISH, MUPIP unable to finish all requested actions
#
# In debugging the failure, the realpath() on line 165 fails with errno set to
# 36, ENAMETOOLONG (File name too long).
#
# 165             if (NULL == realpath(libpath, resolved_libpath))
#
# In the debugger, realpath() manages to fillin in resolved_libpath with the
# correct value. However since the MAN lists the result as undefined when
# returning NULL and setting errno it cannot be used.
#
# The deugging session below shows that the ultimate path length, 4085, is 11 bytes under MAX_PATH, 4096.
#
# (gdb) b /usr/library/V990/src/gtmcrypt_entry.c:164
# Breakpoint 1 at 0x820d5dd: file /usr/library/V990/src/gtmcrypt_entry.c, line 164.
# (gdb) run set -region DEFAULT -journal=enable,on,nobefore
# Starting program: /testarea1/e1020505/V990/tst_V990_dbg_19_140815_161712/v62000_0/gtm7926maxpath/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb/cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc/dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee/ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff/gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg/hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh/iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii/jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj/kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk/llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll/mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm/nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn/oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo/pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp/mupip set -region DEFAULT -journal=enable,on,nobefore
#
# Breakpoint 1, gtmcrypt_entry () at /usr/library/V990/src/gtmcrypt_entry.c:164
# 164             SNPRINTF(libpath, GTM_PATH_MAX, "%s/%s", plugin_dir_path, libname_ptr);
# (gdb) n
# 165             if (NULL == realpath(libpath, resolved_libpath))
# (gdb) p (char *)realpath(libpath, resolved_libpath)
# $12 = 0x0
# (gdb) p resolved_libpath
# $13 = "/testarea1/e1020505/V990/tst_V990_dbg_19_140815_161712/v62000_0/gtm7926maxpath/", 'a' <repeats 254 times>, "/", 'b' <repeats 254 times>, "/", 'c' <repeats 254 times>, "/", 'd' <repeats 254 times>, "/", 'e' <repeats 254 times>, "/", 'f' <repeats 254 times>, "/", 'g' <repeats 254 times>, "/", 'h' <repeats 254 times>, "/", 'i' <repeats 254 times>, "/", 'j' <repeats 254 times>, "/", 'k' <repeats 254 times>, "/"...
# (gdb) p strlen(gtm_dist)
# $14 = 4046
# (gdb) p strlen(libpath)
# $15 = 4068
# (gdb) p strlen(resolved_libpath)
# $16 = 4085
# (gdb) p libpath+4046
# $18 = 0xbfff7049 "/plugin/libgtmcrypt.so"
# (gdb) p (char *)realpath(libpath, 0)
# $22 = 0x0
# (gdb) p (char *)realpath(plugin_dir_path, 0)
# $23 = 0x874f6d8 "/testarea1/e1020505/V990/tst_V990_dbg_19_140815_161712/v62000_0/gtm7926maxpath/", 'a' <repeats 121 times>...
# (gdb) p plugin_dir_path+4046
# $28 = 0xbfff600c "/plugin"
# (gdb) p libpath+4046
# $29 = 0xbfff7049 "/plugin/libgtmcrypt.so"
# (gdb) p resolved_libpath+4046
# $30 = 0xbfff500b "/plugin/libgtmcrypt_gcrypt_AES256CFB.so"
# (gdb) p (char *)realpath(resolved_libpath, 0)
# $31 = 0x0
# (gdb) p errno
# $32 = 36



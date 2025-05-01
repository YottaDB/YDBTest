#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This tests $ZYHASH and ydb_mmrhash_128 to make sure that they return equivalent and consistent hashes across runs

# ^%RANDSTR uses $ZEXTRACT extensively and ydb390.m invokes it with a string length of 1Mib.
# This means we will end up with a lot of duplicated data if "ydb_stp_gcol_nosort" env var is 1
# (as "stp_gcol_nosort()" will not notice the data duplication). And that will cause the process to
# take TOO LONG to run and need a lot of memory. So force stp_gcol() to always sort.
setenv ydb_stp_gcol_nosort 0

$ydb_dist/yottadb -run ydb390

# Setup call-in table

setenv ydb_ci `pwd`/tab.ci
cat >> tab.ci << xx
str:		ydb_string_t *	str^str()
slt:		ydb_int_t *	slt^slt()
toolong:	ydb_string_t *	toolong^toolong()
hash:		ydb_string_t *	hash^hash(I:ydb_string_t *,I:ydb_int_t *)
xx
cat >> str.m << xxx
str
	set len=\$RANDOM(1048576)+1
	set x=\$\$^%RANDSTR(len,.chset)
	quit x
xxx
cat >> slt.m << xxxx
slt
	set salt=\$RANDOM(2147483647)
	quit salt
xxxx
cat >> toolong.m << xxxxx
toolong
	set x=\$\$^%RANDSTR(1048577)
	quit x
xxxxx
cat >> hash.m << xxxxxx
hash(str,slt)
	set x=\$ZYHASH(str,slt)
	quit x
xxxxxx

# Compile and link ydb390.c.
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/ydb390.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output ydb390 $gt_ld_options_common ydb390.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map

# Invoke the executable.
ydb390

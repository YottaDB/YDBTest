#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo '######################################################################'
echo '# Test that ydb_buffer_t can be used to pass string values in call-ins'
echo '######################################################################'

# SETUP of callin files
setenv GTMCI `pwd`/tab.ci
cat >> $GTMCI << xx
retBuff: ydb_buffer_t *retBuff^retBuff(I:ydb_buffer_t *, O:ydb_buffer_t *, IO:ydb_buffer_t *)
xx
cat >> retBuff.m << xxx
retBuff(ibuf,obuf,iobuf)
	set obuf=ibuf_ibuf
	set iobuf=iobuf_iobuf
	quit ibuf_obuf_iobuf
xxx

# Test that [ydb_buffer_t **] is not accepted as return type in call-in
set citab = `pwd`/err1.ci
cat >> $citab << xx
err: ydb_buffer_t **err^retBuff()
xx

# Test that [ydb_buffer_t] is not accepted as return type in call-in
set citab = `pwd`/err2.ci
cat >> $citab << xx
err: ydb_buffer_t err^retBuff()
xx

# Test that [ydb_buffer_t **] is not accepted as O parameter type in call-in
set citab = `pwd`/err3.ci
cat >> $citab << xx
err: void err^retBuff(O:ydb_buffer_t **)
xx

# Test that [ydb_buffer_t] is not accepted as O parameter type in call-in
set citab = `pwd`/err4.ci
cat >> $citab << xx
err: void err^retBuff(O:ydb_buffer_t)
xx

# Test that [ydb_buffer_t **] is not accepted as I parameter type in call-in
set citab = `pwd`/err5.ci
cat >> $citab << xx
err: void err^retBuff(I:ydb_buffer_t **)
xx

# Test that [ydb_buffer_t] is not accepted as I parameter type in call-in
set citab = `pwd`/err6.ci
cat >> $citab << xx
err: void err^retBuff(I:ydb_buffer_t)
xx

# Test that [ydb_buffer_t **] is not accepted as IO parameter type in call-in
set citab = `pwd`/err7.ci
cat >> $citab << xx
err: void err^retBuff(IO:ydb_buffer_t **)
xx

# Test that [ydb_buffer_t] is not accepted as IO parameter type in call-in
set citab = `pwd`/err8.ci
cat >> $citab << xx
err: void err^retBuff(IO:ydb_buffer_t)
xx

# SETUP of the driver C files
set file="ydb565"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map

# Run driver C
`pwd`/$file


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

unsetenv GTMCI

echo ''
echo '#######################################################################'
echo '# Test that ydb_buffer_t can be used to pass string values in call-outs'
echo '#######################################################################'

set file = "ydb565callouts"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_shl_linker ${gt_ld_option_output}lib${file}${gt_ld_shl_suffix} $gt_ld_shl_options $file.o $gt_ld_syslibs

setenv GTMXC $file.tab
setenv GTMXC_package1 $file.tab

echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
preallocO:	void xc_preallocO(O:ydb_buffer_t *)
preallocIO:	void xc_preallocIO(IO:ydb_buffer_t *)
test1:	ydb_buffer_t *xc_test1()
test2:	void xc_test2(O:ydb_buffer_t *[1])
test3:	void xc_test3(IO:ydb_buffer_t *)
test4:	void xc_test4(O:ydb_buffer_t *[10])
test5:	void xc_test5(IO:ydb_buffer_t *)
test6:	ydb_buffer_t *xc_test6()
test7:	ydb_buffer_t *xc_test7()
test8:	void xc_test8(O:ydb_buffer_t *[1])
test9:	void xc_test9(IO:ydb_buffer_t *)
test10:	ydb_buffer_t *xc_test10()
test11:	void xc_test11(O:ydb_buffer_t *[1])
test12:	void xc_test12(IO:ydb_buffer_t *)
test13:	void xc_test13(O:ydb_buffer_t *[10])
test14:	ydb_buffer_t *xc_test14(I:ydb_buffer_t *, IO:ydb_buffer_t *,O:ydb_buffer_t *[10])
xx

rm -f ydb565.o	# remove .o file created in from ydb565.c before we create .o file of same name from ydb565.m
$ydb_dist/yottadb -run ydb565

echo "# Test that [ydb_buffer_t **] is not accepted as return type in call-in"
setenv GTMXC_err1 err1.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err1
cat >> $GTMXC_err1 << xx
err1:	ydb_buffer_t **xc_err1()
xx

$ydb_dist/yottadb -run %XCMD 'write $&err1.err1()'

echo "# Test that [ydb_buffer_t] is not accepted as return type in call-in"
setenv GTMXC_err2 err2.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err2
cat >> $GTMXC_err2 << xx
err2:	ydb_buffer_t xc_err2()
xx

$ydb_dist/yottadb -run %XCMD 'write $&err2.err2()'

echo "# Test that [ydb_buffer_t **] is not accepted as O parameter type in call-in"
setenv GTMXC_err3 err3.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err3
cat >> $GTMXC_err3 << xx
err3:	void xc_err3(O:ydb_buffer_t **)
xx

$ydb_dist/yottadb -run %XCMD 'write $&err3.err3()'

echo "# Test that [ydb_buffer_t] is not accepted as O parameter type in call-in"
setenv GTMXC_err4 err4.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err4
cat >> $GTMXC_err4 << xx
err4:	void xc_err4(O:ydb_buffer_t )
xx

$ydb_dist/yottadb -run %XCMD 'write $&err4.err4()'

echo "# Test that [ydb_buffer_t **] is not accepted as I parameter type in call-in"
setenv GTMXC_err5 err5.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err5
cat >> $GTMXC_err5 << xx
err5:	void xc_err5(I:ydb_buffer_t **)
xx

$ydb_dist/yottadb -run %XCMD 'write $&err5.err5()'

echo "# Test that [ydb_buffer_t] is not accepted as I parameter type in call-in"
setenv GTMXC_err6 err6.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err6
cat >> $GTMXC_err6 << xx
err6:	void xc_err6(I:ydb_buffer_t)
xx

$ydb_dist/yottadb -run %XCMD 'write $&err6.err6()'

echo "# Test that [ydb_buffer_t **] is not accepted as IO parameter type in call-in"
setenv GTMXC_err7 err7.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err7
cat >> $GTMXC_err7 << xx
err7:	void xc_err7(IO:ydb_buffer_t **)
xx

$ydb_dist/yottadb -run %XCMD 'write $&err7.err7()'

echo "# Test that [ydb_buffer_t] is not accepted as IO parameter type in call-in"
setenv GTMXC_err8 err8.tab
echo "`pwd`/lib${file}${gt_ld_shl_suffix}" > $GTMXC_err8
cat >> $GTMXC_err8 << xx
err8:	void xc_err8(IO:ydb_buffer_t)
xx

$ydb_dist/yottadb -run %XCMD 'write $&err8.err8()'


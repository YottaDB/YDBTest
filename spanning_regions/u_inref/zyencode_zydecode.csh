#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtmgbldir mumps.gld
$GDE << GDE_EOF >&! gde_mumps_gld.out
add -name a(01:11) -reg=REG1
add -name a(11:21) -reg=REG2
add -name a(21:31) -reg=REG3
add -region REG1 -dyn=REG1
change -region REG1 -std
add -segment REG1 -file=REG1
add -region REG2 -dyn=REG2
change -region REG2 -std
add -segment REG2 -file=REG2
add -region REG3 -dyn=REG3
change -region REG3 -std
add -segment REG3 -file=REG3
change -region DEFAULT -std
exit
GDE_EOF

$MUPIP create	>&! mupip_create_mumps_gld.out
$MUPIP set -journal="enable,on,before" -reg "*"	>&! set_jnl_mumps_gld.out

setenv gtmgbldir x.gld
$GDE << GDE_EOF >&! gde_x_gld.out
add -name a(01:11) -reg=REG5
add -name a(11:21) -reg=REG6
add -name a(21:31) -reg=REG4
add -region REG4 -dyn=REG4
change -region REG4 -std
add -segment REG4 -file=REG4
add -region REG5 -dyn=REG5
change -region REG5 -std
add -segment REG5 -file=REG5
add -region REG6 -dyn=REG6
change -region REG6 -std
add -segment REG6 -file=REG6
change -region DEFAULT -std
change -segment DEFAULT -file=x.dat
exit
GDE_EOF

$MUPIP create	>&! mupip_create_mumps_gld.out
$MUPIP set -journal="enable,on,before" -reg "*"	>&! set_jnl_x_gld.out

setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run zycode

$gtm_tst/com/backup_dbjnl.csh case1 "*.dat *.gld *.mjl *_gld.out" mv

###
cat << ref_eof
#### Test zyencode/zydecode with spanning regions where
####     - there is an intersection in the src and target gvn
####     - AND source and target globals have a range of regions that intersect
ref_eof

cat >> 3reg.cmd << cat_eof
change -segment DEFAULT -file=mumps.dat
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a
add -name b -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=b
add -name c -region=creg
add -region creg -dyn=cseg
add -segment cseg -file=c
change -region areg -std
change -region breg -std
change -region creg -std
change -region DEFAULT -std
cat_eof

# CASE 1
echo "# case 1 setup : zyencode/zydecode source : mumps.gld : ^a    spans areg and breg"
echo "#                zyencode/zydecode target : other.gld : ^a(1) spans breg and creg"
setenv gtmgbldir mumps.gld
$GDE @3reg.cmd >&! gde_mumps_gld.out
$GDE << GDE_EOF >>&! gde_mumps.gld.out
add -name a(2,1) -reg=areg
add -name a(2,2) -reg=breg
GDE_EOF

$MUPIP create	>&! mupip_create_mumps_gld.out

setenv gtmgbldir other.gld
$GDE @3reg.cmd >&! gde_other_gld.out
$GDE << GDE_EOF >>&! gde_other.gld.out
add -name a(1,2,0)  -reg=breg
add -name a(1,2,10) -reg=creg
GDE_EOF

setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run %XCMD 'set ^a(2,1)=1,^a(2,2)=2'
$gtm_exe/mumps -run %XCMD 'set ^a=1'

echo "# zyencode ^|other.gld|a(1)=^a should issue YDB-E-ZYENCODEDESC as breg intersects src(^a) and dest(^a(1))"
$GTM << GTM_EOF
	zyencode ^|"other.gld"|a(1)=^a
GTM_EOF
echo "# zydecode ^|other.gld|a(1)=^a should issue YDB-E-ZYDECODEDESC as breg intersects src(^a) and dest(^a(1))"
$GTM << GTM_EOF
	zydecode ^|"other.gld"|a(1)=^a
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh "zyencode_zydecode_desc_case1" "*.gld *.dat *_gld.out" mv


# CASE 2
echo "# case 2 setup : zyencode/zydecode source : mumps.gld : ^a    spans areg    and breg"
echo "#                zyencode/zydecode target : other.gld : ^a(1) spans default and creg"

setenv gtmgbldir mumps.gld
$GDE @3reg.cmd >&! gde_mumps_gld.out
$GDE << GDE_EOF >>&! gde_mumps.gld.out
add -name a(2,1) -reg=areg
add -name a(2,2) -reg=breg
GDE_EOF

$MUPIP create	>&! mupip_create_mumps_gld.out

setenv gtmgbldir other.gld
$GDE @3reg.cmd >&! gde_other_gld.out
$GDE << GDE_EOF >>&! gde_other.gld.out
add -name a(1)      -reg=DEFAULT
add -name a(1,2,10) -reg=creg
GDE_EOF

setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run %XCMD 'set ^a(2,1)=1,^a(2,2)=2'

echo "# zyencode ^|other.gld|a(1)=^a should work as src(^a) spans areg and breg ; but dest(^a(1)) spans default and creg"
$GTM << GTM_EOF
	zyencode ^|"other.gld"|a(1)=^a
GTM_EOF
$gtm_exe/mumps -run %XCMD 'set $zgbldir="other.gld" zwrite ^a'

$gtm_exe/mumps -run %XCMD 'set ^a(2,1)=1,^a(2,2)=2'

echo "# zydecode ^a=^|other.gld|a(1) should work as src(^a) spans areg and breg ; but dest(^a(1)) spans default and creg"
$GTM << GTM_EOF
	zydecode ^a=^|other.gld|a(1)
GTM_EOF
$gtm_exe/mumps -run %XCMD 'set $zgbldir="other.gld" zwrite ^a'

$gtm_tst/com/backup_dbjnl.csh "zyencode_zydecode_desc_case2" "*.gld *.dat *_gld.out" mv


# CASE 3
echo "# case 3 setup : zyencode/zydecode source : mumps.gld : ^a spans areg and breg"
echo "#                zyencode/zydecode target : other.gld : ^a(1) maps to breg and does not span regions"

setenv gtmgbldir mumps.gld
$GDE @3reg.cmd >&! gde_mumps_gld.out
$GDE << GDE_EOF >>&! gde_mumps.gld.out
add -name a(2,1) -reg=areg
add -name a(2,2) -reg=breg
GDE_EOF

$MUPIP create	>&! mupip_create_mumps_gld.out

setenv gtmgbldir other.gld
$GDE @3reg.cmd >&! gde_other_gld.out

setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run %XCMD 'set ^a(2,1)=1,^a(2,2)=2'

echo "# zyencode ^|other.gld|a(1)=^a should issue YDB-E-ZYENCODEDESC as breg intersects src(^a) and dest(^a(1))"
$GTM << GTM_EOF
	zyencode ^|"other.gld"|a(1)=^a
GTM_EOF
echo "# zydecode ^|other.gld|a(1)=^a should issue YDB-E-ZYDECODEDESC as breg intersects src(^a) and dest(^a(1))"
$GTM << GTM_EOF
	zydecode ^|"other.gld"|a(1)=^a
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh "zyencode_decode_desc_case3" "*.gld *.dat *_gld.out" mv


# CASE 4
echo "# case 4 setup : zyencode_decode source : other.gld : ^a(2) maps to areg - no spanning"
echo "#                zyencode_decode target : mumps.gld : ^a spans areg and breg"

setenv gtmgbldir mumps.gld
$GDE @3reg.cmd >&! gde_mumps_gld.out
$GDE << GDE_EOF >>&! gde_mumps.gld.out
add -name a(2,1) -reg=areg
add -name a(2,2) -reg=breg
GDE_EOF

$MUPIP create	>&! mupip_create_mumps_gld.out

setenv gtmgbldir other.gld
$GDE @3reg.cmd >&! gde_other_gld.out

setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run %XCMD 'set ^a(2,1)=1,^a(2,2)=2'

echo "# zyencode ^|mumps.gld|a(1)=^a should issue YDB-E-ENCODEDESC as areg intersects src(^a(2)) and dest(^a)"
$GTM << GTM_EOF
	set \$zgbldir="other.gld"
	zyencode ^|"mumps.gld"|a=^a(2)
GTM_EOF
echo "# zydecode ^|mumps.gld|a(1)=^a should issue YDB-E-DECODEDESC as areg intersects src(^a(2)) and dest(^a)"
$GTM << GTM_EOF
	set \$zgbldir="other.gld"
	zydecode ^|"mumps.gld"|a=^a(2)
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh "zyencode_decode_desc_case4" "*.gld *.dat *_gld.out" mv

# CASE 5
echo "# case 5 setup : zyencode_decode source : other.gld : ^a(2) maps to areg - no spanning"
echo "#                zyencode_decode target : mumps.gld : ^a spans areg breg creg and default"

setenv gtmgbldir mumps.gld
$GDE @3reg.cmd >&! gde_mumps_gld.out
$GDE << GDE_EOF >>&! gde_mumps.gld.out
add -name a(2) -reg=creg
add -name a(2,1) -reg=DEFAULT
add -name a(2,2) -reg=breg
GDE_EOF
$MUPIP create	>&! mupip_create_mumps_gld.out

setenv gtmgbldir other.gld
$GDE @3reg.cmd >&! gde_other_gld.out

setenv gtmgbldir other.gld
$gtm_exe/mumps -run %XCMD 'set ^a(2,1)=1,^a(2,2)=2'

echo "# zyencode ^|mumps.gld|a=^a(2) should issue YDB-E-ZYENCODEDESC as areg intersects src(^a(2)) and target(^a)"
$GTM << GTM_EOF
	zyencode ^|"mumps.gld"|a=^a(2)
GTM_EOF
echo "# zydecode ^|mumps.gld|a=^a(2) should issue YDB-E-ZYDECODEDESC as areg intersects src(^a(2)) and target(^a)"
$GTM << GTM_EOF
	zydecode ^|"mumps.gld"|a=^a(2)
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh "zyencode_decode_desc_case5" "*.gld *.dat *_gld.out" mv

# CASE 6
echo "# case 6 setup : zyencode/decode source : other.gld : ^a maps to areg - no spanning"
echo "#                zyencode/decode target : mumps.gld : ^a(2) spans areg breg creg and default"

setenv gtmgbldir mumps.gld
$GDE @3reg.cmd >&! gde_mumps_gld.out
$GDE << GDE_EOF >>&! gde_mumps.gld.out
add -name a(2) -reg=creg
add -name a(2,1) -reg=DEFAULT
add -name a(2,2) -reg=breg
add -name a(2,3) -reg=areg
GDE_EOF
$MUPIP create	>&! mupip_create_mumps_gld.out

setenv gtmgbldir other.gld
$GDE @3reg.cmd >&! gde_other_gld.out

setenv gtmgbldir other.gld
$gtm_exe/mumps -run %XCMD 'set ^a(2,1)=1,^a(2,2)=2'

echo "# zyencode ^|mumps.gld|a(1)=^a should issue YDB-E-ZYENCODEDESC as areg intersects src(^a(2)) and dest(^a(2))"
$GTM << GTM_EOF
	zyencode ^|"mumps.gld"|a=^a(2)
GTM_EOF
echo "# zydecode ^|mumps.gld|a(1)=^a should issue YDB-E-ZYDECODEDESC as areg intersects src(^a(2)) and dest(^a(2))"
$GTM << GTM_EOF
	zydecode ^|"mumps.gld"|a=^a(2)
GTM_EOF

$gtm_tst/com/backup_dbjnl.csh "zyencode_decode_desc_case6" "*.gld *.dat *_gld.out" mv


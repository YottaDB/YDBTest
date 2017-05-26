#!/usr/local/bin/tcsh -f
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
# invoke bad label tranfers in various ways
setenv gtm_etrap 'write $zstatus'
cp $gtm_tst/$tst/inref/gtm7003*.m .
$gtm_dist/mumps gtm7003*.m
$gtm_dist/mumps -run gotolab^gtm7003
$gtm_dist/mumps -run zgotolab^gtm7003
$gtm_dist/mumps -run dolab^gtm7003
$gtm_dist/mumps -run exfunlab^gtm7003
$gtm_dist/mumps -run extexfunlab^gtm7003
$gtm_dist/mumps -run autozllab^gtm7003
$gtm_dist/mumps -dir << GTM_EOF
set cma=\$char(44),dlr=\$char(36),nl=\$char(33)
set @(dlr_"etrap=""set "_dlr_"ecode="""""""" write:"_dlr_"zstatus'[expect "_dlr_"zstatus"_" zgoto -1 """)
do breaklab^gtm7003
set expect="LABELMISSING"
write "zgoto"
do zgotolab
set expect="LABELNOTFND"
do breaklab^gtm7003
write "goto"
do gotolab
set expect="LABELUNKNOWN"
do breaklab^gtm7003
write "do"
do dolab
do breaklab^gtm7003
write "extrinsic"
do exfunlab
set:((\$zversion'["IA64")&((\$zversion'["x86"))!(\$zversion["x86_64")) expect="LABELMISSING"
do breaklab^gtm7003
write "external extrinsic"
do extexfunlab
set expect="LABELMISSING"
do breaklab^gtm7003
write "auto zlink"
do autozllab
set expect="LABELMISSING"
do breaklab^gtm7003
write "zgoto"
xecute "do zgotolab"
set expect="LABELNOTFND"
do breaklab^gtm7003
write "goto"
xecute "do gotolab"
set expect="LABELUNKNOWN"
do breaklab^gtm7003
write "do"
xecute "do dolab"
do breaklab^gtm7003
write "extrinsic"
xecute "do exfunlab"
set:((\$zversion'["IA64")&((\$zversion'["x86"))!(\$zversion["x86_64")) expect="LABELMISSING"
do breaklab^gtm7003
write "external extrinsic"
xecute "do extexfunlab"
set expect="LABELMISSING"
do breaklab^gtm7003
write "auto zlink"
xecute "do autozllab"
write !,"PASS from gtm7003"
GTM_EOF

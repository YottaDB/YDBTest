#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$GTM << xyz
w "d ^comment",!  d ^comment
w "d ^dzro",!  d ^dzro
w "d ^gdparm",!  d ^gdparm
w "d ^gext",!  d ^gext
w "d ^indrex",!  d ^indrex
w "d ^laberr",!  d ^laberr
w "d ^lzlab",!  d ^lzlab
w "d ^mulsign",!  d ^mulsign
w "d ^newgo",!  d ^newgo
w "d ^parmenew",!  d ^parmenew
w "d ^qextnoa",!  d ^qextnoa
w "d ^sym1",!  d ^sym1
w "d ^symtab1",!  d ^symtab1
w "d ^xnew",!  d ^xnew
w "d ^zbform",!  d ^zbform
w "d ^zgext",!  d ^zgext
w "d ^zlextgo1",!  d ^zlextgo1
h
xyz
$gtm_tst/com/dbcreate.csh "mumps"
$GTM << zyx
w "d ^dnnull",!  d ^dnnull
h
zyx
sleep 10
$gtm_tst/com/dbcheck.csh -extract

if ("$LFE" != "E")  exit
#
# Below is for only extended tests
#
echo "Test of Naked Variables causing Number of subscripts to exceed limit"
echo "======"
echo "Test 1"
echo "======"
$gtm_tst/com/dbcreate.csh "mumps" 1 255 500
$GTM << aaa
;view "gdscert":1
SET i=1
SET ^val("AA","BB",1)="DATA"
FOR j=2:1:100 SET ^(j,j+1)=j+2
aaa
$gtm_tst/com/dbcheck.csh -extract
#
echo "======"
echo "Test 2"
echo "======"
$gtm_tst/com/dbcreate.csh "mumps" 1 255 500
$GTM << aaa
view "gdscert":1
SET ^val("A",2)="DATA"
SET ^(0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9)="DATA2"
SET ^(0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9)="DATA3"
SET ^(0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9)="DATA4"
aaa
$gtm_tst/com/dbcheck.csh -extract
#
echo "======"
echo "Test 3"
echo "======"
$gtm_tst/com/dbcreate.csh "mumps" 1 255 500
$GTM << aaa
SET i=1
SET ^val("AA","BB",1)="DATA"
FOR j=2:1:100 SET ^(j,j+1)=j+2
aaa
$gtm_tst/com/dbcheck.csh -extract
#
echo "======"
echo "Test 4"
echo "======"
$gtm_tst/com/dbcreate.csh "mumps" 1 255 500
$GTM << aaa
SET ^val("A",2)="DATA"
SET ^(0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9)="DATA2"
SET ^(0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9)="DATA3"
SET ^(0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9)="DATA4"
aaa
$gtm_tst/com/dbcheck.csh -extract
echo "======"
echo "Test 5"
echo "======"
$gtm_tst/com/dbcreate.csh "mumps" 1 255 500
$GTM << aaa
SET i=1
SET ^val(99,100,1)="DATA"
FOR j=2:1:100 SET ^(i,j)=j
aaa
$gtm_tst/com/dbcheck.csh -extract

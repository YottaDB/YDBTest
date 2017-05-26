#!/usr/local/bin/tcsh -f
#
#########################################
# D9J02002719_1.csh  test for mupip integ #
#########################################
#
# Testing that mupip integ -full -fast doesn't read all data blocks, as a mupip integ -full will do.
#

echo MUPIP D9J02002719_1

setenv gtmgbldir "integ.gld"
$gtm_tst/com/dbcreate.csh integ -record_size=522 -block_size=538 -allocation=2000

# Fill with lots of data
$GTM << EOF
set bigdata="ab"
for i=1:1:8 set bigdata=bigdata_bigdata

for i=1:1:100 set (^a(i),^b(i),^c(i),^d(i),^e(i),^f(i),^g(i),^h(i),^x(i),^y(i),^z(i))=bigdata
EOF

$truss $MUPIP integ -full -fast -reg '*' >& truss_integ_fast.txt
$truss $MUPIP integ -full -reg '*' >& truss_integ.txt

set nb_read_fast = "`$grep -c pread truss_integ_fast.txt`"
set nb_read = "`$grep -c pread truss_integ.txt`"

if ($nb_read_fast != 0) then
	@ ratio = ( $nb_read / $nb_read_fast)
else
	set ratio = 0
endif
set target_ratio = 10

# For HOST_HP-UX_PA_RISC : Until tusc is installed on lester, let the test pass.
if (($ratio < $target_ratio) && (("HOST_HP-UX_PA_RISC" != "$gtm_test_os_machtype") || ("`which tusc`" != "tusc: Command not found."))) then
	echo "Fast integ used $nb_read_fast read() system calls, which is too much compared to non-fast integ ($nb_read calls)."
else
	echo "Fast integ uses at least $target_ratio times less read() system calls than non-fast integ."
endif
$gtm_tst/com/dbcheck.csh

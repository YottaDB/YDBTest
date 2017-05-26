#!/usr/local/bin/tcsh -f
#
# MUPIP REPLIC SHOWBACKLOG should show backlog even if source server is down
#

if (! $?test_replic) then
	echo "This subtest needs to be run with -replic. Exiting..."
	exit -1
endif

$MULTISITE_REPLIC_PREPARE 3
# Create database, start replication servers
$gtm_tst/com/dbcreate.csh mumps

$MSR START INST1 INST2
$MSR START INST1 INST3

# On the primary do 10 updates 
$GTM << EOF
for i=1:1:10 set ^a(i)=i
EOF

$MSR SYNC INST1 INST3
$MSR STOPSRC INST1 INST3

# On the primary do 5 more updates 
$GTM << EOF
for i=1:1:5 set ^b(i)=i
EOF

$MSR SYNC INST1 INST2

# At this time 
# 	a) INST1->INST2 link is healthy
# 	b) INST1->INST3 link is not since the source server was shutdown
# Now test how checkhealth and showbacklog operate for a variety of situations.
#
echo ""
echo "# Test CHECKHEALTH behavior if VALID instance name is specified & source server is alive"
$MSR RUN INST1 '$MUPIP replicate -source -checkhealth -instsecondary=INSTANCE2; echo $status' >&! checkhealth_inst2.out
cat checkhealth_inst2.out

echo ""
echo "# Test SHOWBACKLOG behavior if VALID instance name is specified & source server is alive"
$MSR RUN INST1 '$MUPIP replic -source -showbacklog -instsecondary=INSTANCE2; echo $status' >&! showbacklog_inst2.out
cat showbacklog_inst2.out

echo ""
echo "# Test CHECKHEALTH behavior if VALID instance name is specified & source server is dead"
echo "# We expect a SRCSRVNOTEXIST error in this case"
$MSR RUN INST1 '$MUPIP replicate -source -checkhealth -instsecondary=INSTANCE3; echo $status' >&! checkhealth_inst3.outx
cat checkhealth_inst3.outx

echo ""
echo "# Test SHOWBACKLOG behavior if VALID instance name is specified & source server is dead"
echo "# We expect a SRCSRVNOTEXIST warning message in this case"
$MSR RUN INST1 '$MUPIP replicate -source -showbacklog -instsecondary=INSTANCE3; echo $status' >&! showbacklog_inst3.outx
cat showbacklog_inst3.outx

echo ""
echo "# Test CHECKHEALTH behavior if INVALID instance name is specified"
echo "# We expect a REPLINSTSECNONE error in this case"
$MSR RUN INST1 '$MUPIP replicate -source -checkhealth -instsecondary=ZYXWVU; echo $status' >&! checkhealth_instINVALID.outx
cat checkhealth_instINVALID.outx

echo ""
echo "# Test SHOWBACKLOG behavior if INVALID instance name is specified"
echo "# We expect a REPLINSTSECNONE error in this case"
$MSR RUN INST1 '$MUPIP replicate -source -showbacklog -instsecondary=UVWXYZ; echo $status' >&! showbacklog_instINVALID.outx
cat showbacklog_instINVALID.outx

echo ""
echo "# Test that INVALID instance names did not use up a slot in the instance file/journal pool"
echo "# A search for those instance names should not yield any output in the instance file"
$MSR RUN INST1 '$MUPIP replic -editinstance -show mumps.repl >& editinst.out'
if ($status) then
	echo "TEST-E-ERROR : Error from mupip replic -editinstance -show mumps.repl. See editinst.out"
endif
$grep -E "ZYXWVU|UVWXYZ" editinst.out

echo ""
echo "# Test CHECKHEALTH behavior if NO instance name is specified"
echo "# It should operate only on INST2 and not on INST3 (source server is dead)"
$MSR RUN INST1 '$MUPIP replic -source -checkhealth; echo $status' >&! checkhealth_instALL.out
cat checkhealth_instALL.out

echo ""
echo "# Test showbacklog behavior if NO instance name is specified"
echo "# It should operate only on INST2 and not on INST3 (source server is dead)"
$MSR RUN INST1 '$MUPIP replic -source -showbacklog; echo $status' >&! showbacklog_instALL.out
cat showbacklog_instALL.out

$MSR STARTSRC INST1 INST3
$MSR SYNC INST1 INST3

$gtm_tst/com/dbcheck.csh -extr

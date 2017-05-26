#!/usr/local/bin/tcsh -f

# Verify that compile works when the directory where it runs has been NFS mounted.
# Assume that our $HOME directories are NFS mounted. It might not be true in some cases (non-gg servers or some PCs that has local user and local $HOME)
# The test does not verify if $HOME is NFS mounted and goes ahead as there is no point in failing in that case

set curdir = $PWD
set rundir = "c002924_$$"

cd $HOME
if (-d $rundir) rm -rf $rundir
mkdir $rundir
cd $rundir
echo "# Compiling in the directory : GTM_TEST_DEBUGINFO $PWD"

$GTM << GTM_EOF
set success=0
d ^c002924
if success=1 zsystem "cd $HOME ; rm -rf $rundir"
if success=0 write "TEST-E-FAIL : ^c002924 failed. Will move $rundir to test output directory"
halt
GTM_EOF

cd $curdir
if (-d $HOME/$rundir) then
	mv $HOME/$rundir .
endif

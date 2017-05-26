#!/usr/local/bin/tcsh -f
#
# trigreference - test that \$reference is maintained by triggers in spite of .gld file change

$gtm_tst/com/dbcreate.csh mumps 2

cp mumps.gld mumps2.gld

# ------------------------------------------------------
# --- Create trig.txt file (input for mupip trigger)
cat << TRIG  > trigreference.trg
+^a(acn=:) -commands=SET -xecute="Do ^trigref1"
TRIG

# ------------------------------------------------------
# --- Create trigref1.m trigger program that modifies $ZTVAL
cat << TFILE  > trigref1.m
	set ^|"mumps2.gld"|b(acn)=2
	write "\$reference=",\$reference,!
	quit
TFILE

# ------------------------------------------------------
# --- Create trigreference.m application program
cat << TRIGREF  > trigreference.m
	write "\$reference=",\$reference,!
	set ^a(1)=1
	write "\$reference=",\$reference,!
	quit
TRIGREF

if ($?test_replic == 1) then
    cp trigref1.m $SEC_SIDE
    cp mumps2.gld $SEC_SIDE
endif

$load trigreference.trg "" -noprompt

# ------------------------------------------------------
# --- Run application program
echo "--------------------------------------------------------------------------------"
echo '  Test that $reference is maintained by triggers inspite of .gld file changes',!
echo "--------------------------------------------------------------------------------"

$gtm_exe/mumps -run trigreference

$gtm_tst/com/dbcheck.csh -extract

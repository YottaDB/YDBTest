#!/usr/local/bin/tcsh -f

###############################################################################################
# This test is a slightly more complex modification of sn_jnl2. This is the outline of the    #
# test: Set minimum autoswitch limit and maximum block size. Make sure that the maximum       #
# record size is at least the maximum block size. Turn journaling on and start saving globals #
# that barely fit within a block each. Ensure that the switch does not occur prematurely.     #
# Update the autoswitch limit. Verify that a new journal file is created. Start writing more  #
# globals. At this point it should take a certain number of globals to cause a journal file   #
# switch. Verify that the switch happened; recover and validate the values.                   #
###############################################################################################
echo "Verify that autoswitch occurs when expected when either spanning or non-spanning globals are used."
echo

# Get the current limits
source $gtm_tst/com/set_limits.csh

# Set the journal buffer size near the highest-possible value and try to set the autoswitch limit to be
# slightly less. The key span padding is required for the larger updates that we do after the switch,
# because every record will span, causing the 4-byte expansion of record keys; and 2 is required because
# key indices go into two digits.
@ key_size = $MIN_KEY_SIZE + $KEY_SPAN_PADDING + 2
@ record_size = $MAX_RECORD_SIZE
@ block_size = $MAX_BLOCK_SIZE
@ autoswitch = $MIN_AUTOSWITCH_LIMIT

# Create the database with the above configuration
$gtm_tst/com/dbcreate.csh mumps 1 $key_size $record_size $block_size >&! db_create.outx
$gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP

echo

# Do not play with alignment
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`

# Enforce the selected journaling mode
$gtm_dist/mupip set $tst_jnl_str,auto=$autoswitch -reg "*" >&! mupip_set.out

# Record journaling mode in settings.csh
echo 'setenv tst_jnl_str "'$tst_jnl_str'"' >>&! settings.csh

# Create a backup of the empty database
cp mumps.dat mumps.dat.bak

# Set the size of a global to almost fully occupy one block
@ global_size_before_switch = $MAX_BLOCK_SIZE - 50
@ writes_before_switch = (($autoswitch * 512) / ($global_size_before_switch + $key_size)) / 2
# Global of the following size will cause an autoswitch on each (or every other, if nobefore mode is chosen)
# write because of highly pessimistic estimations for journal file extensions
@ global_size_after_switch = $record_size - 10
@ num_of_extra_jnl_files = 3
# Configure the number of writes that should cause each consecutive journal switch after the first two, and how
# many writes we will do to generate extra $num_of_extra_jnl_files files.
if (! $gtm_test_jnl_nobefore) then
	@ writes_per_jnl_after_switch = 1
	# The following is because with before-image journaling the first two updates actually do
	# fit in one journal buffer
	@ extra_writes_in_first_jnl_after_switch = 1
else
	@ writes_per_jnl_after_switch = 3
	@ extra_writes_in_first_jnl_after_switch = 0
endif
@ writes_after_switch = ($writes_per_jnl_after_switch * $num_of_extra_jnl_files) + 1 + $extra_writes_in_first_jnl_after_switch

# Write a number of globals that is almost enough for a switch; make sure that no switch occurred
$gtm_dist/mumps -direct << EOF >&! mumps.out
set l=$writes_before_switch
write "we are going to do $writes_before_switch writes before the switch",!
for i=1:1:l  set @("^i"_i)=\$justify("abcdefghijklmnopqrstuvwxyz",$global_size_before_switch)
EOF

# Verify that we still have one journal
@ num_of_jnl_files = `ls -l *.mjl* | wc -l`
echo "We now have $num_of_jnl_files journal files"
echo

# Reenable journaling again to trigger the journal file change
$gtm_dist/mupip set $tst_jnl_str,auto=$autoswitch -reg "*" >&! mupip_set2.out

# Verify that we now have two journals
@ num_of_jnl_files = `ls -l *.mjl* | wc -l`
echo "We now have $num_of_jnl_files journal files"
echo

# Write as many globals as we expect to cause a switch; count the number of journal files for
# the last ten (at most) updates
$gtm_dist/mumps -direct << EOF >&! mumps2.out
set k=$writes_before_switch
set l=k+$writes_after_switch
write "we are going to do $writes_after_switch writes after the switch",!
for i=(k+1):1:l  set @("^i"_i)=\$justify("abcdefghijklmnopqrstuvwxyz",$global_size_after_switch)  zsystem "ls -l *.mjl* | wc -l"
EOF

# Verify that the switch occurred as expected
@ num_of_any = 1 * $writes_per_jnl_after_switch
@ num_of_twos = $num_of_any + $extra_writes_in_first_jnl_after_switch
@ num_of_fives = 1
@ twos  = `$grep 2 mumps2.out | $grep -v "writes" | wc -l`
@ threes = `$grep 3 mumps2.out | $grep -v "writes" | wc -l`
@ fours = `$grep 4 mumps2.out | $grep -v "writes" | wc -l`
@ fives = `$grep 5 mumps2.out | $grep -v "writes" | wc -l`
@ total = $twos + $threes + $fours + $fives
if ($twos != $num_of_twos || $threes != $num_of_any || $fours != $num_of_any || $fives != $num_of_fives || $total != $writes_after_switch) then
	echo "TEST-E-FAIL The journal autoswitch did not occur within $writes_after_switch writes."
	exit 1
else
	@ num_of_jnl_files = `ls -l *.mjl* | wc -l`
	echo "We now have $num_of_jnl_files journal files"
	echo
endif

# Create a MUPIP extract of the current database
$gtm_dist/mupip extract -format=zwr mumps-a.zwr >&! extract-a.out

# Overwrite the current database with the empty backup
cp -r mumps.dat.bak mumps.dat

# Repopulate the globals from the journal file
$gtm_dist/mupip journal -recover -forward -verbose mumps.mjl >&! mupip_jnl_rec.out

# Create a MUPIP extract of the recovered database
$gtm_dist/mupip extract -format=zwr mumps-b.zwr >&! extract-b.out

# Compare the extracts by first matching the line counts and then diffing
@ lines_a = `wc -l mumps-a.zwr | $tst_awk '{print $1}'`
@ lines_b = `wc -l mumps-b.zwr | $tst_awk '{print $1}'`

if ($lines_a != $lines_b) then
	echo "TEST-E-FAIL Extracts mumps-a.zwr and mumps-b.zwr are different."
else
	@ lines = $lines_a - 2
	$tail -$lines mumps-a.zwr > mumps-a-headless.zwr
	$tail -$lines mumps-b.zwr > mumps-b-headless.zwr
	diff mumps-{a,b}-headless.zwr >&! diff_extracts.outx
	if ($status) then
		echo "TEST-E-FAIL Extracts mumps-a-headress.zwr and mumps-b-headless.zwr are different."
	else
		\rm mumps-{a,b}-headless.zwr
	endif
endif

# Finally verify all the values programmatically
$gtm_dist/mumps -direct << EOF >&! mumps3.out
set k=$writes_before_switch
set l=k+$writes_after_switch
for i=1:1:k  if @("^i"_i)'=\$justify("abcdefghijklmnopqrstuvwxyz",$global_size_before_switch) write "TEST-E-FAIL ^i"_i_" has a different value",!
for i=(k+1):1:l  if @("^i"_i)'=\$justify("abcdefghijklmnopqrstuvwxyz",$global_size_after_switch) write "TEST-E-FAIL ^i"_i_" has a different value",!
EOF

# Check if the database is OK
$gtm_tst/com/dbcheck.csh

#!/usr/local/bin/tcsh -f

###############################################################################################
# Create two instances with identical, but random, configurations, and ensure that            #
# replication works properly by writing about 10 MB of updates to the database.               #
###############################################################################################
echo "Verify that replication works for a randomized configuration of two instances."
echo

# Try 10 random configurations of replication instances
@ i = 0

while ($i < 10)
	@ i = $i + 1
	if ($i != 1) $echoline
	$gtm_tst/$tst/u_inref/rand_repl.csh $i
end

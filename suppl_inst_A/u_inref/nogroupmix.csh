#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#  1 1) Test that MULTIPLE supplementary LMS clusters can coexist. It is just that they cannot talk to each other.
#  2
#  3         Non-supplementary        Supplementary       Non-supplementary
#  4           LMS cluster 1          LMS cluster 1         LMS cluster 2
#  5           --------------        --------------        --------------
#  6           |     A      | -----> |     P      | <----- |     X      |
#  7           |   /   \    |        |   /   \    |        |   /   \    |
#  8           |  B     C   | ---    |  Q     R   |    --- |  Y     Z   |
#  9           --------------   |    --------------    |   --------------
# 10                            |                      |
# 11                            |     Supplementary    |
# 12                            |     LMS cluster 2    |
# 13                            |    --------------    |
# 14                            ---> |     M      | <---
# 15                                 |   /   \    |
# 16                                 |  N     O   |
# 17                                 --------------
# 18
# 19         In the above scenario,
# 20                 * P and M are rootprimary supplementary instances. Q, R, N, O are propagating primary supplementaries.
# 21                 * A, X are rootprimary non-supplementary instances. B, C, Y, Z are propagating primary non-supplementaries.
# 22
# 23         Subtest scenarios using the above configuration
# 24         -------------------------------------------------
# 25         a) P receives streams from say A and X and M receives streams from A and X. i.e. A->P, A->M, X->P, X->M
# 26         b) C->P, C->M, X->P, X->M
# 27         c) B->P, C->M, X->P, Y->M
# 28
# 29         All of the above should work fine.
# 30
# 31         d) Test switchovers (normal shutdown) & failovers (crash shutdown of primary) in ALL of these LMS clusters.
# 32                 The LMS clusters should still be able to talk to each other afterwards.

# 2) Test that history record information is transmitted from the originating instance across multiple non-supplementary
# and supplementary instances.
#
#	For example, in the below configuration, let C replicate to P.
#
#	 Non-supplementary        Supplementary
#           LMS cluster 1          LMS cluster 1
#           --------------        --------------
#           |     A      |   ---> |     P      |
#           |   /   \    |  /     |   /   \    |
#           |  B     C   |--      |  Q     R   |
#           --------------        --------------
#
#	Do controlled switchovers of BOTH clusters. For example
#
#        --------------          --------------         --------------
#        |     A      |          |     B      |         |     C      |
#        |   /   \    | becomes  |   /   \    | becomes |   /   \    |
#        |  B     C   |          |  A     C   |         |  A     B   |
#        --------------          --------------         --------------
#
#	Similarly
#
#        --------------          --------------         --------------
#        |     P      |          |     Q      |         |     R      |
#        |   /   \    | becomes  |   /   \    | becomes |   /   \    |
#        |  Q     R   |          |  P     R   |         |  P     Q   |
#        --------------          --------------         --------------
#
#	With each cluster state, do 10 updates or so on the root primary of the non-supplementary cluster.
#	Wait until all of this gets replicated to ALL other instances in the above configuration.
#	And then do a switchover of either one or both clusters and then repeat the 10 updates with the
#	new root primary of the non-supplementary cluster. And then wait for it to be replicated and then
#	do the switchover. Keep doing this until all instances have been the root primary at least once.
#
#	The key thing is to note that in all the switchovers, the secondary will always be brought up WITHOUT
#	doing a fetchresync rollback. This is because with the above steps, the primary and secondary should
#	always be in sync thereby not requiring a rollback.
#
#	At the end of the test, ensure that db state is identical in ALL the instances.
#	Dump the instance files of all instances too to see that all of the instances in each cluster have identical
#	history information. Additionally, the non-supplementary stream history records in any supplementary instance
#	should be identical to the history records in any non-supplementary instance.

#2a) Do test (2) but WITH FETCHRESYNC ROLLBACK whenever a secondary is brought up after each switchover. And verify that
#	the rollback does NOT roll back ANY seqno from the instance.

#setenv gtm_test_dbfill "SLOWFILL"

$MULTISITE_REPLIC_PREPARE 6 6

$gtm_tst/com/dbcreate.csh mumps 5 125-425 900-1050 512,768,1024 4096 1024 4096

setenv needupdatersync 1
# Non-supplementary LMS group 1 (A,B,C)
$MSR START INST1 INST2 RP
$MSR START INST1 INST3 RP
# Non-supplementary LMS group 2 (X,Y,Z)
$MSR START INST4 INST5 RP
$MSR START INST4 INST6 RP
# Supplementary LMS group 1 (P,Q,R)
$MSR START INST7 INST8 RP
$MSR START INST7 INST9 RP
$MSR START INST1 INST7 RP
#$MSR START INST4 INST7 RP
# Supplementary LMS group 2 (M,N,O)
$MSR START INST10 INST11 RP
$MSR START INST10 INST12 RP
$MSR START INST1 INST10 RP
#$MSR START INST4 INST10 RP
unsetenv needupdatersync

# Groups definition
set primaries = (1 4 7 10)
set sec1      = (2 5 8 11)
set sec2      = (3 6 9 12)
set issupp    = (0 0 1 1)
# Laurent : Supplementary instances currently only support receiving from one non-supplementary group, so we can not
# have two non-supplementary group replicating.  Uncomment this (and the $MSR START above) when that feature is
# supported.
#set nosupp_groups = (1 2)
set nosupp_groups = (1)
set supp_groups = (3 4)
set lms_groups = "$nosupp_groups $supp_groups"

# Start updates on all primaries
foreach grp ($lms_groups)
	$MSR RUN INST$primaries[$grp] "setenv gtm_test_jobid $grp ; $gtm_tst/com/imptp.csh" >>&! imptp$grp.out
end
#sleep 5

# Cycle primary on each group, one group at at time
echo "** 1st part, cycle all groups"
foreach grp ($lms_groups)
	foreach notused_nbsec (1 2)
		# Stop updates
		$MSR RUN INST$primaries[$grp] "setenv gtm_test_jobid $grp ; $gtm_tst/com/endtp.csh" >>&! endtp$grp.out
		# Stop replication (50% chances of a normal shutdown (sync + stop), 50% chances of a crash shutdown (kill -9 + stop))
		# Laurent : Rollback on supplementary instance not yet supported, so always do clean shutdown for now.
		#set rand = `$gtm_exe/mumps -run rand 2`
		set rand = 1
		if (0 == $issupp[$grp]) then
			foreach supp ($supp_groups)
				if (1 == $rand) then
					$MSR SYNC INST$primaries[$grp] INST$primaries[$supp] >>&! sync_$primaries[$grp]_$primaries[$supp].log
				else
					$MSR RUN SRC=INST$primaries[$grp] RCV=INST$primaries[$supp] '$MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__ | $grep PID | cut -d " " -f 2 >& checkhealth.tmp; '$kill9 ' `cat checkhealth.tmp`' >>&! kill_$primaries[$grp]_$primaries[$supp].log
				endif
				$MSR STOP INST$primaries[$grp] INST$primaries[$supp]
			end
		else
			foreach nosupp ($nosupp_groups)
				$MSR STOPSRC INST$primaries[$nosupp] INST$primaries[$grp]
				$MSR STOPRCV INST$primaries[$nosupp] INST$primaries[$grp]
			end
		endif
		if (1 == $rand) then
			$MSR SYNC INST$primaries[$grp] INST$sec1[$grp] >>&! sync_$primaries[$grp]_$sec1[$grp].log
		else
			$MSR RUN SRC=INST$primaries[$grp] RCV=INST$sec1[$grp] '$MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__ | $grep PID | cut -d " " -f 2 >& checkhealth.tmp; '$kill9 '`cat checkhealth.tmp`' >>&! sync_$primaries[$grp]_$sec1[$grp].log
		endif
		$MSR STOP INST$primaries[$grp] INST$sec1[$grp]
		if (1 == $rand) then
			$MSR SYNC INST$primaries[$grp] INST$sec2[$grp] >>&! sync_$primaries[$grp]_$sec2[$grp].log
		else
			$MSR RUN SRC=INST$primaries[$grp] RCV=INST$sec2[$grp] '$MUPIP replic -source -checkhealth -instsecondary=__RCV_INSTNAME__ | $grep PID | cut -d " " -f 2 >& checkhealth.tmp; '$kill9 '`cat checkhealth.tmp`' >>&! sync_$primaries[$grp]_$sec2[$grp].log
		endif
		$MSR STOP INST$primaries[$grp] INST$sec2[$grp]
		# Restart with second as primary
		$MSR START INST$sec1[$grp] INST$primaries[$grp] RP
		$MSR START INST$sec1[$grp] INST$sec2[$grp] RP
		if (0 == $issupp[$grp]) then
			foreach supp ($supp_groups)
				$MSR START INST$sec1[$grp] INST$primaries[$supp] RP
			end
		else
			foreach nosupp ($nosupp_groups)
				$MSR START INST$primaries[$nosupp] INST$sec1[$grp] RP
			end
		endif
		# Start updates
		$MSR RUN INST$sec1[$grp] "setenv gtm_test_jobid $grp ; $gtm_tst/com/imptp.csh" >>&! imptp$grp.out
		# Setup for next cycle
		set orig_first = $primaries[$grp]
		@ primaries[$grp] = $sec1[$grp]
		@ sec1[$grp] = $sec2[$grp]
		@ sec2[$grp] = $orig_first
		#sleep 5
	end
end

# Now, let a secondary from the 1st non-supplementary group do the replicating to the supplementary groups.
echo "** 2nd part, sec. replicate to non-supp."
foreach supp ($supp_groups)
	$MSR STOPSRC INST$primaries[$nosupp_groups[1]] INST$primaries[$supp]
	$MSR STOPRCV INST$primaries[$nosupp_groups[1]] INST$primaries[$supp]
end
foreach supp ($supp_groups)
	$MSR START INST$sec1[$nosupp_groups[1]] INST$primaries[$supp] PP
end
#sleep 5

# Now, let another secondary from the 1st non-supplementary group do the replicating to only one of the supplementary group.
echo "** 3rd part, different sec. for the two non-supp."
$MSR STOPSRC INST$sec1[$nosupp_groups[1]] INST$primaries[$supp_groups[1]]
$MSR STOPRCV INST$sec1[$nosupp_groups[1]] INST$primaries[$supp_groups[1]]
$MSR START INST$sec2[$nosupp_groups[1]] INST$primaries[$supp_groups[1]] PP
#sleep 5

# End updates on all primaries and stop replication everywhere.
foreach grp ($lms_groups)
	$MSR RUN INST$primaries[$grp] "setenv gtm_test_jobid $grp ; $gtm_tst/com/endtp.csh" >>&! endtp$grp.out
end
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS

# Check everything before going with the "error" cases.
$MSR EXTRACT "INST1 INST2 INST3 INST7 INST8 INST9"
$MSR EXTRACT "INST1 INST10 INST11 INST12"
# Laurent : Do not check INST4-5 as they are not currently used.
#$MSR EXTRACT "INST4 INST5 INST6 INST7 INST8 INST9"
#$MSR EXTRACT "INST4 INST10 INST11 INST12"
$gtm_tst/com/dbcheck_filter.csh

# Test that two LMS group can not interact together (an instance from one group can not change group).
#
echo "** Test for INSNOTJOINED between two non-supp group."
# Laurent : Since $nosupp_group[2] is currently not defined (see comment way above), use the hardcoded value (2) instead.
$MSR START INST$primaries[$nosupp_groups[1]] INST$sec1[2] RP >>& failed_nosupp_start.logx

# Test that a supplementary group can not replicate to another supplementary group.
#
echo "** Test for INSNOTJOINED between two supp group."
$MSR START INST$primaries[$supp_groups[1]] INST$sec1[$supp_groups[2]] RP >>& failed_supp_start.logx

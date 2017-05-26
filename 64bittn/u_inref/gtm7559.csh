#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test for GTM-7559.
# We want an index block that is too-full at dbcertify scan time but is empty (i.e. only has a *-key)
# at dbcertify certify time. Towards that, we do the following.
# We take the database created by v4dbprepare. Do dbcertify scan on it.
# That identifies a list of blocks (data and index) to be split in the GVT and DT.
# An example report follows
#	       Blknum           Offset  Blktype  BlkLvl   Blksize   Free   Key
#	   0x00000cb9           19d200    DT        0         506      6
#	   0x0000103e           20dc00    DT        0         507      5
#	   0x0000137c           275800    DT        1         508      4
#	   0x000034a9           69b200    GVT       0         510      2   [2] ^x(-47703371)
#	   0x000034f6           6a4c00    GVT       1         506      6
#	   0x0000351e           6a9c00    GVT       1         512      0
#	   0x00003583           6b6600    GVT       0         508      4   [2] ^x(-46908865.06)
# In this list, filter out the GVT index blocks. These are too-full index blocks.
# And for each of them, determine one node under the rightmost data block. And except for that, kill the rest of the nodes.
# This way we make the GVT index block size reduce from a too-full block to having just one * record without causing any
# block splits or bitmap block frees. And then feed this database to dbcertify certify to see how it responds to such a block.
echo "Running DBCERTIFY SCAN"
$gtm_tst/com/backup_dbjnl.csh gtm7559_bak "*.dat" cp
cp pre_scan_mumps.dat mumps.dat
$DBCERTIFY scan -detail -outfile=gtm7559.scan DEFAULT >& gtm7559.detail1
echo "Identifying too-full GVT index blocks and killing as many nodes as needed to make them *-only blocks"
set blknum_list = `$grep GVT gtm7559.detail1 |& $grep "GVT       . " | $grep -v "GVT       0" | sed 's/0x0*//g' | $tst_awk '{print $1}'`
# It is possible that in some cases we dont see a too-full GVT index block at all so account for that.
# Note: The below code is ideally done using an M program and a pipe device. But we are using V4 GTM right now
# and pipe devices were not present then. So we make do with a shell script & dse loop.
if ("$blknum_list" != "") then
	foreach block ($blknum_list)
		@ blklevl = `$DSE dump -block=$block -header |& $tst_awk '/Block/  {print $6;}'`
		set starblock = $block
		while ($blklevl > 0)
			set starblock = `$DSE dump -block=$starblock |& $tst_awk '/Rec:/ && $13=="*" { print $11}'`
			@ blklevl = $blklevl - 1
		end
		# Now that we have the rightmost leaf level block #, find out the first record in it
		# Use DSE DUMP -GLO in case the key contains unprintable characters.
		set leafblock = $starblock
		cat > gtm7559_dse.input << CAT_EOF
		open -file=gtm7559.glo
		dump -block=$leafblock -glo
CAT_EOF
		$DSE < gtm7559_dse.input >& gtm7559_dse.output
		if (0 != $status) then
			echo "TEST-E-ERROR: Fail at dse stage"
			exit -1
		endif
		$head -3 gtm7559.glo |& $tail -1 | sed 's/\^x(\(.*\))/  set except(\1)=""/g' >>&! gtm7559.m
	end
	$GTM << GTM_EOF > gtm7559m.out
		do ^gtm7559	; populate "except()" array
		set subs="" for  set subs=\$order(^x(subs))  quit:subs=""  if '\$data(except(subs)) kill ^x(subs)
GTM_EOF
endif
$DBCERTIFY scan -detail -report DEFAULT >& gtm7559.detail2
cp mumps.dat gtm7559_pre_certify.dat
echo "Running DBCERTIFY CERTIFY to verify no errors or cores"
echo "yes" | $DBCERTIFY certify gtm7559.scan >& gtm7559_dbcertify_certify.out
echo "Running DBCERTIFY SCAN again to verify all too-full blocks have been split by DBCERTIFY CERTIFY"
$DBCERTIFY scan -detail -report DEFAULT >& gtm7559.detail3
# Note: The below code has been lifted from dbcertify_certify.csh
$grep -E "DT|GVT " gtm7559.detail3 | sed 's/^.*-//g' | sed 's/ *//g' | sed 's/\t*//g' | $tst_awk -F"[" '{print $1}' >& zerochk.out
if (`$grep -v "^0" zerochk.out|wc -l`) then
        echo "TEST-E-ERROR DVT or GT has NON-ZERO value in them. Pls. check dbceritfy scan results"
else
	echo "DVT,GT check PASSED"
endif
$gtm_tst/com/dbcheck.csh

#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Awk routine to parse the output from a "free -g" command and see if the total of mem and swap exceeds the
# that needed for a 64GB journal and receive pools. We don't know exactly what this minimum is but at this
# point, the only system the v63014/gtm7628 test is able to run on has 64GB RAM plus another 16GB in swap
# space so make that combined total our current minimum to run the test. This script expects to be fed the
# output of 'free -g' so the values are already in gigabytes.
#

/^Mem:/	{
	totram = $2;
}

/^Swap:/ {
	totswap = $2
}

END	{
	#
	# minimum needed is 62GB (RAM) + 15GB (SWAP) - Even if a system has 64GB, up to 2GB of that may be used
	# for various motherboard purposes (video, microcode, etc) or for the kernel and its memory.
	#
	minMemNeeded = (62 + 15)
	if (minMemNeeded <= (totram + totswap))
		print "1"	# We have sufficient memory
	else
		print "0"	# We do NOT have sufficient memory
}

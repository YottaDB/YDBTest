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

BEGIN {
	status= "NULL"
}

(($0 ~/key/) || ($0 ~ /^$/)) {
	next;
}

($0 ~/Shared Memory Segments/) {
	status = "m ";
	print "\nShared Memory:"
	print "T ID\tKEY\tMODE\tOWNER\tbytes\tnattch\tstatus"
	next;
}

($0 ~/Semaphore Arrays/) {
	status = "s ";
	print "\nSemaphores:"
	print "T ID\tKEY\tMODE\tOWNER\tnsems\tstatus"
	next;
}

($0 ~/Message Queues/) {
	status = "q ";
	print "\nMessage Queues:"
	print "T ID\tKEY\tMODE\tOWNER\tused-bytes\tmessages"
	next;
}

{
	if (length($2) > 10) {
		dollar_3 = substr($2,11)
		$2 = substr($2,1,10)
		# this is a sleazy solution:
		printf status "%s\t%s\t%s\t%s\t%s\t%s\t%s",$2,$1,$3,dollar_3,$4,$5,$6
	} else
  		printf status "%s\t%s\t%s\t%s\t%s\t%s\t%s",$2,$1,$4,$3,$5,$6,$7
	printf "\n"
}

END {
	print
}

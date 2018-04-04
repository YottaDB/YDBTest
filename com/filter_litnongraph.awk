#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Filter the below output from the log file
#	 set $x=$x_$J("",48-$L($x))_$J($FN($piece(x(x),".",2),",",2),18)
#	                                                ^-----
#		At column 49, line 2, source module /media/sdb3/kishoreh/tst_V951_dbg_33_080922_143706/v52000_0/tmp/profile1.m
#%YDB-W-LITNONGRAPH, M standard requires graphics in string literals

BEGIN {
	# lineno is the queue index - holds values 0,1,2
	# line[line] holds the actual line from the file
	# flushed[line] checks if the queue is flushed or has data. If it has data, print it before pushing in
	# flushed array is maintained in order to differentiate the blank line in the data. i.e if a blank line is in data,
	# to check if the element has data, the condition  - if ("" != line[lineno]) - will return false which we is not true
	lineno = 0
	curp = 2
	for (i=0 ; i<=2 ; i++) { line[i] = "" ; flushed[i] = "" }
}

{
	# Read 4 lines, and if the 4th line has YDB-W-LITNONGRAPH, do not print any of the above read 4 lines and restart reading
	# Maintain a queue of size 3 and if not YDB-W-LITNONGRAPH, flush the first-in to the output
	if ($1 == "%YDB-W-LITNONGRAPH,")
	{
		# So it means the 3 lines in the queue are LITNONGRAPH related messages. Flush the queue and reset the counter
		for (i=0 ; i<=2 ; i++) { line[i] = "" ; flushed[i] = "" }
		lineno = 0
		next
	}
	if ("" != flushed[lineno])
	{
		# If the array element contains a valid value, print it
		print line[lineno]
	}
	# Push the line into the queue
	line[lineno] = $0
	flushed[lineno] = "print"
	lineno = (lineno +1)%3
}

END {
#  If there are any lines in the queue unprocessed, print them
	for (i=0 ; i<=2 ; i++)
	{
		if ("" != flushed[lineno])
		{
			# If the array element contains a valid value, print it
			print line[lineno]
		}
		lineno = (lineno +1)%3
	}
}

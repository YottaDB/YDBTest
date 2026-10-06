#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Prints the instruction count from output that contains a "com/perfstat.csh" statistics line, such as
#	1375765  instructions:u 2181638 100.00
#	5107145  cpu_core/instructions/u 4927329 100.00
#	1895723  instructions:u 0.01% 1597575 100.00	(with "-r N")
# The input may also contain the output of the measured program, so the line is selected by its form rather
# than by its position. The last field is the percentage of time the counter ran, which keeps a program output
# line like "7 instructions executed" from matching.
# If there is no such line (including when perf printed "<not counted>"), prints a TEST-E-NOCOUNT error to stderr,
# so that it is not captured along with the count, prints nothing to stdout and exits with status 1. Callers test
# for an empty result rather than the exit status, which reaches $status from a backquote only while tcsh's
# anyerror variable is set.
($1 ~ /^[0-9]+$/) && ($2 ~ /(^|\/)instructions(\/|:|$)/) && ($NF ~ /^[0-9]+\.[0-9]+$/) {
	count = $1
	print count
	exit
}
END {
	if ("" == count) {
		if (("" == FILENAME) || ("-" == FILENAME))
			print "TEST-E-NOCOUNT : no instruction count line produced by perf" > "/dev/stderr"
		else
			print "TEST-E-NOCOUNT : no instruction count line in " FILENAME > "/dev/stderr"
		exit 1
	}
}

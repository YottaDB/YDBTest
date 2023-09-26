#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# We find out the fd from the open system call (4 in the example below)
#	11:08:43 open("extract.ZWR", O_RDWR|O_CREAT|O_NOCTTY, 0664) = 4 <0.000017>
# And then check for number of occurrences of the write system call using fd=4 (example output below)
#	11:08:43 write(4, "GT.M MUPIP EXTRACT\n05-DEC-2017  "..., 465) = 465 <0.000006>
#
# The below awk expression achieves this. It filters out the 4 from the open command first and stores it in fd.
# This is done by using a field separator of = and filtering out the " 4 <0.000017>" first.
# And then removing the leading space and then the trailing timestamp (using the sub() commands).
# On Arch Linux, the open() system call shows up as openat() in the strace output.
# Hence the use of "open.*extract" below (to allow for open or openat).
#
# Linux reuses file fd after a file is closed; in order to prevent counting
# lines that are written to a seprate file reusing the same fd, if we detect
# after the open that we are closing that fd, we stop counting, print and exit.
#
BEGIN {
	FS = "="
}
/open.*(extract|mumps.mjf)/ {
	openfd = $2
	sub(/^ /,"",openfd)
	sub(" .*","",openfd)
	fdmatch="write[^a-zA-Z0-9]"openfd
	opendone = 1
}

$0 ~ fdmatch {
	if(length(fdmatch)) {
		total++
	}
}

/close/{
	if(opendone) {
		closeline = $1
		# close(4) -> 4
		match($1, /\(([0-9]+)\)/, matches)
		closefd = matches[1]

		if((openfd == closefd)) {
			print total
			exit
		}
	}
};

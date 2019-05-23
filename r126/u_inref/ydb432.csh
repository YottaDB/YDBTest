#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test that mumps -object will strip from the tail of a file one .o and/or one .m in that order

echo "# Test that mumps -object will strip from the tail of a file one .o and/or one .m in that order"

# blank .m files to compile
touch x.m
mkdir tmp
touch tmp/x.m

echo "\nTesting all permutations of relative and absolute paths"
foreach in (x.m tmp/x.m `pwd`/x.m `pwd`/tmp/x.m)
	foreach pre ("" tmp/ `pwd`/ `pwd`/tmp/)
		foreach out (x.m.o y.m)
			echo "mumps -o=$pre$out $in"
			$ydb_dist/mumps -o=$pre$out $in
			ls -1 $pre$out > /dev/null
			if($status != 0) then
				echo "$pre$out does not exist when it should"
			endif
			rm $pre$out
		end
	end
	echo ""
end

# all of these atemps should output a NOTMNAME error
echo "\nError Checks"
foreach in (x.m tmp/x.m)
	foreach out (y.o.m tmp/y.o.m)
		echo "mumps -o=$out $in"
		$ydb_dist/mumps -o=$out $in
	end
end

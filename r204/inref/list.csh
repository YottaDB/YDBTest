#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

# Given a .m source file, compile it to bytecode and parse the output.
# Optionally, filter the bytecode to only the nth M line, as determined by the second argument.
set file = $1
if ($#argv > 1) then
	set line = $2; shift
endif
shift
if ($?line && $?gtmcompile) then
	if ("$gtmcompile" =~ *-noline_entry* ) then
		# -noline_entry causes an extra OC_LINEFETCH at the beginning of the program, which we need to skip over.
		@ line += 1
	endif
endif
set dst = `basename $file .m`.lis

$ydb_dist/mumps -machine -list=$dst $*:q $file
# With   -dynamic_literals, we generate additional `OC_LITC` and `OC_STO` lines.
# With -nodynamic_literals, we generate additional `OC_STOLIT` lines.
# With -noline_entry, some LINESTARTs are turned into LINEFETCH, and vice versa for -line_entry.
# Normalize them all.
grep -Eo 'OC_[A-Z0-9_]+' $dst | grep -Ev '^(OC_LITC|OC_STO|OC_STOLIT)$' | sed 's/^OC_LINEFETCH/OC_LINESTART/g' > all-opcodes.txt
if ( $?line ) then
	awk -v line=$line < all-opcodes.txt '\
		/OC_LINEFETCH|OC_LINESTART/ { m_line++; };\
		{ if (line == m_line) { print $0 } }'
else
	cat all-opcodes.txt
endif

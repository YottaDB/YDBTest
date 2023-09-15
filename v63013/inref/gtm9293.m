;#################################################################
;#                                                               #
;# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.       #
;# All rights reserved.                                          #
;#                                                               #
;#       This source code contains the intellectual property     #
;#       of its copyright holder(s), and is made available       #
;#       under a license.  If you do not know the terms of       #
;#       the license, please stop and do not read further.       #
;#                                                               #
;#################################################################

write
	write !,"# Testing that WRITE accepts empty string from argument indirection",!
	write "# New line is expected as the output",!
	set y=""
	write @y,!
	quit

do
	write !,"# Testing that DO accepts empty string from argument indirection",!
	write "# LABELEXPECTED error is expected",!
	set y=""
	do @y
	quit

xecute
	write !,"# Testing that XECUTE accepts empty string from argument indirection",!
	write "# No output is expected",!
	set y=""
	xecute @y
	quit

kill
	write !,"# Testing that KILL accepts empty string from argument indirection",!
	write "# VAREXPECTED error is expected",!
	set y=""
	kill @y
	quit


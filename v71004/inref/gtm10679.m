;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm10679 ;
	write "## Test 1: $REFERENCE updated by SET",!
	write "# set ^x=1",!
	set ^x=1
	write "# set ^y=2",!
	set ^y=2
	write "# set ^z=3",!
	set ^z=3
	write "# zwrite ^x",!
	zwrite ^x
	write "# Check $REFERENCE: Expect ^x, previously ^z.",!
	write "$REFERENCE="_$REFERENCE,!
	write !

	write "## Test 2: $REFERENCE updated by $GET",!
	write "# $GET(^y)="_$get(^y),!
	write "# zwrite ^x",!
	zwrite ^x
	write "# Check $REFERENCE: Expect ^x, previously ^y.",!
	write "$REFERENCE="_$REFERENCE,!
	write !

	write "## Test 3: $REFERENCE updated by postconditional",!
	write:^z "# write:^z",!
	write "# zwrite ^x",!
	zwrite ^x
	write "# Check $REFERENCE: Expect ^x, previously ^z.",!
	write "$REFERENCE="_$REFERENCE,!
	write !

	write "## Test 4: $REFERENCE updated by OPEN",!
	write "set ^socket=""socket""",!
	set ^socket="socket"
	write "open ^socket::""SOCKET""",!
	open ^socket::"SOCKET"
	write "# zwrite ^x",!
	zwrite ^x
	write "# Check $REFERENCE: Expect ^x, previously ^socket.",!
	write "$REFERENCE="_$REFERENCE,!
	write !

	write "## Test 5: $REFERENCE updated by USE",!
	write "# use ^socket",!
	use ^socket
	use $p
	write "# zwrite ^x",!
	zwrite ^x
	write "# Check $REFERENCE: Expect ^x, previously ^socket.",!
	write "$REFERENCE="_$REFERENCE,!
	write !

	write "## Test 6: $REFERENCE updated by CLOSE",!
	write "# close ^socket",!
	close ^socket
	write "# zwrite ^x",!
	zwrite ^x
	write "# Check $REFERENCE: Expect ^x, previously ^socket.",!
	write "$REFERENCE="_$REFERENCE,!
	write !

	write "## Test 7: $REFERENCE updated by NEW",!
	write "# if $DATA(^y)",!
	if $data(^y)
	write "# zwrite ^x",!
	zwrite ^x
	write "# Check $REFERENCE: Expect ^x, previously ^y.",!
	write "$REFERENCE="_$REFERENCE,!
	write !

	write "## Test 8: Restore $REFERENCE from variable",!
	write "# if ^y",!
	if ^y
	write "# zwrite ^x",!
	zwrite ^x
	write "# set restore=$REFERENCE",!
	set restore=$REFERENCE
	write "# if @restore",!
	if @restore
	write "# Check $REFERENCE: Expect ^x, previously ^y.",!
	write "$REFERENCE="_$REFERENCE,!

	quit

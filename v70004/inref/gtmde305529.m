;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmde305529	;
	write "# Install a SET trigger on [^x] to invoke [trigger^gtmde305529]",!
	set x=$ztrigger("item","+^x -command=set -name=x -xecute=""do trigger^gtmde305529""")
	write "# Do an update [set ^x=1] to fire a trigger that in turn invokes [trigger^gtmde305529]",!
	set ^x=1
	quit

trigger	;
	write "# Set $ZTSLATE to the string [bbbbb]",!
        set $ztslate=$translate($justify("b",5)," ","b")
	write "# Set lvns x(1) to x(1000) to 100 byte strings containing [aaaaaa...]",!
        for i=1:1:1000 s x(i)=$translate($justify("a",100)," ","a")
	write "# Invoke garbage collection using [view ""STP_GCOL""]",!
        view "STP_GCOL"
	write "# Write value of $ZTSLATE while still inside the trigger",!
	write "# We expect it to still hold the value [bbbbb]",!
	write "# Without the fixes in GTM-DE305529, it would hold garbage values",!
        zwrite $ztslate
        quit


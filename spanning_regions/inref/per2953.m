;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
per2953		;
per2953a	;
	write "# A reference to extended global followed by a zwrite",!
	write "# A normal global access following that should not pick extended global reference",!
	set ^a(1)="default gld"
	set ^|"a.gld"|a(1)="extended gld"
	zwrite ^a               ; should display ^a(1)="default gld"
	write "^a(1)=",^a(1),!  ; should display "default gld" but would display "extended gld" before PER-2953 was fixed
per2953b	;
	write "# A reference to extended global followed by a zwrite",!
	write "# A naked reference following that still should point to extended global reference",!
	set ^a(2)="default gld"
	set ^|"a.gld"|a(2)="extended gld"
	zwrite ^a               ; should display ^a(1)="default gld" ; ^a(2)="default gld"
	write "^a(2)=",^(2),!   ; should display "extended gld"
per2953c	;
	write "# make sure that even if savtarg and rectarg opcodes are generated in a boolean expression,",!
	write "# the naked indicator is properly maintained and that gd_map/gd_map_top has nothing to do with this maintenance.",!
	set ^a(3)=1
	set ^|"a.gld"|a(3)=21
	; Because the first part of the OR condition below is non-zero, the second part of the boolean expression will be
	; short-circuited by default. This means the op_fngvget for the extended reference will not happen (although the
	; op_gvextnam call would happen). We nevertheless expect to see the naked indicator correspond to ^a(1) of "a.gld"
	; and to test this we display its value (expect it to be "21").
	if ($get(^a(3))!$get(^|"a.gld"|a(3)))  write "Naked ^a(3)=",^(3),!
	quit

lcl	;
	; changing local collation from non-default to default
	; define gtm_collate_18 in the shell
	w $V("YLCT"),!	;0
	v "YLCT":18
	w $V("YLCT"),!	;18
	v "YLCT":0
	w $V("YLCT"),!	;0
	v "YLCT":0	; crashes in V43001D and earlier
	; the second time you set local collation to default (0), V43001D and earlier versions crash
	w $V("YLCT"),!	;0
	w "PASS",!
	q

; c002900.m
; This script tries the $view function both with and without access to globals in the view.
; It tests the changes to gtm to make sure $view works for a new global directory without
; accessing a global first.
;
	set $zgbldir="mumps"
	write !,$view("region","^a")
	set $zgbldir="other"
	write !,$view("region","^a")
	set $zgbldir="mumps"
	write !,$view("region","^a")
	set ^a=5
	write !,^a
	write !,$data(^a)
	write !,$view("region","^a")
	set $zgbldir="other"
	set ^a=6
	write !,^a
	write !,$data(^a)
	write !,$view("region","^a")
	set $zgbldir="mumps"
	write !,^a
	write !,$view("region","^a"),!
	quit

;
;	PER 2968:  This is the calling routine.  It references the label `foo'
;		   that later disappears.
;
per2968a w "This is the calling routine",!
	d foo^per2968b
	q

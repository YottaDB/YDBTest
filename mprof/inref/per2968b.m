;
;	PER 2968:  This is the version of the called routine that contains
;		   the label `foo'.
;
per2968b w "This is the called routine",!
foo	w "This is foo^per2968b",!
	q

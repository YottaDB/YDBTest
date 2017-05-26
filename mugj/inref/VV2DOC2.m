VV2DOC2	;VV2DOC V.7.1 -2-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;     II-2. cs between command and command
	;     II-3. cs of IF command
	;     II-4. cs of ELSE command
	;     II-5. cs of FOR - QUIT - DO command
	;     II-6. cs between ls and comment in XECUTE command
	;     II-7. cs between commands in XECUTE command
	;     II-8. cs between commands with indirection argument
	;
	;
	;Lower case letter command words and $data -1-
	;     (VV2LCC1)
	;
	;     II- 9. for
	;     II-10. f
	;     II-11. write
	;     II-12. w
	;     II-13. do
	;     II-14. d
	;     II-15. hang
	;     II-16. h
	;     II-17. quit
	;     II-18. q
	;     II-19. goto
	;     II-20. g
	;
	;
	;Lower case letter command words and $data -2-
	;     (VV2LCC2)
	;
	;     II-21. if
	;     II-22. i
	;     II-23. else
	;     II-24. e
	;     II-25. set
	;     II-26. s
	;     II-27. kill
	;     II-28. k
	;     II-29. $data
	;     II-30. $d
	;     II-31. xecute
	;     II-32. x
	;
	;
	;
	;

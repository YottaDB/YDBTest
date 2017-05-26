VV2DOC7	;VV2DOC V.7.1 -7-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;     @lnamind@(L expr)
	;
	;     II-127. Multi use variable name indirection
	;
	;     @gnamind@(L expr)
	;
	;     II-128. Multi use variable name indirection
	;     II-129. Effect of naked indicator by variable name indirection
	;
	;
	;Variable name indirection -2-
	;     (VV2VNIB)
	;
	;     II-130. Variable name indirection in postcondition
	;        II-130.1  local
	;        II-130.2  global
	;        II-130.3  DO and GOTO command
	;     II-131. Variable name indirection in expr to the right of the =
	;     II-132. Value of indirection contains variable name indirection
	;        II-132.1  interpretation of indirection
	;        II-132.2  another interpretation of indirection
	;        II-132.3  value of name indirection contains variable name indirection
	;
	;
	;Variable name indirection -3-
	;     (VV2VNIC)
	;
	;     II-133. Variable name indirection in expr
	;     II-134. Multi-assignment of variable name indirection
	;     II-135. Value of XECUTE argument contains variable name indirection
	;
	;
	;Naked references
	;     (VV2NR)
	;
	;     II-136. Effect of naked reference on KILL command
	;     II-137. Effect of naked reference on $DATA function
	;     II-138. Effect of global reference in $DATA on naked indicator
	;     II-139. Interpretation sequence of SET command
	;
	;
	;Read count
	;     (VV2READ)
	;
	;     READ lvn readcount

VV2DOC6	;VV2DOC V.7.1 -6-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;        II-102.2  K=2
	;        II-102.3  K=5
	;     II-103. $D(glvn)=0 and intexpr3<1
	;     II-104. $D(glvn)=0 and intexpr2>intexpr3
	;     II-105. $D(glvn)=0 and intexpr3>intexpr2>1
	;     II-106. intexpr2<1
	;     II-107. glvn is naked reference
	;     II-108. Interpretation sequence of subscripted left hand $PIECE
	;
	;
	;Left hand $PIECE -2-
	;     (VV2LHP2)
	;
	;     II-109. Naked indicator when intexpr2>intexpr3
	;     II-110. Naked indicator when intexpr3<1
	;     II-111. Lower case letter left hand "$piece"
	;     II-112. Left hand $PIECE with postcondition
	;     II-113. Indirection of left hand $PIECE
	;     II-114. expr1 is empty string
	;     II-115. Value of glvn is numeric data
	;     II-116. Control characters are used as delimiters (expr1)
	;     II-117. Value of expr1 contains operators
	;     II-118. intexpr2 and intexpr3 are numlits
	;     II-119. Value of expr1,intexpr2,intexpr3 are functions
	;        II-119.1  $C
	;        II-119.2  $L
	;        II-119.3  $P
	;
	;
	;Variable name indirection -1-
	;     (VV2VNIA)
	;
	;     @lnamind@(L expr)
	;
	;     II-120. lnamind is lvn
	;     II-121. lnamind is string literal
	;     II-122. lnamind is rexpratom
	;
	;     @gnamind@(L expr)
	;
	;     II-123. gnamind is gvn
	;     II-124. gnamind is indirection
	;     II-125. gnamind is 2 levels indirection
	;     II-126. Subscript is variable name indirection
	;

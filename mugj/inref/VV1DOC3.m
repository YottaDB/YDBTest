VV1DOC3	;VV1DOC V.7.1 -3-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     68. V1DLB ----- Sub driver
	;     69. V1DLB1 ---- $DATA and KILL of local variables -2.1-
	;                       $DATA of subscripted local variable name and KILL command
	;     70. V1DLB2 ---- $DATA and KILL of local variables -2.2-
	;                       $DATA of subscripted local variable name and KILL command
	;     71. V1DLC ----- $DATA and KILL of local variables -3-
	;                       $DATA of subscripted local variables and exclusive KILL
	;     72. V1DGA ----- $DATA and KILL of global variables -1-
	;                       $DATA of unsubscripted globals and KILL command
	;     73. V1DGB ----- Sub driver
	;     74. V1DGB1 ---- $DATA and KILL of global variables -2.1-
	;                       $DATA of subscripted globals and KILL command
	;     75. V1DGB2 ---- $DATA and KILL of global variables -2.2-
	;                       $DATA of subscripted globals and KILL command
	;     76. V1NR ------ Sub driver
	;     77. V1NR1 ----- Naked reference -1-
	;     78. V1NR2 ----- Naked reference -2-
	;     79. V1NX  ----- Sub driver
	;     80. V1NX1 ----- $NEXT -1-
	;     81. V1NX2 ----- $NEXT -2-
	;     82. V1SET ----- SET command
	;     83. V1GO  ----- Sub driver
	;     84. V1GO1 ----- GOTO command ( local branching ) -1-
	;     85. V1GO2 ----- GOTO command ( local branching ) -2-
	;     86. V1OV ------ GOTO command ( overlay with external routine )
	;                       V1OV is overlaid with V1OV1.
	;     87. V1DO  ----- Sub driver
	;     88. V1DO1 ----- DO command ( call internal line ) -1-
	;     89. V1DO2 ----- DO command ( call internal line ) -2-
	;     90. V1DO3 ----- DO command ( call internal line ) -3-
	;     91. V1CALL ---- DO command ( call external routine )
	;                       V1CALL is overlaid with V1CALL1.
	;     92. V1IE ------ Sub driver
	;     93. V1IE1 ----- IF and ELSE -1-
	;     94. V1IE2 ----- IF and ELSE -2-
	;     95. V1PC ------ Sub driver
	;     96. V1PCA ----- Post conditionals -1-
	;                       V1PCA is overlaid with V1PC1.
	;     97. V1PCB ----- Post conditionals -2-
	;                       V1PCB is overlaid with V1PC1.
	;     98. V1FORA ---- Sub driver
	;     99. V1FORA1 --- FOR command -1.1-
	;    100. V1FORA2 --- FOR command -1.2-
	;    101. V1FORB ---- FOR command -2-
	;    102. V1FORC ---- Sub driver

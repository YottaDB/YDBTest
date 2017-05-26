VV1DOC5	;VV1DOC V.7.1 -5-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;                       V1BR is overlaid with V1BR1.
	;    141. V1READA --- Sub driver
	;    142. V1READA1 -- READ command -1.1-
	;    143. V1READA2 -- READ command -1.2-
	;    144. V1READB --- Sub driver
	;    145. V1READB1 -- READ command -2.1-
	;    146. V1READB2 -- READ command -2.2-
	;    147. V1HANG ---- HANG command
	;    148. V1PO ------ Parenthesis and operator
	;    149. V1RANDA --- $RANDOM function -1-
	;    150. V1RANDB --- $RANDOM function -2-
	;    151. V1IO ------ I/O control
	;                       V1IO is overlaid with V1IO1 and V1IO2.
	;    152. V1MJA ----- Sub driver
	;    153. V1MJA1 ---- Multi job -1-
	;                       V1MJB routine execute in another partition.
	;    154. V1MJA2 ---- Multi job -2-
	;                       V1MJB routine execute in another partition.
	;
	;    155. STATIS^VREPORT --- Result Reporting for Validation Part I
	;
	;
	;
	;
	;
	;
	;2)   Session titles  (Routine names)
	;     Section titles with or without ID numbers and propositions
	;     Tests ( .child Tests . grandchild Tests ) with ID numbers and propositions
	;
	;
	;
	;WRITE command
	;     (V1WR)
	;
	;     I-802. Output of alphabetics
	;       I-802.1  Output of upper-case alphabetics
	;       I-802.2  Output of lower-case alphabetics
	;     I-803. Output of digits
	;     I-804. Output of punctuation characters
	;
	;
	;Comment
	;     (V1CMT)
	;

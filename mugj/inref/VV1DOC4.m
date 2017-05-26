VV1DOC4	;VV1DOC V.7.1 -4-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;    103. V1FORC1 --- FOR command -3.1-
	;    104. V1FORC2 --- FOR command -3.2-
	;    105. V1IDNM ---- Sub driver
	;    106. V1IDNM1 --- Name level indirection -1-
	;    107. V1IDNM2 --- Name level indirection -2-
	;    108. V1IDNM3 --- Name level indirection -3-
	;    109  V1IDGO ---- Sub driver
	;    110. V1IDGOA --- Indirection in GOTO command -1-
	;                       V1IDGOA is overlaid with V1IDGO1.
	;    111. V1IDGOB --- Indirection in GOTO command -2-
	;                       V1IDGOB is overlaid with V1IDGO1.
	;    112. V1IDDO ---- Sub driver
	;    113. V1IDDOA --- Indirection in DO command -1-
	;                       V1IDDOA is overlaid with V1IDDO1.
	;    114. V1IDDOB --- Indirection in DO command -2-
	;                       V1IDDOB is overlaid with V1IDDO1.
	;    115. V1IDARG --- Sub driver
	;    116. V1IDARG1 -- Argument level indirection -1-
	;    117. V1IDARG2 -- Argument level indirection -2-
	;    118. V1IDARG3 -- Argument level indirection -3-
	;    119. V1IDARG4 -- Argument level indirection -4-
	;    120. V1IDARG5 -- Argument level indirection -5-
	;    121. V1XECA ---- Sub driver
	;    122. V1XECA1 --- XECUTE command -1.1-
	;                       V1XECA1 is overlaid with V1XECAE.
	;    123. V1XECA2 --- XECUTE command -1.2-
	;                       V1XECA2 is overlaid with V1XECAE.
	;    124. V1XECB ---- XECUTE command -2-
	;    125. V1SEQ ----- Execution sequence
	;                       V1SEQ is overlaid with V1SEQ1.
	;    126. V1PAT ----- Sub driver
	;    127. V1PAT1 ---- Pattern match operator -1-
	;    128. V1PAT2 ---- Pattern match operator -2-
	;    129. V1NST1 ---- Nesting level -1-
	;    130. V1NST2 ---- Nesting level -2-
	;    131. V1NST3 ---- Nesting level -3-
	;    132. V1JST ----- Sub driver
	;    133. V1JST1 ---- $JUSTIFY, $SELECT and $TEXT -1-
	;    134. V1JST2 ---- $JUSTIFY, $SELECT and $TEXT -2-
	;    135. V1JST3 ---- $JUSTIFY, $SELECT and $TEXT -3-
	;    136. V1SVH ----- Special variable $HOROLOG
	;    137. V1SVS ----- Special variable $STORAGE
	;    138. V1MAX1 ---- Various maximum range -1-
	;    139. V1MAX2 ---- Various maximum range -2-
	;    140. V1BR ------ BREAK command

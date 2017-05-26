VV1DOC37	;VV1DOC V.7.1 -37-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Logical operator -3.1- (!,&) and concatenation operator (_)
	;     (V1BOC1)
	;
	;       The main purpose of this routine is to validate truth value
	;       interpretation of MUMPS.
	;
	;     And  (&)
	;
	;     I-140. expratoms are 0 or 1
	;       I-140.1  1&1
	;       I-140.2  1&0
	;       I-140.3  0&1
	;       I-140.4  0&0
	;     I-141. expratoms are numlit
	;       I-141.1  2&3
	;       I-141.2  4&0
	;       I-141.3  0&-5
	;       I-141.4  0.06&-0.007
	;     I-142. expratoms are strlit
	;       I-142.1  "A"&"B"
	;       I-142.2  "-0.0A"&"2B"
	;     I-143. expratoms are empty string
	;     I-144. expratoms are lvn
	;       I-144.1  A&B
	;       I-144.2  C&%D
	;
	;     Nand  ('&)
	;
	;     I-145. expratoms are 0 or 1
	;       I-145.1  1'&1
	;       I-145.2  1'&0
	;       I-145.3  0'&1
	;       I-145.4  0'&0
	;     I-146. expratoms are numlit
	;       I-146.1  2'&30000
	;       I-146.2  40'&0
	;       I-146.3  2E-10'&0
	;       I-146.4  00.0300'&4E10
	;     I-147. expratoms are strlit
	;       I-147.1  "A"'&"B"
	;       I-147.2  "-0.0A"'&"2B"
	;     I-148. expratoms are empty string
	;     I-149. expratoms are lvn
	;       I-149.1  C'&D
	;       I-149.2  D'&%A

VV1DOC66	;VV1DOC V.7.1 -66-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Pattern match operator -1-
	;     (V1PAT1)
	;
	;     I-696. pattern code "C" and its mapping
	;       I-696.1  function?1C
	;       I-696.2  lvn?5C
	;     I-697. pattern code "N" and its mapping
	;       I-697.1  function?1N
	;       I-697.2  lvn?5N
	;     I-698. pattern code "P" and its mapping
	;       I-698.1  function?1P
	;       I-698.2  lvn?5P
	;     I-699. pattern code "A" and its mapping
	;       I-699.1  function?1A
	;       I-699.2  lvn?5A
	;     I-700. pattern code "L" and its mapping
	;       I-700.1  function?1L
	;       I-700.2  lvn?5L
	;     I-701. pattern code "U" and its mapping
	;       I-701.1  function?1U
	;       I-701.2  lvn?5U
	;     I-702. pattern code "E" and its mapping
	;       I-702.1  function?1E
	;       I-702.2  lvn?5E
	;
	;
	;Pattern match operator -2-
	;     (V1PAT2)
	;
	;     I-703. multiplier>0
	;     I-704. multiplier=0
	;     I-705. infinite multiplier (.)
	;     I-706. empty string as patatom
	;       I-706.1  ?patatom
	;       I-706.2  '?patatom
	;     I-707. not match ('?)
	;     I-708. pattern level indirection
	;     I-709. interpretation of left side expression
	;     I-710. pattern match of maximum length of data
	;     I-711. various combination of patcode
	;
	;
	;Nesting level -1-
	;     (V1NST1)
	;

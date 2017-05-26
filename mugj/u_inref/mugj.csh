#! /usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh . . 125 500
if ($test_collation_no != 0) then
	echo "Running with alternative collation. II-168.2, II-170.2, and II-172 will FAIL"
endif
$GTM << \xyyz
W !!,"V1WR" D ^V1WR
W !!,"V1CMT" D ^V1CMT
W !!,"V1LL1" D ^V1LL1
W !!,"V1LL2" D ^V1LL2
W !!,"V1PRGD" D ^V1PRGD
W !!,"V1RN" D ^V1RN
W !!,"V1PRSET" D ^V1PRSET
W !!,"V1PRIE" D ^V1PRIE
W !!,"V1PRFOR" D ^V1PRFOR
W !!,"V1NUM" D ^V1NUM
W !!,"V1FC" D ^V1FC
W !!,"V1UO" D ^V1UO
W !!,"V1BOA" D ^V1BOA
W !!,"V1BOB" D ^V1BOB
W !!,"V1BOC" D ^V1BOC
W !!,"V1FN" D ^V1FN
W !!,"V1AC" D ^V1AC
W !!,"V1LVN" D ^V1LVN
W !!,"V1GVN" D ^V1GVN
W !!,"V1DLA" D ^V1DLA
W !!,"V1DLB" D ^V1DLB
W !!,"V1DLC" D ^V1DLC
W !!,"V1DGA" D ^V1DGA
W !!,"V1DGB" D ^V1DGB
W !!,"V1NR" D ^V1NR
W !!,"V1NX" D ^V1NX
W !!,"V1SET" D ^V1SET
W !!,"V1GO" D ^V1GO
W !!,"V1OV" D ^V1OV
W !!,"V1DO" D ^V1DO
W !!,"V1CALL" D ^V1CALL
W !!,"V1IE" D ^V1IE
W !!,"V1PC" D ^V1PC
W !!,"V1FORA" D ^V1FORA
W !!,"V1FORB" D ^V1FORB
W !!,"V1FORC" D ^V1FORC
W !!,"V1IDNM" D ^V1IDNM
W !!,"V1IDGO" D ^V1IDGO
W !!,"V1IDDO" D ^V1IDDO
W !!,"V1IDARG" D ^V1IDARG
W !!,"V1XECA" D ^V1XECA
W !!,"V1XECB" D ^V1XECB
W !!,"V1SEQ" D ^V1SEQ
W !!,"V1PAT" D ^V1PAT
W !!,"V1NST1" D ^V1NST1
W !!,"V1NST2" D ^V1NST2
W !!,"V1NST3" D ^V1NST3
W !!,"V1JST" D ^V1JST
W !!,"V1SVH" D ^V1SVH
W !!,"V1SVS" D ^V1SVS
W !!,"V1MAX" D ^V1MAX
W !!,"V1BR" D ^V1BR
ZC
ZC
ZC
ZC
ZC
ZC
;;;;;;;;;W !!,"V1READA" D ^V1READA
;;;;;;;;;W !!,"V1READB" D ^V1READB
;;;;;;;;;W !!,"V1HANG" D ^V1HANG
;;;;;;;;;W !!,"V1PO" D ^V1PO
;;;;;;;;;W !!,"V1RANDA" D ^V1RANDA
;;;;;;;;;W !!,"V1RANDB" D ^V1RANDB
;;;;;;;;;W !!,"V1IO" D ^V1IO
;;;;;;;;;W !!,"V1MJA" D ^V1MJA
H
\xyyz
$GTM << xyzz
W !!,"VV2CS" D ^VV2CS ;Command space
W !!,"VV2LCC1" D ^VV2LCC1 ;Lower case letter command words and \$data -1-
W !!,"VV2LCC2" D ^VV2LCC2 ;Lower case letter command words and \$data -2-
W !!,"VV2LCF1" D ^VV2LCF1 ;Lower case letter function names (less \$data) and special variable names -1-
W !!,"VV2LCF2" D ^VV2LCF2 ;Lower case letter function names (less \$data) and special variable names -2-
W !!,"VV2FN1" D ^VV2FN1 ;Functions extended -1-
W !!,"VV2FN2" D ^VV2FN2 ;Functions extended -2-
W !!,"VV2LHP1" D ^VV2LHP1 ;Left hand \$PIECE -1-
W !!,"VV2LHP2" D ^VV2LHP2 ;Left hand \$PIECE -2-
W !!,"VV2VNIA" D ^VV2VNIA ;Variable name indirection -1-
W !!,"VV2VNIB" D ^VV2VNIB ;Variable name indirection -2-
W !!,"VV2VNIC" D ^VV2VNIC ;Variable name indirection -3-
W !!,"VV2NR" D ^VV2NR ;Naked reference
W !!,"VV2READ - timeouts cannot be automated" D ^VV2READ ;Read count
ABCABC
ABC
ABCABC
ABC

ABC
W !!,"VV2PAT1" D ^VV2PAT1 ;Pattern match -1-
W !!,"VV2PAT2" D ^VV2PAT2 ;Pattern match -2-
W !!,"VV2PAT3" D ^VV2PAT3 ;Pattern match -3-
W !!,"VV2NO" D ^VV2NO ;\$NEXT and \$ORDER
W !!,"VV2SS1" D ^VV2SS1 ;String subscript -1-
W !!,"VV2SS2" D ^VV2SS2 ;String subscript -2-
h
xyzz
sleep 10
$gtm_tst/com/dbcheck.csh -extract

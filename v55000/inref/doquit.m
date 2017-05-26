;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This script is used by GTM6813 subtest and tests gtm_zquit_anyway-controlled
; behavior with DO and $$ calls.
doquit
	set $ecode=""
        set $etrap="do etrap^doquit"

	set unix=$zv'["VMS"

	; quit argument evaluation
        do func()
	do func3()
	do func9()
	write $$func10_"D"
	if unix do func12
	else  do func12("")
	if $$func14
	do func16
	do func20

	; internal calls
	if $$intExtrNoQuitArg()
	do intLabelWithQuitArg()
	do intLabelWithQuitExpr()

	; external calls
	if $$extExtrNoQuitArg^external()
	do extLabelWithQuitArg^external()
	do extLabelWithQuitExpr^external()

        quit

func()
        quit $$func2()

func2()
	write "H"
        quit 1

func3()
	if unix	write "E"_$$func5()
	if 'unix write "E"_$$func5(0)
	do func6()
	do func4()
	quit

func4()
	quit:unix $$func7() quit $$func7("","")

func5(arg)
	quit:arg=2 $$func8()
	if arg="" set arg=0
	write "L"_$$func5(arg+1)
	quit

func6()
	write "O"
	quit

func7(x,y)
	write x_" "_y
	quit 1

func8(x)
	quit:unix x quit ""

func9()
	write "W"
	quit 1

func10()
	write "O"
	do func11()
	quit

func11(x)
	write "R"
	if unix do
	.	if x="" write "L"
	if 'unix write "L"
	quit

func12(x)
	quit $$func13(x)

func13(x)
	write x_"!"
	quit

func14()
        quit $$func15

func15()
	write " ..."
        quit 1

func16
	write "and "_$$func19
	set x=$$func19(1)
	write x

func17
	quit:unix $$func18 quit $$func18

func18()
	write "."
	quit

func19(x)
	if 'unix quit "bye"
	quit:x "bye" quit "good"

func20()
	write ".."
	quit $$func21

func21()
	write $$func22
	do func22()
	quit

func22()
	quit $$func23

func23(x)
	write x,!
	quit

intExtrNoQuitArg()
	write "Internal extrinsic that has no quit argument",!
	quit

intLabelWithQuitArg()
	write "Internal label that returns a value",!
	quit 1

intLabelWithQuitExpr()
	write "Internal label that has an evaluated quit expression",!
	quit $$intExtrEvalExpr()

intExtrEvalExpr()
	write "Internal extrinsic that gets evaluated",!
	quit 1

etrap
	write "FAIL: ",$$error^error($zstatus),!
	set $ecode=""
	quit

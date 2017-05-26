		; dbcreate  -rec=256 -bl=512
		; only two records fit one block in the updates below
		set i=1
		; ASCII
		do upd($C(97))  ; "a" -- 97 +  0
		do upd($C(98))  ; "b" --    +  1
		do upd($C(101)) ; "e" --    +  4
		do upd($C(102)) ; "f" --    +  5
		do upd($C(103)) ; "g" --    +  6
		do upd($C(104)) ; "h" --    +  7
		do upd($C(121)) ; "y" --    + 24
		do upd($C(122)) ; "z" --    + 25
		; the following mimics the same layout as the above ASCII
		; section, so the block splits should happen the same way, and
		; the index block contents should be similar
		; in the test, verify this
		do upd("一") ;do upd($C($$FUNC^%HD("4E00")))  -- U+4E00 +  0
		do upd("丁") ;do upd($C($$FUNC^%HD("4E01")))  --        +  1
		do upd("丄") ;do upd($C($$FUNC^%HD("4E04")))  --        +  4
		do upd("丅") ;do upd($C($$FUNC^%HD("4E05")))  --        +  5
		do upd("丆") ;do upd($C($$FUNC^%HD("4E06")))  --        +  6
		do upd("万") ;do upd($C($$FUNC^%HD("4E07")))  --        +  7
		do upd("仿") ;do upd($C($$FUNC^%HD("4EFF")))  --        + 24
		do upd("帀") ;do upd($C($$FUNC^%HD("5E00")))  --        + 25
		; larger ranges:
		; ??? should we enable the below
		do upd($C($$FUNC^%HD("6000"))) ;U+6000
		do upd($C($$FUNC^%HD("601D"))) ;U+601D
		do upd($C($$FUNC^%HD("6F00"))) ;U+6F00
		do upd($C($$FUNC^%HD("708D"))) ;U+708D
		do upd($C($$FUNC^%HD("A000"))) ;U+A000
		do upd($C($$FUNC^%HD("B000"))) ;U+B000
		do upd($C($$FUNC^%HD("10000"))) ;U+10000
		do upd($C($$FUNC^%HD("20000"))) ;U+20000 (CJK Extension B)
		do upd($C($$FUNC^%HD("20001"))) ;U+20001
		do upd($C($$FUNC^%HD("20005"))) ;U+20005
		quit
		;
upd(subs)	write "inserting key: ",subs,!
		set i=i+1,^b(subs)=i_$JUSTIFY(subs,230)

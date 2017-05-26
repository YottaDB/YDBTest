caseconv  ;
		; this routine requires convert.m which will be generated on the fly by com/convert.awk
		; make sure convert.awk is executed before trigerring this routine
		for func="^%LCASE","^%UCASE" do
		. write !,"Testing "_func_" for the entire range of control,ascii,punctuation chars, 1-255",!
		. set file=$$FUNC^%LCASE($p(func,"%",2))_".out"
		. open file:(NEW)
		. use file
		. for i=1:1:255 set %S=$CHAR(i) do @func ZWRITE %S
		. close file
		. write !,"Compare with the stored and verified output in the test system",!
		. write !,"diff "_file_" $gtm_tst/$tst/outref/"_file,!
		. zsystem "diff "_file_" $gtm_tst/$tst/outref/"_file
		;
		set file="FUNClcase.out"
		open file:(NEW)
		use file
		for i=1:1:255 set b=$$FUNC^%LCASE($CHAR(i)) set %S=b zwrite %S
		close file
		write !,"diff FUNClcase.out $gtm_tst/$tst/outref/lcase.out",!
		zsystem "diff FUNClcase.out $gtm_tst/$tst/outref/lcase.out"
		set file="FUNCucase.out"
		open file:(NEW)
		use file
		for i=1:1:255 set b=$$FUNC^%UCASE($CHAR(i)) set %S=b zwrite %S
		close file
		write !,"diff FUNCucase.out $gtm_tst/$tst/outref/ucase.out",!
		zsystem "diff FUNCucase.out $gtm_tst/$tst/outref/ucase.out"
		write !,"Testing some invalid mix of characters - should not change on LCASE conversion",!
		;for i=$ZCHAR(162,145,167),$ZCHAR(162,145,167),$ZCHAR(199,199,199),$ZCHAR(178,204,234) do
		;. set %S=i
		;. do ^%LCASE
		;. set convl=%S
		;. if i'=convl write "ERROR - LCASE for mix var"
		;. set %S=i
		;. do ^%UCASE
		;. set convu=%S
		;. if i'=convu write "ERROR - LCASE for mix var"
multibyte  ;
		do ^convert ; load arrays with special casing characters
		set cnti=cnti+1,comments(cnti)="WIDE CHARS"
		set testarorg(cnti)="ｗｈａｔ ａｂｏｕｔ ｗｉｄｅ ｃｈａｒｓ, Ｗｈａｔ Ａｂｏｕｔ Ｗｉｄｅ Ｃｈａｒｓ, ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥＣＨＡＲＳ"
		set testarl(cnti)="ｗｈａｔ ａｂｏｕｔ ｗｉｄｅ ｃｈａｒｓ, ｗｈａｔ ａｂｏｕｔ ｗｉｄｅ ｃｈａｒｓ, ｗｈａｔ ａｂｏｕｔ ｗｉｄｅｃｈａｒｓ"
		set testaru(cnti)="ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥ ＣＨＡＲＳ, ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥ ＣＨＡＲＳ, ＷＨＡＴ ＡＢＯＵＴ ＷＩＤＥＣＨＡＲＳ"
		set cnti=cnti+1,comments(cnti)="LATIN CHARS"
		set testarorg(cnti)="ľāťīň 'ō ľāťīň Ľāťīň 'Ō Ľāťīň ĽĀŤĪŇ 'Ō ĽĀŤĪŇ"
		set testarl(cnti)="ľāťīň 'ō ľāťīň ľāťīň 'ō ľāťīň ľāťīň 'ō ľāťīň"
		set testaru(cnti)="ĽĀŤĪŇ 'Ō ĽĀŤĪŇ ĽĀŤĪŇ 'Ō ĽĀŤĪŇ ĽĀŤĪŇ 'Ō ĽĀŤĪŇ"
		set cnti=cnti+1,comments(cnti)="GREEK CHARS"
		set testarorg(cnti)="some greek αβγδεζθκ λμνξοπρ Some Greek Αβγδεζθκ Λμνξοπρ SOME GREEK ΑΒΓΔΕΖΘΚ ΛΜΝΞΟΠΡ"
		set testarl(cnti)="some greek αβγδεζθκ λμνξοπρ some greek αβγδεζθκ λμνξοπρ some greek αβγδεζθκ λμνξοπρ"
		set testaru(cnti)="SOME GREEK ΑΒΓΔΕΖΘΚ ΛΜΝΞΟΠΡ SOME GREEK ΑΒΓΔΕΖΘΚ ΛΜΝΞΟΠΡ SOME GREEK ΑΒΓΔΕΖΘΚ ΛΜΝΞΟΠΡ"
		set cnti=cnti+1,comments(cnti)="CYRILLIC CHARS"
		set testarorg(cnti)="some cyrillic абвгжзмнопщъы ѥѧѩѫѭѯ SOME CYRILLIC Абвгдежзийклмнопщъы Ѥѧѩѫѭѯ Some Cyrillic АБВГДЕЖЗИЙКЛМНОПЩЪЫѤѦѨѪѬѮ"
		set testarl(cnti)="some cyrillic абвгжзмнопщъы ѥѧѩѫѭѯ some cyrillic абвгдежзийклмнопщъы ѥѧѩѫѭѯ some cyrillic абвгдежзийклмнопщъыѥѧѩѫѭѯ"
		set testaru(cnti)="SOME CYRILLIC АБВГЖЗМНОПЩЪЫ ѤѦѨѪѬѮ SOME CYRILLIC АБВГДЕЖЗИЙКЛМНОПЩЪЫ ѤѦѨѪѬѮ SOME CYRILLIC АБВГДЕЖЗИЙКЛМНОПЩЪЫѤѦѨѪѬѮ"
		set cnti=cnti+1,comments(cnti)="CHINESE CHARS"
		set testarorg(cnti)="Chinese Should Not Change 北齊書  周書  南史  北史  隋書"
		set testarl(cnti)="chinese should not change 北齊書  周書  南史  北史  隋書"
		set testaru(cnti)="CHINESE SHOULD NOT CHANGE 北齊書  周書  南史  北史  隋書"
		set cnti=cnti+1,comments(cnti)="WITH UMLAUTS"
		set testarorg(cnti)="How Will Umlaut Work ü"
		set testarl(cnti)="how will umlaut work ü"
		set testaru(cnti)="HOW WILL UMLAUT WORK Ü"
		set cnti=cnti+1,comments(cnti)="TAMIL CHARS"
		set testarorg(cnti)="Ok some Tamil with jUIcy comBIning chars எ ன ̇க̇ கு மா ற̇ ற ம̇ இ ல̇ ைல"
		set testarl(cnti)="ok some tamil with juicy combining chars எ ன ̇க̇ கு மா ற̇ ற ம̇ இ ல̇ ைல"
		set testaru(cnti)="OK SOME TAMIL WITH JUICY COMBINING CHARS எ ன ̇க̇ கு மா ற̇ ற ம̇ இ ல̇ ைல"
		write !,"Testing the following characters conversion",!
		for i=1:1:cnti do
		. write !,comments(i),!
		. for func="^%LCASE","^%UCASE" do
		. . set %S=testarorg(i)
		. . do @func
		. . do ^examine(%S,testarl(i),%S_" should be all converted to "_func)
		. . if (func="^%LCASE") set cstr=$$FUNC^%LCASE(testarorg(i))
		. . else  set cstr=$$FUNC^%UCASE(testarorg(i))
		. . do ^examine(cstr,testarl(i),cstr_" should be all converted to "_func)
		. . ; we assign stru value to strl variable just to not disturn the for loop
		. . ; the routine does compare UCASE result with stru only
		. . set testarl(i)=testaru(i)
		quit

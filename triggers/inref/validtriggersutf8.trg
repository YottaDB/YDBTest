; This is a valid file for Unicode mode loads
; Unicode Collation Algorithm
; http://www.unicode.org/reports/tr10/

; http://tdil.mit.gov.in/pchangeuni.htm
; Gujarati Alphabet      0A80 - 0AF8
; 	kill j for i=2688:1:2808 write $char(i,9) write:8=(($i(j))#9) !
; Numbers only
; 	for i=2790:1:2799 write $char(i,32)
; 	૦ ૧ ૨ ૩ ૪ ૫ ૬ ૭ ૮ ૯

; Hindi Alphabet      0980 - 09FF
; 	kill j for i=2304:1:2415 write $char(i,9) write:8=(($i(j))#9) !
; Numbers only
; 	for i=2406:1:2415 write $char(i,32)
; 	० १ २ ३ ४ ५ ६ ७ ८ ९
; Hindi period ।


; 1. Basic Global variables
+^names("મિલન") -commands=S -xecute="do rtn^testxecuteunicode()"
+^names("અમિ") -commands=S -xecute="do rtn^testxecuteunicode()"
+^names("અમિ") -commands=S -xecute="do rtn^testxecuteunicode()"
+^names("અમૂલ") -commands=set -xecute="do rtn^testxecuteunicode()"
+^names($char(2693,2734,2754,2738)) -commands=set -xecute="do rtn^testxecuteunicode()"

; Ranges with default collation
;
;	b. ranges (with ':' or '*')
+^generic(lvn=:) -commands=S -xecute="do rtn^testxecuteunicode()"

;	c. ranges and semi-colons
+^gujaratinum(lvn="૧":"૧૯૯૯") -commands=S -xecute="do rtn^testxecuteunicode(""1to1999:"")"
+^gujaratinum(lvn="૨":) -commands=S -xecute="do rtn^testxecuteunicode(""2+:"")"
+^gujaratinum(lvn="૨૦૦૦":) -commands=S -xecute="do rtn^testxecuteunicode(""2k+:"")"
+^gujarati(lvn="અ":"જ્ઞ") -commands=S -xecute="do rtn^testxecuteunicode(""ALPHA:"")"
+^hindi(lvn="२";"४";"६";"८";"१०") -commands=S -xecute="do rtn^testxecuteunicode(""EVEN:"")"
+^hindi(lvn="१";"३";"५";"७";"९") -commands=S -xecute="do rtn^testxecuteunicode(""ODD:"")"
+^hindi(lvn="५";"१०":"२०";"३०") -commands=S -xecute="do rtn^testxecuteunicode(""RANGE:"")"
+^hindinum(lvn="१":"९") -commands=S -xecute="do rtn^testxecuteunicode(""CHARS:"")"
; set utf=$char(2406) write "$zchar(" for i=1:1:4  set byte=$zascii(utf,i) write:byte>0 byte write:i<3 "," write:i=4 ")"
+^hindinum(lvn=$char(2407):$char(2415)) -commands=S -xecute="do rtn^testxecuteunicode(""DOLLARCHAR:"")"
+^hindinum(lvn=$zchar(224,165,167):$zchar(224,165,175)) -commands=S -xecute="do rtn^testxecuteunicode(""DOLLARZCHAR:"")"
+^hindinum(lvn=$char(2407):$char(2415),lvn2=$zchar(224,165,167):$zchar(224,165,175)) -commands=S -xecute="do rtn^testxecuteunicode(""UNICHAR:"")"

;	e. pattern matching with ? TODO
+^gujaratipat(lvn=?.N) -commands=S -xecute="do rtn^testxecuteunicode(""ALLNUMS:"")"
+^gujaratipat(lvn=?.e) -commands=S -xecute="do rtn^testxecuteunicode(""MATCHALL:"")"
+^gujaratipat(lvn=?3N1"-"2N1"-"4N;?2N1"-"7N) -commands=S -xecute="do rtn^testxecuteunicode(""SSN/TIN:"")"
+^hindipat(lvn=?.N) -commands=S -xecute="do rtn^testxecuteunicode(""ALLNUMS:"")"
+^hindipat(lvn=?1N) -commands=S -xecute="do rtn^testxecuteunicode(""SOMENUMS:"")"
+^gujaratipat(lvn=?3N1"-"2N1"-"4N,lvn2=:) -commands=S -xecute="do rtn^testxecuteunicode(""SSN+User:"")"

;	f. non-alphanumerics mixed in ranges
; this is a collation issue, skipping

;	l. extraneous ';', ':' and '*' removal
+^hindi(lvn=;"५";"१०":"२०";;;"३०";;:,lvn2=;;"१०";;;"२०";;:;;"३०";) -commands=S -xecute="do rtn^testxecuteunicode(""MESSY:"")"

;	ll. $char in subscripts
+^gujaratinum(lvn=$char(967):,$char(967):$char(967,966)) -commands=S -xecute="do rtn^testxecuteunicode()"

;	g. local variables as part of the trigger subscript range(s)
; already used

;	d. multiple subscripts
; already used

;	j. COLLATION checking on ranges HERE TODO
;	k. Unicode testing goes here
; this is the unicode test

; 2. Options
; not relevant

; 3. [z]delimiters with/without piece
;	a. 0/1 piece with quoted character
; ૱ $char(2801) is the INR symbol in Gujarati
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1 -delim=$char(2801)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1 -delim=$zchar(224,171,177)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1 -delim="૱"

;	b. 0/1 piece with $[z]char delimiter
+^unistorez(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -zdelim="૱"
+^unistorez(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -zdelim=$char(2801)
+^unistorez(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -zdelim=$zchar(224,171,177)

;	c. 0/1 piece with string
; ૱ $char(2801) is the INR symbol in Gujarati
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1 -delim=$char(2801,2801)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1 -delim=$zchar(224,171,177,224,171,177)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1 -delim="૱૱"

;	e. 0/1 piece with expression delimiter
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1;5 -delim=$char(2801)_"૱"
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1;5 -delim=$zchar(224,171,177)_$char(2801)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1;5 -delim="૱"_$zchar(224,171,177)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1:3 -delim=$char(2801)_$char(2801)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1:3 -delim=$zchar(224,171,177)_$zchar(224,171,177)
+^unistore(lvn=:) -commands=set -xecute="do rtn^testxecuteunicode()" -piece=1:3 -delim="૱"_"૱"

;	f. 1 piece with nasty characters in the expression
; in unicode, everything is nasty

;	g. UNICODE testing with zdelim
; that's what this whole file is

; 4. Pieces with static delimiter
;	a. single piece (done)
;	b. multiple pieces
; done step 3

;	c. ranges of pieces
; not relevant

;	d. pieces with LVN
; not relevant

; 5. Commands
; not relevant

; 6. xecute string
; unicode characters in the xecute string
+^uninames(:) -commands=set -xecute="do rtn^testxecuteunicode(""અમૂલ "")"
+^uninames(:) -commands=set -xecute="do rtn^testxecuteunicode($char(2693,2734,2754,2738,32))"

; 7. trigger names
; not relevant
; printing ASCII only with some exceptions, ^ in the first position, [#*] always disallowed

; 8. MAXIMUMS
; refer to the maxparse_* test

; SUBSCRANGE
+^unisubscrange(1,lvn="૯":"૧") -commands=S -xecute="do rtn^testxecuteunicode(""SUBSCRANGE1:"")"
+^unisubscrange(2,lvn="९":"१") -commands=S -xecute="do rtn^testxecuteunicode(""SUBSCRANGE2:"")"

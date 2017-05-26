genbadchars ;
	; this could be done directly as well, but $CHAR() behavior will
	; change, so I do not want to trust that function until we have tested it.
	; So, until we test and verify that the new version of GT.M behaves
	; correctly, let's use this routine with V51000 and generate an M routine
	; that has the bad characters in it explicitly (rather than $CHAR(x)).
	;
	; Since the output routine will have illformed unicode characters, it is not possible to edit in vi.
	;
	; Once we are confident with V990:
	; - We can change this routine to write "$ZCHAR(x)" instead of the actual bytes, and insert the generated lbadchar.m in the test system.
	; - Then we can scrap this routine.
	; Until then, use this routine in the test system.

	set file="lbadchar.m"
	open file:(NEWVERSION:OCHSET="M")
	use file
	set ucpstr=",ucp(cnti)=""-1"",width(cnti)=-1"
	set quote=""""
	set comma=","
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	write "lbadchar  ;",!
	write ?10,"; comments can be like this",!
	; The output line will be of the from:
	;set cnti=cnti+1,str(cnti)="__FILL_IN__",ucp(cnti)="-1",width(cnti)=-1,utf8(cnti)="150",comments(cnti)="starts with a trailing byte"
samples	do wbytea(150,"starts with a trailing byte")
	do wbytea(200,"leading byte of 2-byte char alone")
	do wbytea(230,"leading byte of 3-byte char alone")
	do wbytea(245,"leading byte of 4-byte char alone")
	do wbytea(248,"illegal char")
	do wbytea(249,"illegal char")
	do wbytea(250,"illegal char")
	do wbytea(251,"illegal char")
	do wbytea(252,"illegal char")
	do wbytea(253,"illegal char")
	do wbytea(254,"illegal char")
	do wbytea(255,"illegal char")
	do wbytea("192,224,40","leading byte of 2-byte char, followed by leading byte of 3-byte char")
	do wbytea("240,80,90","leading byte of 4-byte char, followed by 1 trailing byte, followed by 1-byte char")
	do wbytea("240,200,90","leading byte of 4-byte char, followed by leading byte of 2-byte char")
	do wbytea("245,85,85","leading byte for 4-byte char, plus 2 trailing bytes, i.e. one byte short")
	;
	write ?10,";",!
	write ?10,";- any valid unicode code point value, encoded in a longer than necessary format, e.g. an ASCII character encoded in two bytes (110xxxxx 10xxxxxx), such as:",!
	write ?10,";- $ZCHAR(192,191) -- incorrect representation of the char '?'",!
	write ?10,";- $ZCHAR(192,180) -- incorrect representation of the char '4'",!
	write ?10,";- $ZCHAR(224,129,129) -- incorrect representation of the char 'A'",!
	do wbytea("192,191","incorrect representation of the char '?'")
	do wbytea("192,180","incorrect representation of the char '4'")
	do wbytea("224,129,129","incorrect representation of the char 'A'")
	write ?10,"; -Line feed (U+000A) in overlong representations:",!
	write ?10,";",!
	write ?10,"; 0xC0 0x8A",!
	write ?10,"; 0xE0 0x80 0x8A",!
	write ?10,"; 0xF0 0x80 0x80 0x8A",!
	write ?10,"; 0xF8 0x80 0x80 0x80 0x8A",!
	write ?10,"; 0xFC 0x80 0x80 0x80 0x80 0x8A",!
	do wbytea("192,138","0xC0 0x8A -- overlong representation of U+000A")
	do wbytea("224,128,138","0xE0 0x80 0x8A -- overlong representation of U+000A")
	do wbytea("240,128,128,138","0xF0 0x80 0x80 0x8A -- overlong representation of U+000A")
	do wbytea("248,128,128,128,138","0xF8 0x80 0x80 0x80 0x8A -- overlong representation of U+000A")
	do wbytea("252,128,128,128,128,138","0xFC 0x80 0x80 0x80 0x80 0x8A -- overlong representation of U+000A")
	write ?10,";",!
	;
kuhn	write ?10,";all of the examples from Markus Kuhn's UTF-8-test.txt",!
	write ?10,";http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt",!
	write ?10,"; Section 1 is a valid UTF-8 string, hence not included here",!
kuhn2	write ?10,";2  Boundary condition test cases",!
	write ?10,";",!
	write ?10,";2.1  First possible sequence of a certain length",!
	write ?10,";",!
	write ?10,"; 2.1.2-4 are in unicodesampledata.m since they are valid characters",!
	write ?10,";",!
	;
	; ??? -- move valid ucp's to regular tests, leave only the invalid byte sequences and too long utf8 (5-6) here!
	; in unicodesampledata.m -- do wbytea(0,"2.1.1  1 byte  (U-00000000)")
	; in unicodesampledata.m -- do wbytea("194,128","2.1.2  2 bytes (U-00000080) UTF8: C2 80     UTF8(dec): 194 128")
	; in unicodesampledata.m -- do wbytea("224,160,128","2.1.3  3 bytes (U-00000800) UTF8: E0 A0 80 UTF8(dec): 224 160 128")
	; in unicodesampledata.m -- do wbytea("240,144,128,128","2.1.4  4 bytes (U-00010000) UTF8: F0 90 80 80       UTF8(dec): 240 144 128 128")
	do wbytea("248,136,128,128,128","2.1.5  5 bytes (U-00200000) UTF8: F8 88 80 80 80    UTF8(dec): 248 136 128 128 128")
	do wbytea("252,132,128,128,128,128","2.1.6  6 bytes (U-04000000) UTF8: FC 84 80 80 80 80 UTF8(dec): 252 132 128 128 128 128")
	write ?10,";",!
	write ?10,";2.2  Last possible sequence of a certain length",!
	write ?10,";",!
	write ?10,"; 2.2.1-4 are in unicodesampledata.m since they are valid characters",!
	write ?10,";",!
	; in unicodesampledata.m -- do wbytea(127,"2.2.1  1 byte  (U-0000007F) UTF8: 7F        UTF8(dec): 127")
	; in unicodesampledata.m -- do wbytea("223,191","2.2.2  2 bytes (U-000007FF) UTF8: DF BF     UTF8(dec): 223 191")
	; in unicodesampledata.m -- do wbytea("239,191,191","2.2.3  3 bytes (U-0000FFFF) UTF8: EF BF BF  UTF8(dec): 239 191 191")
	; in unicodesampledata.m -- do wbytea("247,191,191,191","2.2.4  4 bytes (U-001FFFFF) UTF8: F7 BF BF BF       UTF8(dec): 247 191 191 191")
	; the only invalid character in 2.2.4 series
	do wbytea("247,191,191,191","2.2.4  4 bytes (U-001FFFFF) UTF8: F7 BF BFBF       UTF8(dec): 247 191 191 191")
	do wbytea("251,191,191,191,191","2.2.5  5 bytes (U-03FFFFFF) UTF8: FB BF BF BF BF    UTF8(dec): 251 191 191 191 191")
	do wbytea("253,191,191,191,191,191","2.2.6  6 bytes (U-7FFFFFFF) UTF8: FD BF BF BF BF BF UTF8(dec): 253 191 191 191 191 191")
	do wbytea("247,191,191,191","2.2.4  4 bytes (U-001FFFFF) UTF8: F7 BF BFBF       UTF8(dec): 247 191 191 191")
	write ?10,";",!
	write ?10,";2.3  Other boundary conditions",!
	write ?10,"; 2.3.1-4 are in unicodesampledata.m since they are valid characters",!
	write ?10,";",!
	write ?10,";",!
	; in unicodesampledata.m -- do wbytea("237,159,191","2.3.1  U-0000D7FF = UTF8: ED 9F BF  UTF8(dec): 237 159 191")
	; in unicodesampledata.m -- do wbytea("238,128,128","2.3.2  U-0000E000 = UTF8: EE 80 80  UTF8(dec): 238 128 128")
	; in unicodesampledata.m -- do wbytea("239,191,189","2.3.3  U-0000FFFD = UTF8: EF BF BD  UTF8(dec): 239 191 189")
	; in unicodesampledata.m -- do wbytea("244,143,191,191","2.3.4  U-0010FFFF = UTF8: F4 8F BF BF       UTF8(dec): 244 143 191 191")
	do wbytea("244,144,128,128","2.3.5  U-00110000 = UTF8: F4 90 80 80       UTF8(dec): 244 144 128 128")
	write ?10,";",!
kuhn3	write ?10,";3  Malformed sequences",!
	write ?10,";",!
	write ?10,";3.1  Unexpected continuation bytes",!
	write ?10,";",!
	write ?10,";Each unexpected continuation byte should be separately signalled as a",!
	write ?10,";malformed sequence of its own.",!
	write ?10,";",!
	do wbytea(128,"3.1.1  First continuation byte 0x80")
	do wbytea(191,"3.1.2  Last  continuation byte 0xbf")
	write ?10,";",!
	do wbytea("128,191","3.1.3  2 continuation bytes")
	do wbytea("128,191,128","3.1.4  3 continuation bytes")
	do wbytea("128,191,128,191","3.1.5  4 continuation bytes")
	do wbytea("128,191,128,191,128","3.1.6  5 continuation bytes")
	do wbytea("128,191,128,191,128,191","3.1.7  6 continuation bytes")
	do wbytea("128,191,128,191,128,191,128","3.1.8  7 continuation bytes")
	write ?10,";",!
	do wbytea("128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191","3.1.9  Sequence of all 64 possible continuation bytes (0x80-0xbf)")
	write ?10,";",!
	write ?10,";3.2  Lonely start characters",!
	write ?10,";",!
	do wbytea("192,32,193,32,194,32,195,32,196,32,197,32,198,32,199,32,200,32,201,32,202,32,203,32,204,32,205,32,206,32,207,32,208,32,209,32,210,32,211,32,212,32,213,32,214,32,215,32,216,32,217,32,218,32,219,32,220,32,221,32,222,32,223,32","3.2.1.1  All 32 first bytes of 2-byte sequences (0xc0-0xdf), each followed by a space character")
	write ?10,";",!
	do wbytea("224,32,225,32,226,32,227,32,228,32,229,32,230,32,231,32,232,32,233,32,234,32,235,32,236,32,237,32,238,32,239,32","3.2.2  All 16 first bytes of 3-byte sequences (0xe0-0xef), each followed by a space character")
	write ?10,";",!
	do wbytea("240,32,241,32,242,32,243,32,244,32,245,32,246,32,247,32","3.2.3  All 8 first bytes of 4-byte sequences (0xf0-0xf7), each followed by a space character")
	write ?10,";",!
	do wbytea("248,32,249,32,250,32,251,32","3.2.4  All 4 first bytes of 5-byte sequences (0xf8-0xfb), each followed by a space character")
	write ?10,";",!
	do wbytea("252,32,253,32","3.2.5  All 2 first bytes of 6-byte sequences (0xfc-0xfd), each followed by a space character")
	write ?10,";",!
	write ?10,";3.3  Sequences with last continuation byte missing",!
	write ?10,";",!
	write ?10,";All bytes of an incomplete sequence should be signalled as a single",!
	write ?10,";malformed sequence, i.e., you should see only a single replacement",!
	write ?10,";character in each of the next 10 tests. (Characters as in section 2)",!
	write ?10,";!!!!NOTE THAT THE ABOVE IS NOT HOW GT.M WILL BEHAVE!!!!!",!
	write ?10,";",!
	do wbytea("192","3.3.1  2-byte sequence with last byte missing (U+0000)")
	do wbytea("224,128","3.3.2  3-byte sequence with last byte missing (U+0000)")
	do wbytea("240,128,128","3.3.3  4-byte sequence with last byte missing (U+0000)")
	do wbytea("248,128,128,128","3.3.4  5-byte sequence with last byte missing (U+0000)")
	do wbytea("252,128,128,128,128","3.3.5  6-byte sequence with last byte missing (U+0000)")
	do wbytea("223","3.3.6  2-byte sequence with last byte missing (U-000007FF)")
	do wbytea("229,191","3.3.7  3-byte sequence with last byte missing (U-0000FFFF)")
	do wbytea("247,191,191","3.3.8  4-byte sequence with last byte missing (U-001FFFFF)")
	do wbytea("251,191,191,191","3.3.9  5-byte sequence with last byte missing (U-03FFFFFF)")
	do wbytea("253,191,191,191,191","3.3.10 6-byte sequence with last byte missing (U-7FFFFFFF)")
	write ?10,";",!
	write ?10,"; I think there is something fishy in the above examples 3.3.1-3.3.2, I believe the following are the actual intended tests -- Nergis",!
	do wbytea("194","3.3.1a  2-byte sequence with last byte missing (U+0080)")
	do wbytea("224,160","3.3.2a  3-byte sequence with last byte missing (U+0800)")
	do wbytea("240,144,128","3.3.3a  4-byte sequence with last byte missing (U+10000)")
	do wbytea("248,136,128,128","3.3.4a  5-byte sequence with last byte missing (U+200000)")
	do wbytea("252,132,128,128,128","3.3.5a  6-byte sequence with last byte missing (U+04000000)")
	write ?10,";",!
	write ?10,";3.4  Concatenation of incomplete sequences",!
	write ?10,";",!
	do wbytea("192,224,128,240,128,128,248,128,128,128,252,128,128,128,128,223,239,191,247,191,191,251,191,191,191,253,191,191,191,191","3.4 All the 10 sequences of 3.3 concatenated, you should see 30 malformed sequences being signalled in GT.M-- ")
	do wbytea("194,224,160,240,144,128,248,136,128,128,252,132,128,128,128,223,239,191,247,191,191,251,191,191,191,253,191,191,191,191","3.4a All the 10 sequences of 3.3 concatenated, you should see 30 malformed sequences being signalled in GT.M-- ")
	write ?10,";",!
	write ?10,";3.5  Impossible bytes",!
	write ?10,";",!
	write ?10,";The following two bytes cannot appear in a correct UTF-8 string",!
	write ?10,";",!
	do wbytea("254","3.5.1  fe = 254")
	do wbytea("255","3.5.2  ff = 255")
	do wbytea("254,254,255,255","3.5.3  fe fe ff ff = 254 254 255 255")
	write ?10,";",!
kuhn4	write ?10,";4  Overlong sequences",!
	write ?10,";",!
	write ?10,";The following sequences are not malformed according to the letter of",!
	write ?10,";the Unicode 2.0 standard. However, they are longer then necessary and",!
	write ?10,";a correct UTF-8 encoder is not allowed to produce them. A 'safe UTF-8",!
	write ?10,";decoder' should reject them just like malformed sequences for two",!
	write ?10,";reasons: (1) It helps to debug applications if overlong sequences are",!
	write ?10,";not treated as valid representations of characters, because this helps",!
	write ?10,";to spot problems more quickly. (2) Overlong sequences provide",!
	write ?10,";alternative representations of characters, that could maliciously be",!
	write ?10,";used to bypass filters that check only for ASCII characters. For",!
	write ?10,";instance, a 2-byte encoded line feed (LF) would not be caught by a",!
	write ?10,";line counter that counts only 0x0a bytes, but it would still be",!
	write ?10,";processed as a line feed by an unsafe UTF-8 decoder later in the",!
	write ?10,";pipeline. From a security point of view, ASCII compatibility of UTF-8",!
	write ?10,";sequences means also, that ASCII characters are *only* allowed to be",!
	write ?10,";represented by ASCII bytes in the range 0x00-0x7f. To ensure this",!
	write ?10,";aspect of ASCII compatibility, use only 'safe UTF-8 decoders' that",!
	write ?10,";reject overlong UTF-8 sequences for which a shorter encoding exists.",!
	write ?10,";",!
	write ?10,";4.1  Examples of an overlong ASCII character",!
	write ?10,";",!
	write ?10,";With a safe UTF-8 decoder, all of the following five overlong",!
	write ?10,";representations of the ASCII character slash ('/') should be rejected",!
	write ?10,";like a malformed UTF-8 sequence, for instance by substituting it with",!
	write ?10,";a replacement character. If you see a slash below, you do not have a",!
	write ?10,";safe UTF-8 decoder!",!
	write ?10,";",!
	do wbytea("192,175","4.1.1 U+002F = c0 af")
	do wbytea("224,128,175","4.1.2 U+002F = e0 80 af")
	do wbytea("240,128,128,175","4.1.3 U+002F = f0 80 80 af")
	do wbytea("248,128,128,128,175","4.1.4 U+002F = f8 80 80 80 af")
	do wbytea("252,128,128,128,128,175","4.1.5 U+002F = fc 80 80 80 80 af")
	write ?10,";",!
	write ?10,";4.2  Maximum overlong sequences",!
	write ?10,";",!
	write ?10,";Below you see the highest Unicode value that is still resulting in an",!
	write ?10,";overlong sequence if represented with the given number of bytes. This",!
	write ?10,";is a boundary test for safe UTF-8 decoders. All five characters should",!
	write ?10,";be rejected like malformed UTF-8 sequences.",!
	write ?10,";",!
	do wbytea("193,191","4.2.1  U-0000007F = c1 bf")
	do wbytea("224,159,191","4.2.2  U-000007FF = e0 9f bf")
	do wbytea("240,143,191,191","4.2.3  U-0000FFFF = f0 8f bf bf")
	do wbytea("248,135,191,191,191","4.2.4  U-001FFFFF = f8 87 bf bf bf")
	do wbytea("252,131,191,191,191,191","4.2.5  U-03FFFFFF = fc 83 bf bf bf bf")
	write ?10,";",!
	write ?10,";4.3  Overlong representation of the NUL character",!
	write ?10,";",!
	write ?10,";The following five sequences should also be rejected like malformed",!
	write ?10,";UTF-8 sequences and should not be treated like the ASCII NUL",!
	write ?10,";character.",!
	write ?10,";",!
	do wbytea("192,128","4.3.1  U+0000 = c0 80")
	do wbytea("224,128,128","4.3.2  U+0000 = e0 80 80")
	do wbytea("240,128,128,128","4.3.3  U+0000 = f0 80 80 80")
	do wbytea("248,128,128,128,128","4.3.4  U+0000 = f8 80 80 80 80")
	do wbytea("252,128,128,128,128,128","4.3.5  U+0000 = fc 80 80 80 80 80")
	write ?10,";",!
kuhn5	write ?10,";5  Illegal code positions",!
	write ?10,";",!
	write ?10,";The following UTF-8 sequences should be rejected like malformed",!
	write ?10,";sequences, because they never represent valid ISO 10646 characters and",!
	write ?10,";a UTF-8 decoder that accepts them might introduce security problems",!
	write ?10,";comparable to overlong UTF-8 sequences.",!
	write ?10,";",!
	write ?10,";5.1 Single UTF-16 surrogates",!
	write ?10,";",!
	do wbytea("237,160,128","5.1.1  U+D800 = UTF8: ED A0 80  UTF8(dec): 237 160 128")
	do wbytea("237,173,191","5.1.2  U+DB7F = UTF8: ED AD BF  UTF8(dec): 237 173 191")
	do wbytea("237,174,128","5.1.3  U+DB80 = UTF8: ED AE 80  UTF8(dec): 237 174 128")
	do wbytea("237,175,191","5.1.4  U+DBFF = UTF8: ED AF BF  UTF8(dec): 237 175 191")
	do wbytea("237,176,128","5.1.5  U+DC00 = UTF8: ED B0 80  UTF8(dec): 237 176 128")
	do wbytea("237,190,128","5.1.6  U+DF80 = UTF8: ED BE 80  UTF8(dec): 237 190 128")
	do wbytea("237,191,191","5.1.7  U+DFFF = UTF8: ED BF BF  UTF8(dec): 237 191 191")
	write ?10,";",!
	write ?10,";5.2 Paired UTF-16 surrogates",!
	write ?10,";",!
	do wbytea("237,160,128,237,176,128","5.2.1  U+D800 U+DC00 = ed a0 80 ed b0 80")
	do wbytea("237,160,128,237,191,191","5.2.2  U+D800 U+DFFF = ed a0 80 ed bf bf")
	do wbytea("237,173,191,237,176,128","5.2.3  U+DB7F U+DC00 = ed ad bf ed b0 80")
	do wbytea("237,173,191,237,191,191","5.2.4  U+DB7F U+DFFF = ed ad bf ed bf bf")
	do wbytea("237,174,128,237,176,128","5.2.5  U+DB80 U+DC00 = ed ae 80 ed b0 80")
	do wbytea("237,174,128,237,191,191","5.2.6  U+DB80 U+DFFF = ed ae 80 ed bf bf")
	do wbytea("237,175,191,237,176,128","5.2.7  U+DBFF U+DC00 = ed af bf ed b0 80")
	do wbytea("237,175,191,237,191,191","5.2.8  U+DBFF U+DFFF = ed af bf ed bf bf")
	write ?10,";",!
	write ?10,";5.3 Other illegal code positions",!
	write ?10,";",!
	; tmp tmp CLARIFICATION STILL PENDING ON WHETHER THIS IS BADCHAR OR NOT. ALL FUNTIONS FAIL ON THE BELOW TWO SEQUENECE
	;do wbytea("239,191,190","5.3.1  U+FFFE = ef bf be")
	;do wbytea("239,191,191","5.3.2  U+FFFF = ef bf bf")
	write ?10,";",!
	write ?10,";THE END",!
	write ?10,";",!
	write ?10,";",!
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	close file
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wbytea(cx,comm)	; write the actual bytes, i.e. test literals (write "aaa")
	write ?10,"set cnti=cnti+1,str(cnti)=",quote
	set lcx=$LENGTH(cx,",")
	for xi=1:1:lcx write $ZCHAR($PIECE(cx,",",xi));
	write quote,ucpstr,",utf8(cnti)=",quote,cx,quote,",comments(cnti)=",quote,comm,quote,!
	quit
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wbyte(cx,comm)	; alternate wbyte - writes $ZCHAR() statements (write $ZCHAR(nnn))
	write ?10,"set cnti=cnti+1,str(cnti)="
	set lcx=$LENGTH(cx,comma)
	write "$ZCHAR(" for xi=1:1:lcx write $PIECE(cx,comma,xi) if xi<lcx write comma
	write ")"
	write ucpstr,",utf8(cnti)=",quote,cx,quote,",comments(cnti)=",quote,comm,quote,!
	quit
	;

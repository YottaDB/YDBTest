	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
unicodesampledata	;
	; Sample data to test UNICODE strings, includes single-byte and multi-byte strings.
	; There will be multiple arrays defined here for each string, each array is to be used in
	; the tests as reference data.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; the arrays that should be defined for each entry:
	; str(cnti) - the test string
	; ucp -- unicode code point (decimal), comma delimited    - $ASCII() values for all characters of str(cnti) if $ZCHSET="UTF-8"
	; utf8 -- UTF-8 representation (decimal), comma delimited - $ZASCII() values for all characters of str(cnti)
	; comments(cnti) - (optional) arbitrary comments to describe the str
	;
	; Note that the code should use $GET(comments(cnti)) where necessary because the comments() array is optional
	;
	; There will be 3 derived arrays for each entry:
	; ucplen --  derived from the number of elements of ucp(str)  -- $LENGTH(str(cnti)) if $ZCHSET="UTF-8"
	; utf8len -- derived from the number of elements of utf8(str) -- $ZLENGTH(str(cnti))
	; width(cnti) - shows (for printable strings) the width of the string -- what $ZWIDTH(str(cnti)) should return if $ZCHSET="UTF-8".
	;
	; All the derived arrays can also be overriden at the point of specification. In that case, the value in the specification will be used.
	;
	; maxucplen, maxutf8len, and maxwidth hold the maximum length of all strings (i.e. max(ucplen()), max(utf8len()),
	; and max(width()) respectively)
	;
	; These can be derived from the ucp(cnti) and utf8(cnti) values, since they are comma delimited
	; strings where the respective number of elements are ucplen(str) and utf8len(str).
	;
	; cntstr is the total number of samples in the sample set.
	;
	; If badcharsamples is defined and zero, BADCHAR samples will not be defined.
	; If BADCHAR samples are defined, cntstrbadchars and cntstrbadchare will show the start and end points
	; of the BADCHAR section.
	;
	; The entrypoint global^unicodesampledata will define all of the values in globals as well.
	;
	; There are some entrypoints (and some aliases) that are useful for debugging now:
	; x l 	  --> will re-link
	; x u 	  --> will re-run
	; x ps 	  --> will print a "box" of all the printable elements of str(), with their comments
	; x p 	  --> will print all elements of all arrays
	; x k 	  --> will kill all (local) data defined in this routine
	; x putf8 --> will p(rint) the utf8 values for the range (see the entrypoint for details)
	; x check --> will check the data (very much incomplete check)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ex:
	; set str(cnti)="ab",ucp(cnti)="97,98",utf8(cnti)="97,98",comments(cnti)="just an a and a b",cnt=cnt+1
	;
init	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	new cnti
	set cnti=0
	; varsdefined is only used in the entry-point "global", to list the local variables that are defined in this routine
	; to help in getting the list for the global definitions.
	; some ofthe variables here are the key in which specific functions operate. Not all the logic defined in all the functions can operate for all
	; the ^str defined here. Some of them will require only mutlibyte char string and some non-repetitve char string etc.
	; to satisfy those requests we have these variables defined that can be used as entry and exit points for a piece of logic.
	set varsdefined="str,ucp,utf8,comments,ucplen,utf8len,width,maxucplen,maxutf8len,maxwidth,cntstr,cntstrbadchars,cntstrbadchare,cntstrsentinelss,cntstrsentinelse,cntstrmbytes,cntstrmbytee,cntstrfinds,cntstrfinde,cntstrnumerics,cntstrnumerice"
set 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ASCII
	set cnti=cnti+1,str(cnti)="x",ucp(cnti)="120",utf8(cnti)="120",comments(cnti)="just an x"
	set cnti=cnti+1,str(cnti)="ab",ucp(cnti)="97,98",utf8(cnti)="97,98",comments(cnti)="just an a and a b"
	set cnti=cnti+1,str(cnti)="!""#$%&'()*+,-./0",ucp(cnti)="33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48",utf8(cnti)=ucp(cnti),comments(cnti)="$CHAR(33-48)"
	set cnti=cnti+1,str(cnti)="123456789:;<=>?@",ucp(cnti)="49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64",utf8(cnti)=ucp(cnti),comments(cnti)="$CHAR(49-64)"
	set cnti=cnti+1,str(cnti)="ABCDEFGHIJKLMNOP",ucp(cnti)="65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80",utf8(cnti)=ucp(cnti),comments(cnti)="$CHAR(65-80)"
	set cnti=cnti+1,str(cnti)="QRS TUVWXYZ[\]^_`",ucp(cnti)="81,82,83,32,84,85,86,87,88,89,90,91,92,93,94,95,96",utf8(cnti)=ucp(cnti),comments(cnti)="$CHAR(81-96)"
	set cnti=cnti+1,str(cnti)="abcdefghijklmnop",ucp(cnti)="97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112",utf8(cnti)=ucp(cnti),comments(cnti)="$CHAR(97-112)"
	set cnti=cnti+1,str(cnti)="qrstuvwxyz{|}~",ucp(cnti)="113,114,115,116,117,118,119,120,121,122,123,124,125,126",utf8(cnti)=ucp(cnti),comments(cnti)="$CHAR(113-126)"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="-1",ucplen(cnti)=0,utf8(cnti)="-1",utf8len(cnti)=0,comments(cnti)="null string",width(cnti)=0
	;
	; ASCII control characters
	set cnti=cnti+1,str(cnti)=$CHAR(0,1,2,3,4,5,6,7,8,9),ucp(cnti)="0,1,2,3,4,5,6,7,8,9",utf8(cnti)=ucp(cnti),comments(cnti)="control characters $CHAR(0-9)",width(cnti)=-1
	set cnti=cnti+1,str(cnti)=$CHAR(10,11,12,13,14,15,16,17,18,19),ucp(cnti)="10,11,12,13,14,15,16,17,18,19",utf8(cnti)=ucp(cnti),comments(cnti)="control characters $CHAR(10-19)",width(cnti)=-1
	set cnti=cnti+1,str(cnti)=$CHAR(20,21,22,23,24,25,26,27,28,29),ucp(cnti)="20,21,22,23,24,25,26,27,28,29",utf8(cnti)=ucp(cnti),comments(cnti)="control characters $CHAR(20-29)",width(cnti)=-1
	set cnti=cnti+1,str(cnti)=$CHAR(30,31,127),ucp(cnti)="30,31,127",utf8(cnti)=ucp(cnti),comments(cnti)="control characters $CHAR(30-31,127)",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,32,97",utf8(cnti)="97,32,97",comments(cnti)="SPACE"
        set cnti=cnti+1,str(cnti)=$ZCHAR(0),ucp(cnti)="0",width(cnti)=-1,utf8(cnti)="0",comments(cnti)="2.1.1  1 byte  (U-00000000)"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="127",width(cnti)=-1,utf8(cnti)="127",comments(cnti)="2.2.1  1 byte  (U-0000007F) UTF8: 7F        UTF8(dec): 127"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Latin-1 supplement (U+0080-U+00FF)
	; Latin-1 supplement printable characters
	set cntstrmbytes=cnti+1	; multibyte characters start 
	set cnti=cnti+1,str(cnti)="Ş",ucp(cnti)="350",utf8(cnti)="197,158",comments(cnti)="a single 2-byte character"
	set cnti=cnti+1,str(cnti)="aÂb",ucp(cnti)="97,194,98",utf8(cnti)="97,195,130,98",comments(cnti)="a single 2-byte character single byte characters"
	set cnti=cnti+1,str(cnti)=" ¡¢£¤¥¦§¨©ª«¬­®¯",ucp(cnti)="160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175",comments(cnti)="$CHAR(160-175)"
	set utf8(cnti)="194,160,194,161,194,162,194,163,194,164,194,165,194,166,194,167,194,168,194,169,194,170,194,171,194,172,194,173,194,174,194,175"
	set cnti=cnti+1,str(cnti)="°±²³´µ¶·¸¹º»¼½¾¿",ucp(cnti)="176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191",comments(cnti)="$CHAR(176-191)"
	set utf8(cnti)="194,176,194,177,194,178,194,179,194,180,194,181,194,182,194,183,194,184,194,185,194,186,194,187,194,188,194,189,194,190,194,191"
	set cnti=cnti+1,str(cnti)="ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏ",ucp(cnti)="192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207",comments(cnti)="$CHAR(192-207)"
	set utf8(cnti)="195,128,195,129,195,130,195,131,195,132,195,133,195,134,195,135,195,136,195,137,195,138,195,139,195,140,195,141,195,142,195,143"
	set cnti=cnti+1,str(cnti)="ÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß",ucp(cnti)="208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223",comments(cnti)="$CHAR(208-223)"
	set utf8(cnti)="195,144,195,145,195,146,195,147,195,148,195,149,195,150,195,151,195,152,195,153,195,154,195,155,195,156,195,157,195,158,195,159"
	set cnti=cnti+1,str(cnti)="àáâãäåæçèéêëìíîï",ucp(cnti)="224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239",comments(cnti)="$CHAR(224-239)"
	set utf8(cnti)="195,160,195,161,195,162,195,163,195,164,195,165,195,166,195,167,195,168,195,169,195,170,195,171,195,172,195,173,195,174,195,175"
	set cnti=cnti+1,str(cnti)="ðñòóôõö÷øùúûüýþÿ",ucp(cnti)="240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255",comments(cnti)="$CHAR(240-255)"
	set utf8(cnti)="195,176,195,177,195,178,195,179,195,180,195,181,195,182,195,183,195,184,195,185,195,186,195,187,195,188,195,189,195,190,195,191"
	;
	; Latin-1 supplement control characters
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="128,129,130,131,132,133,134,135",comments(cnti)="$CHAR(128-135)",width(cnti)=-1
	set utf8(cnti)="194,128,194,129,194,130,194,131,194,132,194,133,194,134,194,135"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="136,137,138,139,140,141,142,143",comments(cnti)="$CHAR(136-143)",width(cnti)=-1
	set utf8(cnti)="194,136,194,137,194,138,194,139,194,140,194,141,194,142,194,143"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="144,145,146,147,148,149,150,151",comments(cnti)="$CHAR(144-151)",width(cnti)=-1
	set utf8(cnti)="194,144,194,145,194,146,194,147,194,148,194,149,194,150,194,151"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="152,153,154,155,156,157,158,159",comments(cnti)="$CHAR(152-159)",width(cnti)=-1
	set utf8(cnti)="194,152,194,153,194,154,194,155,194,156,194,157,194,158,194,159"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; other graphical multi-byte characters
	;
	; spaces
	;Here are (many of) the different spaces in Unicode:
	;U+0020;SPACE ; this will be present in the ASCII section atop of this routine just to group all single byte character strings together
	;U+00A0;NO-BREAK SPACE
	;U+2002;EN SPACE
	;U+2003;EM SPACE
	;U+2004;THREE-PER-EM SPACE
	;U+2005;FOUR-PER-EM SPACE
	;U+2006;SIX-PER-EM SPACE
	;U+2007;FIGURE SPACE
	;U+2008;PUNCTUATION SPACE
	;U+2009;THIN SPACE
	;U+200A;HAIR SPACE
	;U+200B;ZERO WIDTH SPACE
	;U+202F;NARROW NO-BREAK SPACE
	;U+205F;MEDIUM MATHEMATICAL SPACE
	;U+3000;IDEOGRAPHIC SPACE
	;U+303F;IDEOGRAPHIC HALF FILL SPACE
	;U+FEFF;ZERO WIDTH NO-BREAK SPACE; BYTE ORDER MARK
	;U+E0020;TAG SPACE
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,160,97",utf8(cnti)="97,194,160,97",comments(cnti)="NO-BREAK SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8194,97",utf8(cnti)="97,226,128,130,97",comments(cnti)="EN SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8195,97",utf8(cnti)="97,226,128,131,97",comments(cnti)="EM SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8196,97",utf8(cnti)="97,226,128,132,97",comments(cnti)="THREE-PER-EM SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8197,97",utf8(cnti)="97,226,128,133,97",comments(cnti)="FOUR-PER-EM SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8198,97",utf8(cnti)="97,226,128,134,97",comments(cnti)="SIX-PER-EM SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8199,97",utf8(cnti)="97,226,128,135,97",comments(cnti)="FIGURE SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8200,97",utf8(cnti)="97,226,128,136,97",comments(cnti)="PUNCTUATION SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8201,97",utf8(cnti)="97,226,128,137,97",comments(cnti)="THIN SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8202,97",utf8(cnti)="97,226,128,138,97",comments(cnti)="HAIR SPACE"
	set cnti=cnti+1,str(cnti)="a​a",ucp(cnti)="97,8203,97",utf8(cnti)="97,226,128,139,97",width(cnti)=2,comments(cnti)="ZERO WIDTH SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8239,97",utf8(cnti)="97,226,128,175,97",comments(cnti)="NARROW NO-BREAK SPACE"
	set cnti=cnti+1,str(cnti)="a a",ucp(cnti)="97,8287,97",utf8(cnti)="97,226,129,159,97",comments(cnti)="MEDIUM MATHEMATICAL SPACE"
	set cnti=cnti+1,str(cnti)="a　a",ucp(cnti)="97,12288,97",utf8(cnti)="97,227,128,128,97",width(cnti)=4,comments(cnti)="IDEOGRAPHIC SPACE"
	set cnti=cnti+1,str(cnti)="a〿a",ucp(cnti)="97,12351,97",utf8(cnti)="97,227,128,191,97",comments(cnti)="IDEOGRAPHIC HALF FILL SPACE"
	set cnti=cnti+1,str(cnti)="a﻿a",ucp(cnti)="97,65279,97",utf8(cnti)="97,239,187,191,97",width(cnti)=2,comments(cnti)="ZERO WIDTH NO-BREAK SPACE; BYTE ORDER MARK"
	set cnti=cnti+1,str(cnti)="a󠀠a",ucp(cnti)="97,917536,97",utf8(cnti)="97,243,160,128,160,97",comments(cnti)="TAG SPACE",width(cnti)=2
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Latin Extended A (U+100-U+17FF)
	set cnti=cnti+1,str(cnti)="ĀāĂăĄąĆćĈĉĊċČčĎď",ucp(cnti)="256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271",comments(cnti)="$CHAR(256-271)"
	set utf8(cnti)="196,128,196,129,196,130,196,131,196,132,196,133,196,134,196,135,196,136,196,137,196,138,196,139,196,140,196,141,196,142,196,143"
	set cnti=cnti+1,str(cnti)="ĐđĒēĔĕĖėĘęĚěĜĝĞğ",ucp(cnti)="272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287",comments(cnti)="$CHAR(272-287)"
	set utf8(cnti)="196,144,196,145,196,146,196,147,196,148,196,149,196,150,196,151,196,152,196,153,196,154,196,155,196,156,196,157,196,158,196,159"
	set cnti=cnti+1,str(cnti)="ĠġĢģĤĥĦħĨĩĪīĬĭĮį",ucp(cnti)="288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303",comments(cnti)="$CHAR(288-303)"
	set utf8(cnti)="196,160,196,161,196,162,196,163,196,164,196,165,196,166,196,167,196,168,196,169,196,170,196,171,196,172,196,173,196,174,196,175"
	set cnti=cnti+1,str(cnti)="İıĲĳĴĵĶķĸĹĺĻļĽľĿ",ucp(cnti)="304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319",comments(cnti)="$CHAR(304-319)"
	set utf8(cnti)="196,176,196,177,196,178,196,179,196,180,196,181,196,182,196,183,196,184,196,185,196,186,196,187,196,188,196,189,196,190,196,191"
	set cnti=cnti+1,str(cnti)="ŀŁłŃńŅņŇňŉŊŋŌōŎŏ",ucp(cnti)="320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335",comments(cnti)="$CHAR(320-335)"
	set utf8(cnti)="197,128,197,129,197,130,197,131,197,132,197,133,197,134,197,135,197,136,197,137,197,138,197,139,197,140,197,141,197,142,197,143"
	set cnti=cnti+1,str(cnti)="ŐőŒœŔŕŖŗŘřŚśŜŝŞş",ucp(cnti)="336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351",comments(cnti)="$CHAR(336-351)"
	set utf8(cnti)="197,144,197,145,197,146,197,147,197,148,197,149,197,150,197,151,197,152,197,153,197,154,197,155,197,156,197,157,197,158,197,159"
	set cnti=cnti+1,str(cnti)="ŠšŢţŤťŦŧŨũŪūŬŭŮů",ucp(cnti)="352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367",comments(cnti)="$CHAR(352-367)"
	set utf8(cnti)="197,160,197,161,197,162,197,163,197,164,197,165,197,166,197,167,197,168,197,169,197,170,197,171,197,172,197,173,197,174,197,175"
	set cnti=cnti+1,str(cnti)="ŰűŲųŴŵŶŷŸŹźŻżŽžſ",ucp(cnti)="368,369,370,371,372,373,374,375,376,377,378,379,380,381,382,383",comments(cnti)="$CHAR(368-383)"
	set utf8(cnti)="197,176,197,177,197,178,197,179,197,180,197,181,197,182,197,183,197,184,197,185,197,186,197,187,197,188,197,189,197,190,197,191"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Latin Extended B (U+0180-U+024F)
	set cnti=cnti+1,str(cnti)="ƀƁƂƃƄƅƆƇƈƉƊƋƌƍƎƏ",ucp(cnti)="384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399",comments(cnti)="$CHAR(384-399)"
	set utf8(cnti)="198,128,198,129,198,130,198,131,198,132,198,133,198,134,198,135,198,136,198,137,198,138,198,139,198,140,198,141,198,142,198,143"
	set cnti=cnti+1,str(cnti)="ƐƑƒƓƔƕƖƗƘƙƚƛƜƝƞƟ",ucp(cnti)="400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415",comments(cnti)="$CHAR(400-415)"
	set utf8(cnti)="198,144,198,145,198,146,198,147,198,148,198,149,198,150,198,151,198,152,198,153,198,154,198,155,198,156,198,157,198,158,198,159"
	set cnti=cnti+1,str(cnti)="ƠơƢƣƤƥƦƧƨƩƪƫƬƭƮƯ",ucp(cnti)="416,417,418,419,420,421,422,423,424,425,426,427,428,429,430,431",comments(cnti)="$CHAR(416-431)"
	set utf8(cnti)="198,160,198,161,198,162,198,163,198,164,198,165,198,166,198,167,198,168,198,169,198,170,198,171,198,172,198,173,198,174,198,175"
	set cnti=cnti+1,str(cnti)="ưƱƲƳƴƵƶƷƸƹƺƻƼƽƾƿ",ucp(cnti)="432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447",comments(cnti)="$CHAR(432-447)"
	set utf8(cnti)="198,176,198,177,198,178,198,179,198,180,198,181,198,182,198,183,198,184,198,185,198,186,198,187,198,188,198,189,198,190,198,191"
	set cnti=cnti+1,str(cnti)="ǀǁǂǃǄǅǆǇǈǉǊǋǌǍǎǏ",ucp(cnti)="448,449,450,451,452,453,454,455,456,457,458,459,460,461,462,463",comments(cnti)="$CHAR(448-463)"
	set utf8(cnti)="199,128,199,129,199,130,199,131,199,132,199,133,199,134,199,135,199,136,199,137,199,138,199,139,199,140,199,141,199,142,199,143"
	set cnti=cnti+1,str(cnti)="ǐǑǒǓǔǕǖǗǘǙǚǛǜǝǞǟ",ucp(cnti)="464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479",comments(cnti)="$CHAR(464-479)"
	set utf8(cnti)="199,144,199,145,199,146,199,147,199,148,199,149,199,150,199,151,199,152,199,153,199,154,199,155,199,156,199,157,199,158,199,159"
	set cnti=cnti+1,str(cnti)="ǠǡǢǣǤǥǦǧǨǩǪǫǬǭǮǯ",ucp(cnti)="480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495",comments(cnti)="$CHAR(480-495)"
	set utf8(cnti)="199,160,199,161,199,162,199,163,199,164,199,165,199,166,199,167,199,168,199,169,199,170,199,171,199,172,199,173,199,174,199,175"
	set cnti=cnti+1,str(cnti)="ǰǱǲǳǴǵǶǷǸǹǺǻǼǽǾǿ",ucp(cnti)="496,497,498,499,500,501,502,503,504,505,506,507,508,509,510,511",comments(cnti)="$CHAR(496-511)"
	set utf8(cnti)="199,176,199,177,199,178,199,179,199,180,199,181,199,182,199,183,199,184,199,185,199,186,199,187,199,188,199,189,199,190,199,191"
	set cnti=cnti+1,str(cnti)="ȀȁȂȃȄȅȆȇȈȉȊȋȌȍȎȏ",ucp(cnti)="512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527",comments(cnti)="$CHAR(512-527)"
	set utf8(cnti)="200,128,200,129,200,130,200,131,200,132,200,133,200,134,200,135,200,136,200,137,200,138,200,139,200,140,200,141,200,142,200,143"
	set cnti=cnti+1,str(cnti)="ȐȑȒȓȔȕȖȗȘșȚțȜȝȞȟ",ucp(cnti)="528,529,530,531,532,533,534,535,536,537,538,539,540,541,542,543",comments(cnti)="$CHAR(528-543)"
	set utf8(cnti)="200,144,200,145,200,146,200,147,200,148,200,149,200,150,200,151,200,152,200,153,200,154,200,155,200,156,200,157,200,158,200,159"
	set cnti=cnti+1,str(cnti)="ȠȡȢȣȤȥȦȧȨȩȪȫȬȭȮȯ",ucp(cnti)="544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559",comments(cnti)="$CHAR(544-559)"
	set utf8(cnti)="200,160,200,161,200,162,200,163,200,164,200,165,200,166,200,167,200,168,200,169,200,170,200,171,200,172,200,173,200,174,200,175"
	set cnti=cnti+1,str(cnti)="ȰȱȲȳȴȵȶȷȸȹȺȻȼȽȾȿ",ucp(cnti)="560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575",comments(cnti)="$CHAR(560-575)"
	set utf8(cnti)="200,176,200,177,200,178,200,179,200,180,200,181,200,182,200,183,200,184,200,185,200,186,200,187,200,188,200,189,200,190,200,191"
	set cnti=cnti+1,str(cnti)="ɀɁɂɃɄɅɆɇɈɉɊɋɌɍɎɏ",ucp(cnti)="576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591",comments(cnti)="$CHAR(576-591) (U+0242-U+024F)"
	set utf8(cnti)="201,128,201,129,201,130,201,131,201,132,201,133,201,134,201,135,201,136,201,137,201,138,201,139,201,140,201,141,201,142,201,143"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Latin Extended Additional (U+1E00-U+1EFF)
	set cnti=cnti+1,str(cnti)="ḀḁḂḃḄḅḆḇ",ucp(cnti)="7680,7681,7682,7683,7684,7685,7686,7687",comments(cnti)="$CHAR(7680-7687)"
	set utf8(cnti)="225,184,128,225,184,129,225,184,130,225,184,131,225,184,132,225,184,133,225,184,134,225,184,135"
	set cnti=cnti+1,str(cnti)="ḈḉḊḋḌḍḎḏ",ucp(cnti)="7688,7689,7690,7691,7692,7693,7694,7695",comments(cnti)="$CHAR(7688-7695)"
	set utf8(cnti)="225,184,136,225,184,137,225,184,138,225,184,139,225,184,140,225,184,141,225,184,142,225,184,143"
	set cnti=cnti+1,str(cnti)="ḐḑḒḓḔḕḖḗ",ucp(cnti)="7696,7697,7698,7699,7700,7701,7702,7703",comments(cnti)="$CHAR(7696-7703)"
	set utf8(cnti)="225,184,144,225,184,145,225,184,146,225,184,147,225,184,148,225,184,149,225,184,150,225,184,151"
	set cnti=cnti+1,str(cnti)="ḘḙḚḛḜḝḞḟ",ucp(cnti)="7704,7705,7706,7707,7708,7709,7710,7711",comments(cnti)="$CHAR(7704-7711)"
	set utf8(cnti)="225,184,152,225,184,153,225,184,154,225,184,155,225,184,156,225,184,157,225,184,158,225,184,159"
	set cnti=cnti+1,str(cnti)="ḠḡḢḣḤḥḦḧ",ucp(cnti)="7712,7713,7714,7715,7716,7717,7718,7719",comments(cnti)="$CHAR(7712-7719)"
	set utf8(cnti)="225,184,160,225,184,161,225,184,162,225,184,163,225,184,164,225,184,165,225,184,166,225,184,167"
	set cnti=cnti+1,str(cnti)="ḨḩḪḫḬḭḮḯ",ucp(cnti)="7720,7721,7722,7723,7724,7725,7726,7727",comments(cnti)="$CHAR(7720-7727)"
	set utf8(cnti)="225,184,168,225,184,169,225,184,170,225,184,171,225,184,172,225,184,173,225,184,174,225,184,175"
	set cnti=cnti+1,str(cnti)="ḰḱḲḳḴḵḶḷ",ucp(cnti)="7728,7729,7730,7731,7732,7733,7734,7735",comments(cnti)="$CHAR(7728-7735)"
	set utf8(cnti)="225,184,176,225,184,177,225,184,178,225,184,179,225,184,180,225,184,181,225,184,182,225,184,183"
	set cnti=cnti+1,str(cnti)="ḸḹḺḻḼḽḾḿ",ucp(cnti)="7736,7737,7738,7739,7740,7741,7742,7743",comments(cnti)="$CHAR(7736-7743)"
	set utf8(cnti)="225,184,184,225,184,185,225,184,186,225,184,187,225,184,188,225,184,189,225,184,190,225,184,191"
	set cnti=cnti+1,str(cnti)="ṀṁṂṃṄṅṆṇ",ucp(cnti)="7744,7745,7746,7747,7748,7749,7750,7751",comments(cnti)="$CHAR(7744-7751)"
	set utf8(cnti)="225,185,128,225,185,129,225,185,130,225,185,131,225,185,132,225,185,133,225,185,134,225,185,135"
	set cnti=cnti+1,str(cnti)="ṈṉṊṋṌṍṎṏ",ucp(cnti)="7752,7753,7754,7755,7756,7757,7758,7759",comments(cnti)="$CHAR(7752-7759)"
	set utf8(cnti)="225,185,136,225,185,137,225,185,138,225,185,139,225,185,140,225,185,141,225,185,142,225,185,143"
	set cnti=cnti+1,str(cnti)="ṐṑṒṓṔṕṖṗ",ucp(cnti)="7760,7761,7762,7763,7764,7765,7766,7767",comments(cnti)="$CHAR(7760-7767)"
	set utf8(cnti)="225,185,144,225,185,145,225,185,146,225,185,147,225,185,148,225,185,149,225,185,150,225,185,151"
	set cnti=cnti+1,str(cnti)="ṘṙṚṛṜṝṞṟ",ucp(cnti)="7768,7769,7770,7771,7772,7773,7774,7775",comments(cnti)="$CHAR(7768-7775)"
	set utf8(cnti)="225,185,152,225,185,153,225,185,154,225,185,155,225,185,156,225,185,157,225,185,158,225,185,159"
	set cnti=cnti+1,str(cnti)="ṠṡṢṣṤṥṦṧ",ucp(cnti)="7776,7777,7778,7779,7780,7781,7782,7783",comments(cnti)="$CHAR(7776-7783)"
	set utf8(cnti)="225,185,160,225,185,161,225,185,162,225,185,163,225,185,164,225,185,165,225,185,166,225,185,167"
	set cnti=cnti+1,str(cnti)="ṨṩṪṫṬṭṮṯ",ucp(cnti)="7784,7785,7786,7787,7788,7789,7790,7791",comments(cnti)="$CHAR(7784-7791)"
	set utf8(cnti)="225,185,168,225,185,169,225,185,170,225,185,171,225,185,172,225,185,173,225,185,174,225,185,175"
	set cnti=cnti+1,str(cnti)="ṰṱṲṳṴṵṶṷ",ucp(cnti)="7792,7793,7794,7795,7796,7797,7798,7799",comments(cnti)="$CHAR(7792-7799)"
	set utf8(cnti)="225,185,176,225,185,177,225,185,178,225,185,179,225,185,180,225,185,181,225,185,182,225,185,183"
	set cnti=cnti+1,str(cnti)="ṸṹṺṻṼṽṾṿ",ucp(cnti)="7800,7801,7802,7803,7804,7805,7806,7807",comments(cnti)="$CHAR(7800-7807)"
	set utf8(cnti)="225,185,184,225,185,185,225,185,186,225,185,187,225,185,188,225,185,189,225,185,190,225,185,191"
	set cnti=cnti+1,str(cnti)="ẀẁẂẃẄẅẆẇ",ucp(cnti)="7808,7809,7810,7811,7812,7813,7814,7815",comments(cnti)="$CHAR(7808-7815)"
	set utf8(cnti)="225,186,128,225,186,129,225,186,130,225,186,131,225,186,132,225,186,133,225,186,134,225,186,135"
	set cnti=cnti+1,str(cnti)="ẈẉẊẋẌẍẎẏ",ucp(cnti)="7816,7817,7818,7819,7820,7821,7822,7823",comments(cnti)="$CHAR(7816-7823)"
	set utf8(cnti)="225,186,136,225,186,137,225,186,138,225,186,139,225,186,140,225,186,141,225,186,142,225,186,143"
	set cnti=cnti+1,str(cnti)="ẐẑẒẓẔẕẖẗ",ucp(cnti)="7824,7825,7826,7827,7828,7829,7830,7831",comments(cnti)="$CHAR(7824-7831)"
	set utf8(cnti)="225,186,144,225,186,145,225,186,146,225,186,147,225,186,148,225,186,149,225,186,150,225,186,151"
	set cnti=cnti+1,str(cnti)="ẘẙẚẛ",ucp(cnti)="7832,7833,7834,7835",comments(cnti)="$CHAR(7832-7835)"
	set utf8(cnti)="225,186,152,225,186,153,225,186,154,225,186,155"
	set cnti=cnti+1,str(cnti)="ẠạẢảẤấẦầ",ucp(cnti)="7840,7841,7842,7843,7844,7845,7846,7847",comments(cnti)="$CHAR(7840-7847)"
	set utf8(cnti)="225,186,160,225,186,161,225,186,162,225,186,163,225,186,164,225,186,165,225,186,166,225,186,167"
	set cnti=cnti+1,str(cnti)="ẨẩẪẫẬậẮắ",ucp(cnti)="7848,7849,7850,7851,7852,7853,7854,7855",comments(cnti)="$CHAR(7848-7855)"
	set utf8(cnti)="225,186,168,225,186,169,225,186,170,225,186,171,225,186,172,225,186,173,225,186,174,225,186,175"
	set cnti=cnti+1,str(cnti)="ẰằẲẳẴẵẶặ",ucp(cnti)="7856,7857,7858,7859,7860,7861,7862,7863",comments(cnti)="$CHAR(7856-7863)"
	set utf8(cnti)="225,186,176,225,186,177,225,186,178,225,186,179,225,186,180,225,186,181,225,186,182,225,186,183"
	set cnti=cnti+1,str(cnti)="ẸẹẺẻẼẽẾế",ucp(cnti)="7864,7865,7866,7867,7868,7869,7870,7871",comments(cnti)="$CHAR(7864-7871)"
	set utf8(cnti)="225,186,184,225,186,185,225,186,186,225,186,187,225,186,188,225,186,189,225,186,190,225,186,191"
	set cnti=cnti+1,str(cnti)="ỀềỂểỄễỆệ",ucp(cnti)="7872,7873,7874,7875,7876,7877,7878,7879",comments(cnti)="$CHAR(7872-7879)"
	set utf8(cnti)="225,187,128,225,187,129,225,187,130,225,187,131,225,187,132,225,187,133,225,187,134,225,187,135"
	set cnti=cnti+1,str(cnti)="ỈỉỊịỌọỎỏ",ucp(cnti)="7880,7881,7882,7883,7884,7885,7886,7887",comments(cnti)="$CHAR(7880-7887)"
	set utf8(cnti)="225,187,136,225,187,137,225,187,138,225,187,139,225,187,140,225,187,141,225,187,142,225,187,143"
	set cnti=cnti+1,str(cnti)="ỐốỒồỔổỖỗ",ucp(cnti)="7888,7889,7890,7891,7892,7893,7894,7895",comments(cnti)="$CHAR(7888-7895)"
	set utf8(cnti)="225,187,144,225,187,145,225,187,146,225,187,147,225,187,148,225,187,149,225,187,150,225,187,151"
	set cnti=cnti+1,str(cnti)="ỘộỚớỜờỞở",ucp(cnti)="7896,7897,7898,7899,7900,7901,7902,7903",comments(cnti)="$CHAR(7896-7903)"
	set utf8(cnti)="225,187,152,225,187,153,225,187,154,225,187,155,225,187,156,225,187,157,225,187,158,225,187,159"
	set cnti=cnti+1,str(cnti)="ỠỡỢợỤụỦủ",ucp(cnti)="7904,7905,7906,7907,7908,7909,7910,7911",comments(cnti)="$CHAR(7904-7911)"
	set utf8(cnti)="225,187,160,225,187,161,225,187,162,225,187,163,225,187,164,225,187,165,225,187,166,225,187,167"
	set cnti=cnti+1,str(cnti)="ỨứỪừỬửỮữ",ucp(cnti)="7912,7913,7914,7915,7916,7917,7918,7919",comments(cnti)="$CHAR(7912-7919)"
	set utf8(cnti)="225,187,168,225,187,169,225,187,170,225,187,171,225,187,172,225,187,173,225,187,174,225,187,175"
	set cnti=cnti+1,str(cnti)="ỰựỲỳỴỵỶỷ",ucp(cnti)="7920,7921,7922,7923,7924,7925,7926,7927",comments(cnti)="$CHAR(7920-7927)"
	set utf8(cnti)="225,187,176,225,187,177,225,187,178,225,187,179,225,187,180,225,187,181,225,187,182,225,187,183"
	set cnti=cnti+1,str(cnti)="ỸỹỺỻỼỽỾỿ",ucp(cnti)="7928,7929,7930,7931,7932,7933,7934,7935",comments(cnti)="$CHAR(7928-7935)"
	set utf8(cnti)="225,187,184,225,187,185,225,187,186,225,187,187,225,187,188,225,187,189,225,187,190,225,187,191",width(cnti)=-1 ;width=-1 because only the first two characters are valid unicode char in the string
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Fullwidth Characters (U+FF00-U+FF5E)
	; width is twice the ASCII characters
	set cntstrfinds=cnti+1
	set cnti=cnti+1,str(cnti)="！＂＃＄％＆＇",ucp(cnti)="65281,65282,65283,65284,65285,65286,65287",width(cnti)=14,comments(cnti)="full width $CHAR(65280-65287)"
	set utf8(cnti)="239,188,129,239,188,130,239,188,131,239,188,132,239,188,133,239,188,134,239,188,135"
	set cnti=cnti+1,str(cnti)="（）＊＋，－．／",ucp(cnti)="65288,65289,65290,65291,65292,65293,65294,65295",width(cnti)=16,comments(cnti)="full width $CHAR(65288-65295)"
	set utf8(cnti)="239,188,136,239,188,137,239,188,138,239,188,139,239,188,140,239,188,141,239,188,142,239,188,143"
	set cnti=cnti+1,str(cnti)="０１２３４５６７",ucp(cnti)="65296,65297,65298,65299,65300,65301,65302,65303",width(cnti)=16,comments(cnti)="full width $CHAR(65296-65303)"
	set utf8(cnti)="239,188,144,239,188,145,239,188,146,239,188,147,239,188,148,239,188,149,239,188,150,239,188,151"
	set cnti=cnti+1,str(cnti)="８９：；＜＝＞？",ucp(cnti)="65304,65305,65306,65307,65308,65309,65310,65311",width(cnti)=16,comments(cnti)="full width $CHAR(65304-65311)"
	set utf8(cnti)="239,188,152,239,188,153,239,188,154,239,188,155,239,188,156,239,188,157,239,188,158,239,188,159"
	set cnti=cnti+1,str(cnti)="＠ＡＢＣＤＥＦＧ",ucp(cnti)="65312,65313,65314,65315,65316,65317,65318,65319",width(cnti)=16,comments(cnti)="full width $CHAR(65312-65319)"
	set utf8(cnti)="239,188,160,239,188,161,239,188,162,239,188,163,239,188,164,239,188,165,239,188,166,239,188,167"
	set cnti=cnti+1,str(cnti)="ＨＩＪＫＬＭＮＯ",ucp(cnti)="65320,65321,65322,65323,65324,65325,65326,65327",width(cnti)=16,comments(cnti)="full width $CHAR(65320-65327)"
	set utf8(cnti)="239,188,168,239,188,169,239,188,170,239,188,171,239,188,172,239,188,173,239,188,174,239,188,175"
	set cnti=cnti+1,str(cnti)="ＰＱＲＳＴＵＶＷ",ucp(cnti)="65328,65329,65330,65331,65332,65333,65334,65335",width(cnti)=16,comments(cnti)="full width $CHAR(65328-65335)"
	set utf8(cnti)="239,188,176,239,188,177,239,188,178,239,188,179,239,188,180,239,188,181,239,188,182,239,188,183"
	set cnti=cnti+1,str(cnti)="ＸＹＺ［＼］＾＿",ucp(cnti)="65336,65337,65338,65339,65340,65341,65342,65343",width(cnti)=16,comments(cnti)="full width $CHAR(65336-65343)"
	set utf8(cnti)="239,188,184,239,188,185,239,188,186,239,188,187,239,188,188,239,188,189,239,188,190,239,188,191"
	set cnti=cnti+1,str(cnti)="｀ａｂｃｄｅｆｇ",ucp(cnti)="65344,65345,65346,65347,65348,65349,65350,65351",width(cnti)=16,comments(cnti)="full width $CHAR(65344-65351)"
	set utf8(cnti)="239,189,128,239,189,129,239,189,130,239,189,131,239,189,132,239,189,133,239,189,134,239,189,135"
	set cnti=cnti+1,str(cnti)="ｈｉｊｋｌｍｎｏ",ucp(cnti)="65352,65353,65354,65355,65356,65357,65358,65359",width(cnti)=16,comments(cnti)="full width $CHAR(65352-65359)"
	set utf8(cnti)="239,189,136,239,189,137,239,189,138,239,189,139,239,189,140,239,189,141,239,189,142,239,189,143"
	set cnti=cnti+1,str(cnti)="ｐｑｒｓｔｕｖｗ",ucp(cnti)="65360,65361,65362,65363,65364,65365,65366,65367",width(cnti)=16,comments(cnti)="full width $CHAR(65360-65367)"
	set utf8(cnti)="239,189,144,239,189,145,239,189,146,239,189,147,239,189,148,239,189,149,239,189,150,239,189,151"
	set cnti=cnti+1,str(cnti)="ｘｙｚ｛｜｝～｟",ucp(cnti)="65368,65369,65370,65371,65372,65373,65374,65375",width(cnti)=16,comments(cnti)="full width $CHAR(65368-65375)"
	set utf8(cnti)="239,189,152,239,189,153,239,189,154,239,189,155,239,189,156,239,189,157,239,189,158,239,189,159"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; mixture of ASCII and Fullwidth:
	set cnti=cnti+1,str(cnti)="a mｉxＴuＲe",width(cnti)=12,ucp(cnti)="97,32,109,65353,120,65332,117,65330,101",comments(cnti)="mixture of ASCII and fullwidth"
	set utf8(cnti)="97,32,109,239,189,137,120,239,188,180,117,239,188,178,101"
	set cntstrfinde=cnti
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Sample Hebrew
	; without vowels:(rightmost) U+05E9 U+05DE U+05D5 U+05D0 U+05DC (leftmost): לאומש
	;                             ש      מ      ו      א      ל
	;
	; With points/vowels, in the same order,
	;
	;    05E9 05C1 05B0 shin point shin (dot above right) point sheva (2 vert dot below)
	;    05DE           mem
	;    05D5 05BC      vav point dagesh/mapiq (dot middle)
	;    05D0 05B5      aleph point tsere (2 horiz dot below)
	;    05DC           lamed
	;
	; Each line above is a single character with the character name followed by any
	; points (point shin and point dagesh/mapiq distingush variations of consonants,
	; sheva and tsere are vowels.) I've included a short description of what the
	; points look like in parens.
	; : לאֵוּמשְׁ
	set cnti=cnti+1,str(cnti)="ש",ucp(cnti)="1513",utf8(cnti)="215,169",comments(cnti)="U+05E9"
	set cnti=cnti+1,str(cnti)="מ",ucp(cnti)="1502",utf8(cnti)="215,158",comments(cnti)="U+05DE"
	set cnti=cnti+1,str(cnti)="ו",ucp(cnti)="1493",utf8(cnti)="215,149",comments(cnti)="U+05D5"
	set cnti=cnti+1,str(cnti)="א",ucp(cnti)="1488",utf8(cnti)="215,144",comments(cnti)="U+05D0 ALEF"
	set cnti=cnti+1,str(cnti)="ל",ucp(cnti)="1500",utf8(cnti)="215,156",comments(cnti)="U+05DC"
	set cnti=cnti+1,str(cnti)="‏שמואל‎",ucp(cnti)="8207,1513,1502,1493,1488,1500,8206",width(cnti)=5,comments(cnti)="U+05DC should appear leftmost, and U+05E9 right-most, RLM at the beginning of string, LRM at the end" ;LRM and RLM are zero width chars.
	set utf8(cnti)="226,128,143,215,169,215,158,215,149,215,144,215,156,226,128,142"
	set cnti=cnti+1,str(cnti)="שמואל",ucp(cnti)="1513,1502,1493,1488,1500",comments(cnti)="without RLM and LRM"
	set utf8(cnti)="215,169,215,158,215,149,215,144,215,156"
	;
	; the accent characters when combined show up as one char and so calculating width from ucplen will be misleading
	set cnti=cnti+1,str(cnti)="א֑",ucp(cnti)="1488,1425",utf8(cnti)="215,144,214,145",comments(cnti)="ALEF (U+05D0) with HEBREW ACCENT ETNAHTA (U+0591)"
	set width(cnti)=1
	set cnti=cnti+1,str(cnti)="לְ",ucp(cnti)="1500,1456",utf8(cnti)="215,156,214,176",comments(cnti)="LAMED (U+05DC) with HEBREW POINT SHEVA (U+05B0)"
	set width(cnti)=1
	set cnti=cnti+1,str(cnti)="לׄ",ucp(cnti)="1500,1476",utf8(cnti)="215,156,215,132",comments(cnti)="LAMED (U+05DC) with HEBREW MARK UPPER DOT (U+05C4)"
	set width(cnti)=1
	set cnti=cnti+1,str(cnti)="לְׄ",ucp(cnti)="1500,1456,1476",utf8(cnti)="215,156,214,176,215,132",comments(cnti)="LAMED (U+05DC) with HEBREW POINT SHEVA (U+05B0) and HEBREW MARK UPPER DOT (U+05C4)"
	set width(cnti)=1
	;
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; usage of combination characters
	set cnti=cnti+1,str(cnti)="Türkçe",ucp(cnti)="84,252,114,107,231,101",utf8(cnti)="84,195,188,114,107,195,167,101",comments(cnti)="Normalized"
	set cnti=cnti+1,str(cnti)="Türkçe",ucp(cnti)="84,117,776,114,107,99,807,101",utf8(cnti)="84,117,204,136,114,107,99,204,167,101",width(cnti)=6,comments(cnti)="with combining characters (U+0308 after u, and U+0327 after c)"
	set width(cnti)=6
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; samples from different languages (pangrams or other samples ("I can eat glass"))
	set cnti=cnti+1,str(cnti)="Falsches Üben von Xylophonmusik quält jeden größeren Zwerg.",comments(cnti)="German"
	set ucp(cnti)="70,97,108,115,99,104,101,115,32,220,98,101,110,32,118,111,110,32,88,121,108,111,112,104,111,110,109,117,115,105,107,32,113,117,228,108,116,32,106,101,100,101,110,32,103,114,246,223,101,114,101,110,32,90,119,101,114,103,46"
	set utf8(cnti)="70,97,108,115,99,104,101,115,32,195,156,98,101,110,32,118,111,110,32,88,121,108,111,112,104,111,110,109,117,115,105,107,32,113,117,195,164,108,116,32,106,101,100,101,110,32,103,114,195,182,195,159,101,114,101,110,32,90,119,101,114,103,46"
	set cnti=cnti+1,str(cnti)="Pchnąć w tę łódź jeża lub ośm skrzyń fig.",comments(cnti)="Polish"
	set ucp(cnti)="80,99,104,110,261,263,32,119,32,116,281,32,322,243,100,378,32,106,101,380,97,32,108,117,98,32,111,347,109,32,115,107,114,122,121,324,32,102,105,103,46"
	set utf8(cnti)="80,99,104,110,196,133,196,135,32,119,32,116,196,153,32,197,130,195,179,100,197,186,32,106,101,197,188,97,32,108,117,98,32,111,197,155,109,32,115,107,114,122,121,197,132,32,102,105,103,46"
	set cnti=cnti+1,str(cnti)="Příliš žluťoučký kůň úpěl ďábelské kódy.",comments(cnti)="Czech"
	set ucp(cnti)="80,345,237,108,105,353,32,382,108,117,357,111,117,269,107,253,32,107,367,328,32,250,112,283,108,32,271,225,98,101,108,115,107,233,32,107,243,100,121,46"
	set utf8(cnti)="80,197,153,195,173,108,105,197,161,32,197,190,108,117,197,165,111,117,196,141,107,195,189,32,107,197,175,197,136,32,195,186,112,196,155,108,32,196,143,195,161,98,101,108,115,107,195,169,32,107,195,179,100,121,46"
	set cnti=cnti+1,str(cnti)="В чащах юга жил-был цитрус? Да, но фальшивый экземпляр! ёъ.",comments(cnti)="Russian"
	set ucp(cnti)="1042,32,1095,1072,1097,1072,1093,32,1102,1075,1072,32,1078,1080,1083,45,1073,1099,1083,32,1094,1080,1090,1088,1091,1089,63,32,1044,1072,44,32,1085,1086,32,1092,1072,1083,1100,1096,1080,1074,1099,1081,32,1101,1082,1079,1077,1084,1087,1083,1103,1088,33,32,1105,1098,46"
	set utf8(cnti)="208,146,32,209,135,208,176,209,137,208,176,209,133,32,209,142,208,179,208,176,32,208,182,208,184,208,187,45,208,177,209,139,208,187,32,209,134,208,184,209,130,209,128,209,131,209,129,63,32,208,148,208,176,44,32,208,189,208,190,32,209,132,208,176,208,187,209,140,209,136,208,184,208,178,209,139,208,185,32,209,141,208,186,208,183,208,181,208,188,208,191,208,187,209,143,209,128,33,32,209,145,209,138,46"
	set cnti=cnti+1,str(cnti)="Árvíztűrő tükörfúrógép.",comments(cnti)="Hungarian"
	set ucp(cnti)="193,114,118,237,122,116,369,114,337,32,116,252,107,246,114,102,250,114,243,103,233,112,46"
	set utf8(cnti)="195,129,114,118,195,173,122,116,197,177,114,197,145,32,116,195,188,107,195,182,114,102,195,186,114,195,179,103,195,169,112,46"
	set cnti=cnti+1,str(cnti)="いろはにほへど　ちりぬるを",width(cnti)=26,comments(cnti)="Japanese (Hiragana) 1/4"
	set ucp(cnti)="12356,12429,12399,12395,12411,12408,12393,12288,12385,12426,12396,12427,12434"
	set utf8(cnti)="227,129,132,227,130,141,227,129,175,227,129,171,227,129,187,227,129,184,227,129,169,227,128,128,227,129,161,227,130,138,227,129,172,227,130,139,227,130,146"
	set cnti=cnti+1,str(cnti)="わがよたれぞ　つねならむ",width(cnti)=24,comments(cnti)="Japanese (Hiragana) 2/4"
	set ucp(cnti)="12431,12364,12424,12383,12428,12382,12288,12388,12397,12394,12425,12416"
	set utf8(cnti)="227,130,143,227,129,140,227,130,136,227,129,159,227,130,140,227,129,158,227,128,128,227,129,164,227,129,173,227,129,170,227,130,137,227,130,128"
	set cnti=cnti+1,str(cnti)="うゐのおくやま　けふこえて",width(cnti)=26,comments(cnti)="Japanese (Hiragana) 3/4"
	set ucp(cnti)="12358,12432,12398,12362,12367,12420,12414,12288,12369,12405,12371,12360,12390"
	set utf8(cnti)="227,129,134,227,130,144,227,129,174,227,129,138,227,129,143,227,130,132,227,129,190,227,128,128,227,129,145,227,129,181,227,129,147,227,129,136,227,129,166"
	set cnti=cnti+1,str(cnti)="あさきゆめみじ　ゑひもせず",width(cnti)=26,comments(cnti)="Japanese (Hiragana) 4/4"
	set ucp(cnti)="12354,12373,12365,12422,12417,12415,12376,12288,12433,12402,12418,12379,12378"
	set utf8(cnti)="227,129,130,227,129,149,227,129,141,227,130,134,227,130,129,227,129,191,227,129,152,227,128,128,227,130,145,227,129,178,227,130,130,227,129,155,227,129,154"
	set cnti=cnti+1,str(cnti)="色は匂へど 散りぬるを",width(cnti)=21,comments(cnti)="Japanese (Kanji) 1/4"
	set ucp(cnti)="33394,12399,21250,12408,12393,32,25955,12426,12396,12427,12434"
	set utf8(cnti)="232,137,178,227,129,175,229,140,130,227,129,184,227,129,169,32,230,149,163,227,130,138,227,129,172,227,130,139,227,130,146"
	set cnti=cnti+1,str(cnti)="我が世誰ぞ 常ならむ",width(cnti)=19,comments(cnti)="Japanese (Kanji) 2/4"
	set ucp(cnti)="25105,12364,19990,35504,12382,32,24120,12394,12425,12416"
	set utf8(cnti)="230,136,145,227,129,140,228,184,150,232,170,176,227,129,158,32,229,184,184,227,129,170,227,130,137,227,130,128"
	set cnti=cnti+1,str(cnti)="有為の奥山 今日越えて",width(cnti)=21,comments(cnti)="Japanese (Kanji) 3/4"
	set ucp(cnti)="26377,28858,12398,22885,23665,32,20170,26085,36234,12360,12390"
	set utf8(cnti)="230,156,137,231,130,186,227,129,174,229,165,165,229,177,177,32,228,187,138,230,151,165,232,182,138,227,129,136,227,129,166"
	set cnti=cnti+1,str(cnti)="浅き夢見じ 酔ひもせず",width(cnti)=21,comments(cnti)="Japanese (Kanji) 4/4"
	set ucp(cnti)="27973,12365,22818,35211,12376,32,37204,12402,12418,12379,12378"
	set utf8(cnti)="230,181,133,227,129,141,229,164,162,232,166,139,227,129,152,32,233,133,148,227,129,178,227,130,130,227,129,155,227,129,154"
	set cnti=cnti+1,str(cnti)="나는 유리를 먹을 수 있어요. 그래도 아프지 않아요",width(cnti)=48,comments(cnti)="Korean"
	set ucp(cnti)="45208,45716,32,50976,47532,47484,32,47673,51012,32,49688,32,51080,50612,50836,46,32,44536,47000,46020,32,50500,54532,51648,32,50506,50500,50836"
	set utf8(cnti)="235,130,152,235,138,148,32,236,156,160,235,166,172,235,165,188,32,235,168,185,236,157,132,32,236,136,152,32,236,158,136,236,150,180,236,154,148,46,32,234,183,184,235,158,152,235,143,132,32,236,149,132,237,148,132,236,167,128,32,236,149,138,236,149,132,236,154,148"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Chinese samples
	set cnti=cnti+1,str(cnti)="我能吞下玻璃而傷身體。",width(cnti)=22,comments(cnti)="Chinese sample 1"
	set ucp(cnti)="25105,33021,21534,19979,29627,29827,32780,20663,36523,39636,12290"
	set utf8(cnti)="230,136,145,232,131,189,229,144,158,228,184,139,231,142,187,231,146,131,232,128,140,229,130,183,232,186,171,233,171,148,227,128,130"
	set cnti=cnti+1,str(cnti)="史記  前漢書  後漢書  三國志  晉書  宋書  魏書",width(cnti)=46,comments(cnti)="Chinese sample 2"
	set ucp(cnti)="21490,35352,32,32,21069,28450,26360,32,32,24460,28450,26360,32,32,19977,22283,24535,32,32,26185,26360,32,32,23435,26360,32,32,39759,26360"
	set utf8(cnti)="229,143,178,232,168,152,32,32,229,137,141,230,188,162,230,155,184,32,32,229,190,140,230,188,162,230,155,184,32,32,228,184,137,229,156,139,229,191,151,32,32,230,153,137,230,155,184,32,32,229,174,139,230,155,184,32,32,233,173,143,230,155,184"
	set cnti=cnti+1,str(cnti)="北齊書  周書  南史  北史  隋書",width(cnti)=30,comments(cnti)="Chinese sample 3"
	set ucp(cnti)="21271,40778,26360,32,32,21608,26360,32,32,21335,21490,32,32,21271,21490,32,32,38539,26360"
	set utf8(cnti)="229,140,151,233,189,138,230,155,184,32,32,229,145,168,230,155,184,32,32,229,141,151,229,143,178,32,32,229,140,151,229,143,178,32,32,233,154,139,230,155,184"
	set cnti=cnti+1,str(cnti)="客去波平槛",width(cnti)=10,comments(cnti)="Chinese sample 4"
	set ucp(cnti)="23458,21435,27874,24179,27099"
	set utf8(cnti)="229,174,162,229,142,187,230,179,162,229,185,179,230,167,155"
	set cnti=cnti+1,str(cnti)="蝉休露满枝 永怀当此节",width(cnti)=21,comments(cnti)="Chinese sample 5"
	set ucp(cnti)="34633,20241,38706,28385,26525,32,27704,24576,24403,27492,33410"
	set utf8(cnti)="232,157,137,228,188,145,233,156,178,230,187,161,230,158,157,32,230,176,184,230,128,128,229,189,147,230,173,164,232,138,130"
	set cnti=cnti+1,str(cnti)="倚立自移时 北斗兼春远",width(cnti)=21,comments(cnti)="Chinese sample 6"
	set ucp(cnti)="20506,31435,33258,31227,26102,32,21271,26007,20860,26149,36828"
	set utf8(cnti)="229,128,154,231,171,139,232,135,170,231,167,187,230,151,182,32,229,140,151,230,150,151,229,133,188,230,152,165,232,191,156"
	set cnti=cnti+1,str(cnti)="南陵寓使迟 天涯占梦数 疑误有新知",width(cnti)=32,comments(cnti)="Chinese sample 7"
	set ucp(cnti)="21335,38517,23507,20351,36831,32,22825,28079,21344,26790,25968,32,30097,35823,26377,26032,30693"
	set utf8(cnti)="229,141,151,233,153,181,229,175,147,228,189,191,232,191,159,32,229,164,169,230,182,175,229,141,160,230,162,166,230,149,176,32,231,150,145,232,175,175,230,156,137,230,150,176,231,159,165"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Japanese samples (Article 1 of the Universal Declaration of Human Rights)
	set cnti=cnti+1,str(cnti)="すべての人間は、",width(cnti)=16,comments(cnti)="Japanese sample 1"
	set ucp(cnti)="12377,12409,12390,12398,20154,38291,12399,12289"
	set utf8(cnti)="227,129,153,227,129,185,227,129,166,227,129,174,228,186,186,233,150,147,227,129,175,227,128,129"
	set cnti=cnti+1,str(cnti)="生まれながらにして自由であり、",width(cnti)=30,comments(cnti)="Japanese sample 2"
	set ucp(cnti)="29983,12414,12428,12394,12364,12425,12395,12375,12390,33258,30001,12391,12354,12426,12289"
	set utf8(cnti)="231,148,159,227,129,190,227,130,140,227,129,170,227,129,140,227,130,137,227,129,171,227,129,151,227,129,166,232,135,170,231,148,177,227,129,167,227,129,130,227,130,138,227,128,129"
	set cnti=cnti+1,str(cnti)="かつ、尊厳と権利とについ",width(cnti)=24,comments(cnti)="Japanese sample 3"
	set ucp(cnti)="12363,12388,12289,23562,21427,12392,27177,21033,12392,12395,12388,12356"
	set utf8(cnti)="227,129,139,227,129,164,227,128,129,229,176,138,229,142,179,227,129,168,230,168,169,229,136,169,227,129,168,227,129,171,227,129,164,227,129,132"
	set cnti=cnti+1,str(cnti)="て平等である。人間は、",width(cnti)=22,comments(cnti)="Japanese sample 4"
	set ucp(cnti)="12390,24179,31561,12391,12354,12427,12290,20154,38291,12399,12289"
	set utf8(cnti)="227,129,166,229,185,179,231,173,137,227,129,167,227,129,130,227,130,139,227,128,130,228,186,186,233,150,147,227,129,175,227,128,129"
	set cnti=cnti+1,str(cnti)="理性と良心、とを授けられてあり、",width(cnti)=32,comments(cnti)="Japanese sample 5"
	set ucp(cnti)="29702,24615,12392,33391,24515,12289,12392,12434,25480,12369,12425,12428,12390,12354,12426,12289"
	set utf8(cnti)="231,144,134,230,128,167,227,129,168,232,137,175,229,191,131,227,128,129,227,129,168,227,130,146,230,142,136,227,129,145,227,130,137,227,130,140,227,129,166,227,129,130,227,130,138,227,128,129"
	set cnti=cnti+1,str(cnti)="互いに同胞の精神をも",width(cnti)=20,comments(cnti)="Japanese sample 6"
	set ucp(cnti)="20114,12356,12395,21516,32990,12398,31934,31070,12434,12418"
	set utf8(cnti)="228,186,146,227,129,132,227,129,171,229,144,140,232,131,158,227,129,174,231,178,190,231,165,158,227,130,146,227,130,130"
	set cnti=cnti+1,str(cnti)="って行動しなければならない。",width(cnti)=28,comments(cnti)="Japanese sample 7"
	set ucp(cnti)="12387,12390,34892,21205,12375,12394,12369,12428,12400,12394,12425,12394,12356,12290"
	set utf8(cnti)="227,129,163,227,129,166,232,161,140,229,139,149,227,129,151,227,129,170,227,129,145,227,130,140,227,129,176,227,129,170,227,130,137,227,129,170,227,129,132,227,128,130"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Enclosed Alphanumerics (U+2460-U+24FF)
	set cnti=cnti+1,str(cnti)="①②③④⑤⑥⑦⑧",ucp(cnti)="9312,9313,9314,9315,9316,9317,9318,9319",comments(cnti)="$CHAR(9312-9319)"
	set utf8(cnti)="226,145,160,226,145,161,226,145,162,226,145,163,226,145,164,226,145,165,226,145,166,226,145,167"
	set cnti=cnti+1,str(cnti)="⑨⑩⑪⑫⑬⑭⑮⑯",ucp(cnti)="9320,9321,9322,9323,9324,9325,9326,9327",comments(cnti)="$CHAR(9320-9327)"
	set utf8(cnti)="226,145,168,226,145,169,226,145,170,226,145,171,226,145,172,226,145,173,226,145,174,226,145,175"
	set cnti=cnti+1,str(cnti)="⑰⑱⑲⑳⑴⑵⑶⑷",ucp(cnti)="9328,9329,9330,9331,9332,9333,9334,9335",comments(cnti)="$CHAR(9328-9335)"
	set utf8(cnti)="226,145,176,226,145,177,226,145,178,226,145,179,226,145,180,226,145,181,226,145,182,226,145,183"
	set cnti=cnti+1,str(cnti)="⑸⑹⑺⑻⑼⑽⑾⑿",ucp(cnti)="9336,9337,9338,9339,9340,9341,9342,9343",comments(cnti)="$CHAR(9336-9343)"
	set utf8(cnti)="226,145,184,226,145,185,226,145,186,226,145,187,226,145,188,226,145,189,226,145,190,226,145,191"
	set cnti=cnti+1,str(cnti)="⒀⒁⒂⒃⒄⒅⒆⒇",ucp(cnti)="9344,9345,9346,9347,9348,9349,9350,9351",comments(cnti)="$CHAR(9344-9351)"
	set utf8(cnti)="226,146,128,226,146,129,226,146,130,226,146,131,226,146,132,226,146,133,226,146,134,226,146,135"
	set cnti=cnti+1,str(cnti)="⒈⒉⒊⒋⒌⒍⒎⒏",ucp(cnti)="9352,9353,9354,9355,9356,9357,9358,9359",comments(cnti)="$CHAR(9352-9359)"
	set utf8(cnti)="226,146,136,226,146,137,226,146,138,226,146,139,226,146,140,226,146,141,226,146,142,226,146,143"
	set cnti=cnti+1,str(cnti)="⒐⒑⒒⒓⒔⒕⒖⒗",ucp(cnti)="9360,9361,9362,9363,9364,9365,9366,9367",comments(cnti)="$CHAR(9360-9367)"
	set utf8(cnti)="226,146,144,226,146,145,226,146,146,226,146,147,226,146,148,226,146,149,226,146,150,226,146,151"
	set cnti=cnti+1,str(cnti)="⒘⒙⒚⒛⒜⒝⒞⒟",ucp(cnti)="9368,9369,9370,9371,9372,9373,9374,9375",comments(cnti)="$CHAR(9368-9375)"
	set utf8(cnti)="226,146,152,226,146,153,226,146,154,226,146,155,226,146,156,226,146,157,226,146,158,226,146,159"
	set cnti=cnti+1,str(cnti)="⒣⒠⒧⒧⒪ ⒲ⓞⓡld",ucp(cnti)="9379,9376,9383,9383,9386,32,9394,9438,9441,108,100",comments(cnti)="hello world, in parentheses (U+2460-U+24FF)"
	set utf8(cnti)="226,146,163,226,146,160,226,146,167,226,146,167,226,146,170,32,226,146,178,226,147,158,226,147,161,108,100"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; CJK Area (samples over U+4E00-U+9FFF)
	set cnti=cnti+1,str(cnti)="一丄下丕丢串久",ucp(cnti)="19968,19972,19979,19989,20002,20018,20037",width(cnti)=14,comments(cnti)="samples from $CHAR(19968-20059)"
	set utf8(cnti)="228,184,128,228,184,132,228,184,139,228,184,149,228,184,162,228,184,178,228,185,133"
	set cnti=cnti+1,str(cnti)="乴亐亯仑件伞佉佷",ucp(cnti)="20084,20112,20143,20177,20214,20254,20297,20343",width(cnti)=16,comments(cnti)="samples from $CHAR(20084-20343)"
	set utf8(cnti)="228,185,180,228,186,144,228,186,175,228,187,145,228,187,182,228,188,158,228,189,137,228,189,183"
	set cnti=cnti+1,str(cnti)="侨俜倓傊僊儍兓",ucp(cnti)="20392,20444,20499,20618,20682,20749,20819",width(cnti)=14,comments(cnti)="samples from $CHAR(20392-20819)"
	set utf8(cnti)="228,190,168,228,191,156,229,128,147,229,130,138,229,131,138,229,132,141,229,133,147"
	set cnti=cnti+1,str(cnti)="俭倥偠傞僟儣兪",ucp(cnti)="20461,20517,20576,20638,20703,20771,20842",width(cnti)=14,comments(cnti)="samples from $CHAR(20408-20842)"
	set utf8(cnti)="228,191,173,229,128,165,229,129,160,229,130,158,229,131,159,229,132,163,229,133,170"
	set cnti=cnti+1,str(cnti)="冴刁剑劤勺卓厯后",ucp(cnti)="20916,20993,21073,21156,21242,21331,21423,21518",width(cnti)=16,comments(cnti)="samples from $CHAR(20916-21518)"
	set utf8(cnti)="229,134,180,229,136,129,229,137,145,229,138,164,229,139,186,229,141,147,229,142,175,229,144,142"
	set cnti=cnti+1,str(cnti)="妙姈娯婧媢嫠嬡",ucp(cnti)="22937,22984,23087,23143,23202,23264,23329",width(cnti)=14,comments(cnti)="samples from $CHAR(22937-23329)"
	set utf8(cnti)="229,166,153,229,167,136,229,168,175,229,169,167,229,170,162,229,171,160,229,172,161"
	set cnti=cnti+1,str(cnti)="执抒抬拉择挌挲",ucp(cnti)="25191,25234,25260,25289,25321,25356,25394",width(cnti)=14,comments(cnti)="samples from $CHAR(25191-25394)"
	set utf8(cnti)="230,137,167,230,138,146,230,138,172,230,139,137,230,139,169,230,140,140,230,140,178"
	set cnti=cnti+1,str(cnti)="琴璥甙疐瘊瘌瘙",ucp(cnti)="29748,29861,29977,30096,30218,30220,30233",width(cnti)=14,comments(cnti)="samples from $CHAR(29748-30233)"
	set utf8(cnti)="231,144,180,231,146,165,231,148,153,231,150,144,231,152,138,231,152,140,231,152,153"
	set cnti=cnti+1,str(cnti)="結綷縡纎绾罱聠",ucp(cnti)="32080,32183,32289,32398,32510,32625,32864",width(cnti)=14,comments(cnti)="samples from $CHAR(32080-32864)"
	set utf8(cnti)="231,181,144,231,182,183,231,184,161,231,186,142,231,187,190,231,189,177,232,129,160"
	set cnti=cnti+1,str(cnti)="綴縢纓缇罾翺翿",ucp(cnti)="32180,32290,32403,32519,32638,32762,32767",width(cnti)=14,comments(cnti)="samples from $CHAR(32180-32767)"
	set utf8(cnti)="231,182,180,231,184,162,231,186,147,231,188,135,231,189,190,231,191,186,231,191,191"
	set cnti=cnti+1,str(cnti)="舟艚芘苙茝荤菻",ucp(cnti)="33311,33370,33432,33497,33565,33636,33787",width(cnti)=14,comments(cnti)="samples from $CHAR(33311-33787)"
	set utf8(cnti)="232,136,159,232,137,154,232,138,152,232,139,153,232,140,157,232,141,164,232,143,187"
	set cnti=cnti+1,str(cnti)="鑒鑯钏钲铘锁锭镜",ucp(cnti)="37970,37999,38031,38066,38104,38145,38189,38236",width(cnti)=16,comments(cnti)="samples from $CHAR(37970-38236)"
	set utf8(cnti)="233,145,146,233,145,175,233,146,143,233,146,178,233,147,152,233,148,129,233,148,173,233,149,156"
	set cnti=cnti+1,str(cnti)="鰄鱫鳕鵂鶲鸥麛鼔",ucp(cnti)="39940,40043,40149,40258,40370,40485,40603,40724",width(cnti)=16,comments(cnti)="samples from $CHAR(39940-40724)"
	set utf8(cnti)="233,176,132,233,177,171,233,179,149,233,181,130,233,182,178,233,184,165,233,186,155,233,188,148"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; CJK Extension A (U+3400-U+4DBF)
	set cnti=cnti+1,str(cnti)="㐀㐄㐋㐕㐢",ucp(cnti)="13312,13316,13323,13333,13346",width(cnti)=10,comments(cnti)="samples from $CHAR(13312-13346)"
	set utf8(cnti)="227,144,128,227,144,132,227,144,139,227,144,149,227,144,162"
	set cnti=cnti+1,str(cnti)="㐲㑅㑛㑴㒐㒯",ucp(cnti)="13362,13381,13403,13428,13456,13487",width(cnti)=12,comments(cnti)="samples from $CHAR(13362-13487)"
	set utf8(cnti)="227,144,178,227,145,133,227,145,155,227,145,180,227,146,144,227,146,175"
	set cnti=cnti+1,str(cnti)="㓑㓶㔞㕉㕷㖨㗜",ucp(cnti)="13521,13558,13598,13641,13687,13736,13788",width(cnti)=14,comments(cnti)="samples from $CHAR(13521-13788)"
	set utf8(cnti)="227,147,145,227,147,182,227,148,158,227,149,137,227,149,183,227,150,168,227,151,156"
	set cnti=cnti+1,str(cnti)="㘓㙍㚊㛊㜍㝓㞜㟨",ucp(cnti)="13843,13901,13962,14026,14093,14163,14236,14312",width(cnti)=16,comments(cnti)="samples from $CHAR(13843-14312)"
	set utf8(cnti)="227,152,147,227,153,141,227,154,138,227,155,138,227,156,141,227,157,147,227,158,156,227,159,168"
	set cnti=cnti+1,str(cnti)="㠷㢉㣞㤶㦑㧯㩐㪴㬛",ucp(cnti)="14391,14473,14558,14646,14737,14831,14928,15028,15131",width(cnti)=18,comments(cnti)="samples from $CHAR(14391-15131)"
	set utf8(cnti)="227,160,183,227,162,137,227,163,158,227,164,182,227,166,145,227,167,175,227,169,144,227,170,180,227,172,155"
	set cnti=cnti+1,str(cnti)="㮅㯲㱢㳕㵋㷄㹀㹇㹑㹞",ucp(cnti)="15237,15346,15458,15573,15691,15812,15936,15943,15953,15966",width(cnti)=20,comments(cnti)="samples from $CHAR(15237-15966)"
	set utf8(cnti)="227,174,133,227,175,178,227,177,162,227,179,149,227,181,139,227,183,132,227,185,128,227,185,135,227,185,145,227,185,158"
	set cnti=cnti+1,str(cnti)="㹮㺁㺗㺰㻌",ucp(cnti)="15982,16001,16023,16048,16076",width(cnti)=10,comments(cnti)="samples from $CHAR(15982-16076)"
	set utf8(cnti)="227,185,174,227,186,129,227,186,151,227,186,176,227,187,140"
	set cnti=cnti+1,str(cnti)="㻫㼍㼲㽚㾅㾳",ucp(cnti)="16107,16141,16178,16218,16261,16307",width(cnti)=12,comments(cnti)="samples from $CHAR(16107-16307)"
	set utf8(cnti)="227,187,171,227,188,141,227,188,178,227,189,154,227,190,133,227,190,179"
	set cnti=cnti+1,str(cnti)="㿤䀘䁏䂉䃆䄆䅉",ucp(cnti)="16356,16408,16463,16521,16582,16646,16713",width(cnti)=14,comments(cnti)="samples from $CHAR(16356-16713)"
	set utf8(cnti)="227,191,164,228,128,152,228,129,143,228,130,137,228,131,134,228,132,134,228,133,137"
	set cnti=cnti+1,str(cnti)="䆏䇘䈤䉳䋅䌚䍲䏍",ucp(cnti)="16783,16856,16932,17011,17093,17178,17266,17357",width(cnti)=16,comments(cnti)="samples from $CHAR(16783-17357)"
	set utf8(cnti)="228,134,143,228,135,152,228,136,164,228,137,179,228,139,133,228,140,154,228,141,178,228,143,141"
	set cnti=cnti+1,str(cnti)="䐫䒌䓰䕗䗁䘮䚞䜑䞇",ucp(cnti)="17451,17548,17648,17751,17857,17966,18078,18193,18311",width(cnti)=18,comments(cnti)="samples from $CHAR(17451-18311)"
	set utf8(cnti)="228,144,171,228,146,140,228,147,176,228,149,151,228,151,129,228,152,174,228,154,158,228,156,145,228,158,135"
	set cnti=cnti+1,str(cnti)="䠀䡼䢃䢍䢚䢪䢽䣓䣬䤈",ucp(cnti)="18432,18556,18563,18573,18586,18602,18621,18643,18668,18696",width(cnti)=20,comments(cnti)="samples from $CHAR(18432-18696)"
	set utf8(cnti)="228,160,128,228,161,188,228,162,131,228,162,141,228,162,154,228,162,170,228,162,189,228,163,147,228,163,172,228,164,136"
	set cnti=cnti+1,str(cnti)="䤧䥉䥮䦖䧁",ucp(cnti)="18727,18761,18798,18838,18881",width(cnti)=10,comments(cnti)="samples from $CHAR(18727-18881)"
	set utf8(cnti)="228,164,167,228,165,137,228,165,174,228,166,150,228,167,129"
	set cnti=cnti+1,str(cnti)="䧯䨠䩔䪋䫅䬂",ucp(cnti)="18927,18976,19028,19083,19141,19202",width(cnti)=12,comments(cnti)="samples from $CHAR(18927-19202)"
	set utf8(cnti)="228,167,175,228,168,160,228,169,148,228,170,139,228,171,133,228,172,130"
	set cnti=cnti+1,str(cnti)="䭂䮅䯋䰔䱠䲯䴁䶿",ucp(cnti)="19266,19333,19403,19476,19552,19631,19713,19903",width(cnti)=-1,comments(cnti)="samples from $CHAR(19266-19903)"
	; width is -1 for the above string because of code point 4DBF code point
	set utf8(cnti)="228,173,130,228,174,133,228,175,139,228,176,148,228,177,160,228,178,175,228,180,129,228,182,191"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Private use Area (U+E000-U+F8FF)
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="57344,57601,57858,58115,58372,58629,58886,59143",comments(cnti)="samples in the range $CHAR(57344-59143)",width(cnti)=-1
	set utf8(cnti)="238,128,128,238,132,129,238,136,130,238,140,131,238,144,132,238,148,133,238,152,134,238,156,135"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="59400,59657,59914,60171,60428,60685,60942,61199",comments(cnti)="samples in the range $CHAR(59400-61199)",width(cnti)=-1
	set utf8(cnti)="238,160,136,238,164,137,238,168,138,238,172,139,238,176,140,238,180,141,238,184,142,238,188,143"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="61456,61713,61970,62227,62484,62741,62998,63255,63743",comments(cnti)="samples in the range $CHAR(61456-63255)",width(cnti)=-1
	set utf8(cnti)="239,128,144,239,132,145,239,136,146,239,140,147,239,144,148,239,148,149,239,152,150,239,156,151,239,163,191",width(cnti)=-1
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; CJK Compatibility Ideographs (U+F900-U+FAFF)
	set cnti=cnti+1,str(cnti)="豈羅爛來祿屢讀數",ucp(cnti)="63744,63759,63774,63789,63804,63819,63834,63849",width(cnti)=16,comments(cnti)="samples in the range $CHAR(63744-63849)"
	set utf8(cnti)="239,164,128,239,164,143,239,164,158,239,164,173,239,164,188,239,165,139,239,165,154,239,165,169"
	set cnti=cnti+1,str(cnti)="兩驪練殮領遼戮李",ucp(cnti)="63864,63879,63894,63909,63924,63939,63954,63969",width(cnti)=16,comments(cnti)="samples in the range $CHAR(63864-63969)"
	set utf8(cnti)="239,165,184,239,166,135,239,166,150,239,166,165,239,166,180,239,167,131,239,167,146,239,167,161"
	set cnti=cnti+1,str(cnti)="藺刺﨎精館層琢繁",ucp(cnti)="63984,63999,64014,64029,64044,64059,64074,64089",width(cnti)=16,comments(cnti)="samples in the range $CHAR(63984-64089)"
	set utf8(cnti)="239,167,176,239,167,191,239,168,142,239,168,157,239,168,172,239,168,187,239,169,138,239,169,153"
	set cnti=cnti+1,str(cnti)="難勺惘歹瘝荒輸𣏕",ucp(cnti)="64104,64119,64134,64149,64164,64179,64194,64209",width(cnti)=16,comments(cnti)="samples in the range $CHAR(64104-64209)"
	set utf8(cnti)="239,169,168,239,169,183,239,170,134,239,170,149,239,170,164,239,170,179,239,171,130,239,171,145"
	set cnti=cnti+1,str(cnti)="﫠﫯﫾﫿",ucp(cnti)="64224,64239,64254,64255",width(cnti)=8,comments(cnti)="samples in the range $CHAR(64224-64329)",width(cnti)=-1
	set utf8(cnti)="239,171,160,239,171,175,239,171,190,239,171,191"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Variation Selectors (U+FE00-UFE0F)
	set cnti=cnti+1,str(cnti)="Fr︀iday",ucp(cnti)="70,114,65024,105,100,97,121",width(cnti)="6",comments(cnti)="""Friday"" with a variation selector (U+FE00) on the ""r"""
	set utf8(cnti)="70,114,239,184,128,105,100,97,121"
	set cnti=cnti+1,str(cnti)="Fr︁iday",ucp(cnti)="70,114,65025,105,100,97,121",width(cnti)="6",comments(cnti)="""Friday"" with a variation selector(U+FE01) on the ""r"""
	set utf8(cnti)="70,114,239,184,129,105,100,97,121"
	set cnti=cnti+1,str(cnti)="Fr︎iday",ucp(cnti)="70,114,65038,105,100,97,121",width(cnti)="6",comments(cnti)="""Friday"" with a variation selector (U+FE0F) on the ""r"""
	set utf8(cnti)="70,114,239,184,142,105,100,97,121"
	set cnti=cnti+1,str(cnti)="Fr️iday",ucp(cnti)="70,114,65039,105,100,97,121",width(cnti)="6",comments(cnti)="""Friday"" with a variation selector (U+FE0F) on the ""r"""
	set utf8(cnti)="70,114,239,184,143,105,100,97,121"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Halfwidth characters (U+FF61-U+FFEE)
	set cnti=cnti+1,str(cnti)="｡､ｧｪｭｰｳｶ",ucp(cnti)="65377,65380,65383,65386,65389,65392,65395,65398",comments(cnti)="samples in the range $CHAR(65377-65398)"
	set utf8(cnti)="239,189,161,239,189,164,239,189,167,239,189,170,239,189,173,239,189,176,239,189,179,239,189,182"
	set cnti=cnti+1,str(cnti)="ｹｼｿﾂﾅﾈﾋﾎ",ucp(cnti)="65401,65404,65407,65410,65413,65416,65419,65422",comments(cnti)="samples in the range $CHAR(65401-65422)"
	set utf8(cnti)="239,189,185,239,189,188,239,189,191,239,190,130,239,190,133,239,190,136,239,190,139,239,190,142"
	set cnti=cnti+1,str(cnti)="ﾑﾔﾗﾚﾝﾠﾣﾦ",ucp(cnti)="65425,65428,65431,65434,65437,65440,65443,65446",comments(cnti)="samples in the range $CHAR(65425-65446)"
	set utf8(cnti)="239,190,145,239,190,148,239,190,151,239,190,154,239,190,157,239,190,160,239,190,163,239,190,166"
	set cnti=cnti+1,str(cnti)="ﾩﾬﾯﾲﾵﾸﾻﾾ",ucp(cnti)="65449,65452,65455,65458,65461,65464,65467,65470",comments(cnti)="samples in the range $CHAR(65449-65470)"
	set utf8(cnti)="239,190,169,239,190,172,239,190,175,239,190,178,239,190,181,239,190,184,239,190,187,239,190,190"
	set cnti=cnti+1,str(cnti)="ￂￄￇￊￍￒￓￖ",ucp(cnti)="65474,65476,65479,65482,65485,65490,65491,65494",comments(cnti)="samples in the range $CHAR(65474-65494)"
	set utf8(cnti)="239,191,130,239,191,132,239,191,135,239,191,138,239,191,141,239,191,146,239,191,147,239,191,150"
	set cnti=cnti+1,str(cnti)="ￚￜ￢￥￨￫￮",ucp(cnti)="65498,65500,65506,65509,65512,65515,65518",width(cnti)=9,comments(cnti)="samples in the range $CHAR(65498-65518)"
	set utf8(cnti)="239,191,154,239,191,156,239,191,162,239,191,165,239,191,168,239,191,171,239,191,174"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; U+FFF8-U+FFFD
	set cnti=cnti+1,str(cnti)="a￯a",ucp(cnti)="97,65519,97",comments(cnti)="$CHAR(65519)"
	set utf8(cnti)="97,239,191,175,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￰a",ucp(cnti)="97,65520,97",comments(cnti)="$CHAR(65520)"
	set utf8(cnti)="97,239,191,176,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￱a",ucp(cnti)="97,65521,97",comments(cnti)="$CHAR(65521)"
	set utf8(cnti)="97,239,191,177,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￲a",ucp(cnti)="97,65522,97",comments(cnti)="$CHAR(65522)"
	set utf8(cnti)="97,239,191,178,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￳a",ucp(cnti)="97,65523,97",comments(cnti)="$CHAR(65523)"
	set utf8(cnti)="97,239,191,179,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￴a",ucp(cnti)="97,65524,97",comments(cnti)="$CHAR(65524)"
	set utf8(cnti)="97,239,191,180,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￵a",ucp(cnti)="97,65525,97",comments(cnti)="$CHAR(65525)"
	set utf8(cnti)="97,239,191,181,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￶a",ucp(cnti)="97,65526,97",comments(cnti)="$CHAR(65526)"
	set utf8(cnti)="97,239,191,182,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￷a",ucp(cnti)="97,65527,97",comments(cnti)="$CHAR(65527)"
	set utf8(cnti)="97,239,191,183,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￸a",ucp(cnti)="97,65528,97",comments(cnti)="$CHAR(65528)"
	set utf8(cnti)="97,239,191,184,97",width(cnti)=-1
	set cnti=cnti+1,str(cnti)="a￹a",ucp(cnti)="97,65529,97",width(cnti)=2,comments(cnti)="$CHAR(65529)"
	set utf8(cnti)="97,239,191,185,97"
	set cnti=cnti+1,str(cnti)="a￺a",ucp(cnti)="97,65530,97",width(cnti)=2,comments(cnti)="$CHAR(65530)"
	set utf8(cnti)="97,239,191,186,97"
	set cnti=cnti+1,str(cnti)="a￻a",ucp(cnti)="97,65531,97",width(cnti)=2,comments(cnti)="$CHAR(65531)"
	set utf8(cnti)="97,239,191,187,97"
	set cnti=cnti+1,str(cnti)="a￼a",ucp(cnti)="97,65532,97",comments(cnti)="$CHAR(65532)"
	set utf8(cnti)="97,239,191,188,97"
	set cnti=cnti+1,str(cnti)="a�a",ucp(cnti)="97,65533,97",comments(cnti)="$CHAR(65533)"
	set utf8(cnti)="97,239,191,189,97"

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; non-printable characters
	;- Test some unprintable characters, should return 0 for $ZWIDTH() when alone:
	;Zero width joiner (ZWJ, U+200D):
	set cnti=cnti+1,str(cnti)="f‍i",width(cnti)=2,ucp(cnti)="102,8205,105",utf8(cnti)="102,226,128,141,105",comments(cnti)="f $CHAR(8205) i -- Zero width joiner (ZWJ, U+200D)"
	set cnti=cnti+1,str(cnti)="‍",width(cnti)=0,ucp(cnti)="8205",utf8(cnti)="226,128,141",comments(cnti)="$CHAR(8205) -- Zero width joiner (ZWJ, U+200D)"
	;
	;Zero width non-joiner (ZWNJ,U+200C): "f"_$CHAR(8204)_"i"
	set cnti=cnti+1,str(cnti)="f‌i",width(cnti)=2,ucp(cnti)="102,8204,105",utf8(cnti)="102,226,128,140,105",comments(cnti)="f $CHAR(8204) i -- Zero width non-joiner (ZWNJ, U+200C)"
	set cnti=cnti+1,str(cnti)="‌",width(cnti)=0,ucp(cnti)="8204",utf8(cnti)="226,128,140",comments(cnti)="$CHAR(8204) -- Zero width non-joiner (ZWNJ, U+200C)"
	;
	;Line Separator (U+2028): $CHAR(8232)
	set cnti=cnti+1,str(cnti)="f i",width(cnti)=-1,ucp(cnti)="102,8232,105",utf8(cnti)="102,226,128,168,105",comments(cnti)="f $CHAR(8232) i -- Line Separator (U+2028)" ; width is -1 because the unicode char is a general punctuation category character
	set cnti=cnti+1,str(cnti)=" ",width(cnti)=-1,ucp(cnti)="8232",utf8(cnti)="226,128,168",comments(cnti)="$CHAR(8232) -- Line Separator (U+2028)"
	;
	;Paragraph Separator (U+2029): "a"_$CHAR(8233)_"b"
	set cnti=cnti+1,str(cnti)="f i",width(cnti)=-1,ucp(cnti)="102,8233,105",utf8(cnti)="102,226,128,169,105",comments(cnti)="f $CHAR(8233) i -- Paragraph Separator (U+2029)"
	set cnti=cnti+1,str(cnti)=" ",width(cnti)=-1,ucp(cnti)="8233",utf8(cnti)="226,128,169",comments(cnti)="$CHAR(8233) -- Paragraph Separator (U+2029)"
	;
	;Some bidirectional formatting chars: $CHAR(8206,8207,8234,8235)
	set cnti=cnti+1,str(cnti)="‎‏‪‫",width(cnti)=-1,ucp(cnti)="8206,8207,8234,8235",utf8(cnti)="226,128,142,226,128,143,226,128,170,226,128,171",comments(cnti)="U+200E LRM, U+200F RLM, U+202A LEFT-TO-RIGHT embedding, U+202B R-L embedding"
	;
	;Grapheme Joiner U+034F
	set cnti=cnti+1,str(cnti)="f͏i",width(cnti)=2,ucp(cnti)="102,847,105",utf8(cnti)="102,205,143,105",comments(cnti)="f $CHAR(847) i -- Grapheme Joiner U+034F"
	;
	;Combining enclosing circle U+20DD
	set cnti=cnti+1,str(cnti)="f ⃝i",width(cnti)=3,ucp(cnti)="102,32,8413,105",utf8(cnti)="102,32,226,131,157,105",comments(cnti)="f $CHAR(8413) -- Combining enclosing circle U+20DD"
	set cnti=cnti+1,str(cnti)="f⃝⃝i",width(cnti)=2,ucp(cnti)="102,8413,8413,105",utf8(cnti)="102,226,131,157,226,131,157,105",comments(cnti)="f $CHAR(8413,8413) -- huh, two combining circles, doesn't make much sense, but should still work"
	; different combining characters, multiple combining characters on a single character
	set cnti=cnti+1,str(cnti)="f⃝̈ẍ̧̃i",width(cnti)=3,ucp(cnti)="102,8413,776,120,776,807,771,105",utf8(cnti)="102,226,131,157,204,136,120,204,136,204,167,204,131,105",comments(cnti)="f $CHAR(8413,8413) i -- huh, multiple combining characters on one character, doesn't make much sense, but should still work"
	;
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Indic samples
	; Samples taken from: http://www.trigeminal.com/samples/provincial.html
	; Hindi:
	set cnti=cnti+1,str(cnti)="यह लोग हिन्दी क्यों नहीं बोल सकते हैं ?",ucp(cnti)="2351,2361,32,2354,2379,2327,32,2361,2367,2344,2381,2342,2368,32,2325,2381,2351,2379,2306,32,2344,2361,2368,2306,32,2348,2379,2354,32,2360,2325,2340,2375,32,2361,2376,2306,32,63",utf8(cnti)="224,164,175,224,164,185,32,224,164,178,224,165,139,224,164,151,32,224,164,185,224,164,191,224,164,168,224,165,141,224,164,166,224,165,128,32,224,164,149,224,165,141,224,164,175,224,165,139,224,164,130,32,224,164,168,224,164,185,224,165,128,224,164,130,32,224,164,172,224,165,139,224,164,178,32,224,164,184,224,164,149,224,164,164,224,165,135,32,224,164,185,224,165,136,224,164,130,32,63",comments(cnti)="Hindi",width(cnti)=32
	; Bengali:
	set cnti=cnti+1,str(cnti)="ওরা েকন বাংলা বলেত পাের না ?",ucp(cnti)="2451,2480,2494,32,2503,2453,2472,32,2476,2494,2434,2482,2494,32,2476,2482,2503,2468,32,2474,2494,2503,2480,32,2472,2494,32,63",utf8(cnti)="224,166,147,224,166,176,224,166,190,32,224,167,135,224,166,149,224,166,168,32,224,166,172,224,166,190,224,166,130,224,166,178,224,166,190,32,224,166,172,224,166,178,224,167,135,224,166,164,32,224,166,170,224,166,190,224,167,135,224,166,176,32,224,166,168,224,166,190,32,63",comments(cnti)="Bengali",width(cnti)=28
	;
	; Gujarati:
	set cnti=cnti+1,str(cnti)="બદ્ધા લોકો ગુજરાતી કૅમ નથી બોલતા?",ucp(cnti)="2732,2726,2765,2727,2750,32,2738,2763,2709,2763,32,2711,2753,2716,2736,2750,2724,2752,32,2709,2757,2734,32,2728,2725,2752,32,2732,2763,2738,2724,2750,63",utf8(cnti)="224,170,172,224,170,166,224,171,141,224,170,167,224,170,190,32,224,170,178,224,171,139,224,170,149,224,171,139,32,224,170,151,224,171,129,224,170,156,224,170,176,224,170,190,224,170,164,224,171,128,32,224,170,149,224,171,133,224,170,174,32,224,170,168,224,170,165,224,171,128,32,224,170,172,224,171,139,224,170,178,224,170,164,224,170,190,63",comments(cnti)="Gujarati",width(cnti)=30
	;
	; Tamil:
	set cnti=cnti+1,str(cnti)="அவர்கள் ஏன் தமிழில் பேசக்கூடாது ?",ucp(cnti)="2949,2997,2992,3021,2965,2995,3021,32,2959,2985,3021,32,2980,2990,3007,2996,3007,2994,3021,32,2986,3015,2970,2965,3021,2965,3010,2975,3006,2980,3009,32,63",utf8(cnti)="224,174,133,224,174,181,224,174,176,224,175,141,224,174,149,224,174,179,224,175,141,32,224,174,143,224,174,169,224,175,141,32,224,174,164,224,174,174,224,174,191,224,174,180,224,174,191,224,174,178,224,175,141,32,224,174,170,224,175,135,224,174,154,224,174,149,224,175,141,224,174,149,224,175,130,224,174,159,224,174,190,224,174,164,224,175,129,32,63",comments(cnti)="Tamil",width(cnti)=28
	;
	; Telugu:
	set cnti=cnti+1,str(cnti)="తెలుగులో ఎందుకు మాట్లాడరు?",ucp(cnti)="3108,3142,3122,3137,3095,3137,3122,3147,32,3086,3074,3110,3137,3093,3137,32,3118,3134,3103,3149,3122,3134,3105,3120,3137,63",utf8(cnti)="224,176,164,224,177,134,224,176,178,224,177,129,224,176,151,224,177,129,224,176,178,224,177,139,32,224,176,142,224,176,130,224,176,166,224,177,129,224,176,149,224,177,129,32,224,176,174,224,176,190,224,176,159,224,177,141,224,176,178,224,176,190,224,176,161,224,176,176,224,177,129,63",comments(cnti)="Telugu",width(cnti)=21
	;
	; Kannada:
	set cnti=cnti+1,str(cnti)="ಅವರು ಕನ್ನಡ ಮಾತನಾಡಬಹುದಲ್ಲಾ?",ucp(cnti)="3205,3253,3248,3265,32,3221,3240,3277,3240,3233,32,3246,3262,3236,3240,3262,3233,3244,3257,3265,3238,3250,3277,3250,3262,63",utf8(cnti)="224,178,133,224,178,181,224,178,176,224,179,129,32,224,178,149,224,178,168,224,179,141,224,178,168,224,178,161,32,224,178,174,224,178,190,224,178,164,224,178,168,224,178,190,224,178,161,224,178,172,224,178,185,224,179,129,224,178,166,224,178,178,224,179,141,224,178,178,224,178,190,63",comments(cnti)="Kannada",width(cnti)=24
	;
	; Marathi:
	set cnti=cnti+1,str(cnti)="लोकांना मराठी का बोलता येत नाही?",ucp(cnti)="2354,2379,2325,2366,2306,2344,2366,32,2350,2352,2366,2336,2368,32,2325,2366,32,2348,2379,2354,2340,2366,32,2351,2375,2340,32,2344,2366,2361,2368,63",utf8(cnti)="224,164,178,224,165,139,224,164,149,224,164,190,224,164,130,224,164,168,224,164,190,32,224,164,174,224,164,176,224,164,190,224,164,160,224,165,128,32,224,164,149,224,164,190,32,224,164,172,224,165,139,224,164,178,224,164,164,224,164,190,32,224,164,175,224,165,135,224,164,164,32,224,164,168,224,164,190,224,164,185,224,165,128,63",comments(cnti)="Marathi",width(cnti)=30
	;
	; Sanskrit:
	set cnti=cnti+1,str(cnti)="ते किं संस्कृतः माम वदन्ति ?",ucp(cnti)="2340,2375,32,2325,2367,2306,32,2360,2306,2360,2381,2325,2371,2340,2307,32,2350,2366,2350,32,2357,2342,2344,2381,2340,2367,32,63",utf8(cnti)="224,164,164,224,165,135,32,224,164,149,224,164,191,224,164,130,32,224,164,184,224,164,130,224,164,184,224,165,141,224,164,149,224,165,131,224,164,164,224,164,131,32,224,164,174,224,164,190,224,164,174,32,224,164,181,224,164,166,224,164,168,224,165,141,224,164,164,224,164,191,32,63",comments(cnti)="Sanskrit",width(cnti)=22
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Some samples from U+10000-U+10FFFF
	set cnti=cnti+1,str(cnti)="𐀀𐀐𐀣𐀹𐁒𐂍𐂯",ucp(cnti)="65536,65552,65571,65593,65618,65677,65711",comments(cnti)="samples from $CHAR(65536-65711)"
	set utf8(cnti)="240,144,128,128,240,144,128,144,240,144,128,163,240,144,128,185,240,144,129,146,240,144,130,141,240,144,130,175"
	set cnti=cnti+1,str(cnti)="𐃔𐃼𐄧𐅕𐆆𐆺𐇱𐈫",ucp(cnti)="65748,65788,65831,65877,65926,65978,66033,66091",comments(cnti)="samples from $CHAR(65748-66091)",width(cnti)=-1
	set utf8(cnti)="240,144,131,148,240,144,131,188,240,144,132,167,240,144,133,149,240,144,134,134,240,144,134,186,240,144,135,177,240,144,136,171"
	set cnti=cnti+1,str(cnti)="𐉨𐊨𐋫𐌱𐍺𐏆𐐕𐑧",ucp(cnti)="66152,66216,66283,66353,66426,66502,66581,66663",comments(cnti)="samples from $CHAR(66152-66663)",width(cnti)=-1
	set utf8(cnti)="240,144,137,168,240,144,138,168,240,144,139,171,240,144,140,177,240,144,141,186,240,144,143,134,240,144,144,149,240,144,145,167"
	set cnti=cnti+1,str(cnti)="𘂳𘄟𘆎𘈀𘉵𘋭𘍨𘎡",ucp(cnti)="98483,98591,98702,98816,98933,99053,99176,99233",comments(cnti)="samples from $CHAR(98483-99233)",width(cnti)=-1
	set utf8(cnti)="240,152,130,179,240,152,132,159,240,152,134,142,240,152,136,128,240,152,137,181,240,152,139,173,240,152,141,168,240,152,142,161"
	set cnti=cnti+1,str(cnti)="𠞉𠟠𠠺𠢗𠣷𠥚𠧀𠨩",ucp(cnti)="133001,133088,133178,133271,133367,133466,133568,133673",width(cnti)=16,comments(cnti)="samples from $CHAR(133001-133673)"
	set utf8(cnti)="240,160,158,137,240,160,159,160,240,160,160,186,240,160,162,151,240,160,163,183,240,160,165,154,240,160,167,128,240,160,168,169"
	set cnti=cnti+1,str(cnti)="𠷶𠹜𠻅𠼱𠾠𡀒𡂇𡃿",ucp(cnti)="134646,134748,134853,134961,135072,135186,135303,135423",width(cnti)=16,comments(cnti)="samples from $CHAR(134646-135423)"
	set utf8(cnti)="240,160,183,182,240,160,185,156,240,160,187,133,240,160,188,177,240,160,190,160,240,161,128,146,240,161,130,135,240,161,131,191"
	set cnti=cnti+1,str(cnti)="𨻲𨼴𨽹𨿁𩀌𩁚𩂫𩃿",ucp(cnti)="167666,167732,167801,167873,167948,168026,168107,168191",width(cnti)=16,comments(cnti)="samples from $CHAR(167666-168191)"
	set utf8(cnti)="240,168,187,178,240,168,188,180,240,168,189,185,240,168,191,129,240,169,128,140,240,169,129,154,240,169,130,171,240,169,131,191"
	set cnti=cnti+1,str(cnti)="𱗚𱙌𱛁𱜹𱞴𱟭𱠩𱡨",ucp(cnti)="202202,202316,202433,202553,202676,202733,202793,202856",width(cnti)=-1,comments(cnti)="samples from $CHAR(202202-202856)"
	set utf8(cnti)="240,177,151,154,240,177,153,140,240,177,155,129,240,177,156,185,240,177,158,180,240,177,159,173,240,177,160,169,240,177,161,168"
	set cnti=cnti+1,str(cnti)="𭖦𭗷𭙋𭚢𭛼𭝙𭞹𭠜",ucp(cnti)="185766,185847,185931,186018,186108,186201,186297,186396",width(cnti)=-1,comments(cnti)="samples from $CHAR(185766-186396)"
	set utf8(cnti)="240,173,150,166,240,173,151,183,240,173,153,139,240,173,154,162,240,173,155,188,240,173,157,153,240,173,158,185,240,173,160,156"
	set cnti=cnti+1,str(cnti)="𺀝𺁱𺃈𺄢𺅿𺇟𺉂𺊨",ucp(cnti)="237597,237681,237768,237858,237951,238047,238146,238248",width(cnti)=-1,comments(cnti)="samples from $CHAR(237597-238248)"
	set utf8(cnti)="240,186,128,157,240,186,129,177,240,186,131,136,240,186,132,162,240,186,133,191,240,186,135,159,240,186,137,130,240,186,138,168"
	set cnti=cnti+1,str(cnti)="񆪗񆫮񆭈񆮥񆰅񆱨񆳎񆴷",ucp(cnti)="289431,289518,289608,289701,289797,289896,289998,290103",comments(cnti)="samples from $CHAR(289431-290103)",width(cnti)=-1
	set utf8(cnti)="241,134,170,151,241,134,171,174,241,134,173,136,241,134,174,165,241,134,176,133,241,134,177,168,241,134,179,142,241,134,180,183"
	set cnti=cnti+1,str(cnti)="𨚠𨚑𨘪𨕫𨑔𨋥𨄞𧻿",ucp(cnti)="165536,165521,165418,165227,164948,164581,164126,163583",width(cnti)=16,comments(cnti)="samples from $CHAR(165536-163583)"
	set utf8(cnti)="240,168,154,160,240,168,154,145,240,168,152,170,240,168,149,171,240,168,145,148,240,168,139,165,240,168,132,158,240,167,187,191"
	set cnti=cnti+1,str(cnti)="𧲈𧦹𧚒𧌓𦼼𦬍𦚆𦆧",ucp(cnti)="162952,162233,161426,160531,159548,158477,157318,156071",width(cnti)=16,comments(cnti)="samples from $CHAR(162952-156071)"
	set utf8(cnti)="240,167,178,136,240,167,166,185,240,167,154,146,240,167,140,147,240,166,188,188,240,166,172,141,240,166,154,134,240,166,134,167"
	set cnti=cnti+1,str(cnti)="𥱰𥛡𥃺𤪻𤐤𣴵𣗮𢹏",ucp(cnti)="154736,153313,151802,150203,148516,146741,144878,142927",width(cnti)=16,comments(cnti)="samples from $CHAR(154736-142927)"
	set utf8(cnti)="240,165,177,176,240,165,155,161,240,165,131,186,240,164,170,187,240,164,144,164,240,163,180,181,240,163,151,174,240,162,185,143"
	set cnti=cnti+1,str(cnti)="𢙘𡸉𡕢𠱣𠌌",ucp(cnti)="140888,138761,136546,134243,131852",width(cnti)=10,comments(cnti)="samples from $CHAR(140888-124151)"
	set utf8(cnti)="240,162,153,152,240,161,184,137,240,161,149,162,240,160,177,163,240,160,140,140"
	set cnti=cnti+1,str(cnti)="𝩀𜼱𜏊𛠋𚯴𙾅𙊾𘖟",ucp(cnti)="121408,118577,115658,112651,109556,106373,103102,99743",comments(cnti)="samples from $CHAR(121408-99743)",width(cnti)=-1
	set utf8(cnti)="240,157,169,128,240,156,188,177,240,156,143,138,240,155,160,139,240,154,175,180,240,153,190,133,240,153,138,190,240,152,150,159"
	set cnti=cnti+1,str(cnti)="𗠨𖩙𕰲𔶳𓻜𒾭𒀦𑁇",ucp(cnti)="96296,92761,89138,85427,81628,77741,73766,69703",comments(cnti)="samples from $CHAR(96296-69703)",width(cnti)=-1
	set utf8(cnti)="240,151,160,168,240,150,169,153,240,149,176,178,240,148,182,179,240,147,187,156,240,146,190,173,240,146,128,166,240,145,129,135"
	set cnti=cnti+1,str(cnti)="󿪿󿩧󿨏󿦷󿥟󿤇󿢯󿡗",ucp(cnti)="1047231,1047143,1047055,1046967,1046879,1046791,1046703,1046615",comments(cnti)="samples from $CHAR(1047231-1046615)",width(cnti)=-1
	set utf8(cnti)="243,191,170,191,243,191,169,167,243,191,168,143,243,191,166,183,243,191,165,159,243,191,164,135,243,191,162,175,243,191,161,151"
	set cnti=cnti+1,str(cnti)="󳒿󳑧󳐏󳎷󳍟󳌇󳊯󳉗",ucp(cnti)="996543,996455,996367,996279,996191,996103,996015,995927",comments(cnti)="samples from $CHAR(996543-995927)",width(cnti)=-1
	set utf8(cnti)="243,179,146,191,243,179,145,167,243,179,144,143,243,179,142,183,243,179,141,159,243,179,140,135,243,179,138,175,243,179,137,151"
	set cnti=cnti+1,str(cnti)="󦺿󦹧󦸏󦶷󦵟󦴇󦲯󦱗",ucp(cnti)="945855,945767,945679,945591,945503,945415,945327,945239",comments(cnti)="samples from $CHAR(945855-945239)",width(cnti)=-1
	set utf8(cnti)="243,166,186,191,243,166,185,167,243,166,184,143,243,166,182,183,243,166,181,159,243,166,180,135,243,166,178,175,243,166,177,151"
	set cnti=cnti+1,str(cnti)="󖚿󖙧󖘏󖖷󖕟󖔇󖒯󖑗",ucp(cnti)="878271,878183,878095,878007,877919,877831,877743,877655",comments(cnti)="samples from $CHAR(878271-877655)",width(cnti)=-1
	set utf8(cnti)="243,150,154,191,243,150,153,167,243,150,152,143,243,150,150,183,243,150,149,159,243,150,148,135,243,150,146,175,243,150,145,151"
	set cnti=cnti+1,str(cnti)="񀁿񀀧𿿏𿽷𿼟𿻇𿹯𿸗",ucp(cnti)="262271,262183,262095,262007,261919,261831,261743,261655",width(cnti)=-1,comments(cnti)="samples from $CHAR(262271-261655)"
	set utf8(cnti)="241,128,129,191,241,128,128,167,240,191,191,143,240,191,189,183,240,191,188,159,240,191,187,135,240,191,185,175,240,191,184,151"
	set cnti=cnti+1,str(cnti)="􏾧􏽏􏻷􏺟􏹇􏷯􏶗",ucp(cnti)="1114023,1113935,1113847,1113759,1113671,1113583,1113495",comments(cnti)="samples from $CHAR(1114111-1113495)",width(cnti)=-1
	set utf8(cnti)="244,143,190,167,244,143,189,143,244,143,187,183,244,143,186,159,244,143,185,135,244,143,183,175,244,143,182,151"
	set cnti=cnti+1,str(cnti)="􏴿􏳧􏲏􏰷􏯟􏮇􏬯􏫗",ucp(cnti)="1113407,1113319,1113231,1113143,1113055,1112967,1112879,1112791",comments(cnti)="samples from $CHAR(1113407-1112791)",width(cnti)=-1
	set utf8(cnti)="244,143,180,191,244,143,179,167,244,143,178,143,244,143,176,183,244,143,175,159,244,143,174,135,244,143,172,175,244,143,171,151"
	set cnti=cnti+1,str(cnti)="􏩿􏨧􏧏􏥷􏤟􏣇􏡯􏠗",ucp(cnti)="1112703,1112615,1112527,1112439,1112351,1112263,1112175,1112087",comments(cnti)="samples from $CHAR(1112703-1112087)",width(cnti)=-1
	set utf8(cnti)="244,143,169,191,244,143,168,167,244,143,167,143,244,143,165,183,244,143,164,159,244,143,163,135,244,143,161,175,244,143,160,151"
	set cnti=cnti+1,str(cnti)="􏞿􏝧􏜏􏚷􏙟􏘇􏖯􏕗",ucp(cnti)="1111999,1111911,1111823,1111735,1111647,1111559,1111471,1111383",comments(cnti)="samples from $CHAR(1111999-1111383)",width(cnti)=-1
	set utf8(cnti)="244,143,158,191,244,143,157,167,244,143,156,143,244,143,154,183,244,143,153,159,244,143,152,135,244,143,150,175,244,143,149,151"
	set cnti=cnti+1,str(cnti)="􏓿􏒧􏑏􏏷􏎟􏍇􏋯􏊗",ucp(cnti)="1111295,1111207,1111119,1111031,1110943,1110855,1110767,1110679",comments(cnti)="samples from $CHAR(1111295-1110679)",width(cnti)=-1
	set utf8(cnti)="244,143,147,191,244,143,146,167,244,143,145,143,244,143,143,183,244,143,142,159,244,143,141,135,244,143,139,175,244,143,138,151"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; would this be useful???
	; set a onestring (that is also part of the str() array:
	; onestring should have all types of valid characters: one-byte, two-byte, three-byte, four-byte, (non)graphical, sentinel, (non)printable, ...
	; to be used where it is not possible to test all elements of str(), but this onestring is representative enough.
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Markus Kuhn's Stress Tests
	;http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt
	; Some of the tests are valid characters (boundary conditions). The valid samples will be included here,
	; and the invalid samples will be tested through lbadchar.m (which right now is generated by genbadchars.m)
	;
	; 2  Boundary condition test cases
	;
	; 2.1  First possible sequence of a certain length
	; 2.1.1  1 byte  (U-00000000) will be present atop of this routine near ASCII section
	; To ensure we group all single byt character strings together
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="128",width(cnti)=-1,utf8(cnti)="194,128",comments(cnti)="2.1.2  2 bytes (U-00000080) UTF8: C2 80     UTF8(dec): 194 128"
	set cnti=cnti+1,str(cnti)="ࠀ",ucp(cnti)="2048",width(cnti)=-1,utf8(cnti)="224,160,128",comments(cnti)="2.1.3  3 bytes (U-00000800) UTF8: E0 A0 80 UTF8(dec): 224 160 128"
	set cnti=cnti+1,str(cnti)="𐀀",ucp(cnti)="65536",width(cnti)=1,utf8(cnti)="240,144,128,128",comments(cnti)="2.1.4  4 bytes (U-00010000) UTF8: F0 90 80 80       UTF8(dec): 240 144 128 128"
	;
	; 2.2  Last possible sequence of a certain length
	; (U-0000007F) UTF8: 7F        UTF8(dec):127 will be atop of this routine near ASCII section
	; this is to ensure we group all single byte character strings together.
	set cnti=cnti+1,str(cnti)="߿",ucp(cnti)="2047",width(cnti)=-1,utf8(cnti)="223,191",comments(cnti)="2.2.2  2 bytes (U-000007FF) UTF8: DF BF     UTF8(dec): 223 191"
	; U+nFFFE and U+nFFFF are invalid
;	set cnti=cnti+1,str(cnti)="￿",ucp(cnti)="65535",width(cnti)=-1,utf8(cnti)="239,191,191",comments(cnti)="2.2.3  3 bytes (U-0000FFFF) UTF8: EF BF BF  UTF8(dec): 239 191 191"
	;
	;2.3  Other boundary conditions
	;
	set cnti=cnti+1,str(cnti)="퟿",ucp(cnti)="55295",width(cnti)=-1,utf8(cnti)="237,159,191",comments(cnti)="2.3.1  U-0000D7FF = UTF8: ED 9F BF  UTF8(dec): 237 159 191"
	set cnti=cnti+1,str(cnti)="",ucp(cnti)="57344",width(cnti)=-1,utf8(cnti)="238,128,128",comments(cnti)="2.3.2  U-0000E000 = UTF8: EE 80 80  UTF8(dec): 238 128 128"
	set cnti=cnti+1,str(cnti)="�",ucp(cnti)="65533",width(cnti)=-1,utf8(cnti)="239,191,189",comments(cnti)="2.3.3  U-0000FFFD = UTF8: EF BF BD  UTF8(dec): 239 191 189"
	; U+nFFFE and U+nFFFF are invalid
	;set cnti=cnti+1,str(cnti)="􏿿",ucp(cnti)="1114111",width(cnti)=-1,utf8(cnti)="244,143,191,191",comments(cnti)="2.3.4  U-0010FFFF = UTF8: F4 8F BF BF       UTF8(dec): 244 143 191 191"
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set cntstrmbytee=cnti ; this varibale will be used by all functions when they need only strings that has multibyte chars in it.
	do lnumeric
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Fromt this point on all badchar samples begin. So in future if we need to add more strings to unicodesampledata it
	; SHOULD be added before this call.
	do lbadchar
	quit
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
wrapup	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set cntstr=cnti
derived	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Calculate the derived arrays
	set maxucplen=0,maxutf8len=0,maxwidth=0
	for cnti=1:1:cntstr  do
	. if '$DATA(ucplen(cnti)) set ucplen(cnti)=$LENGTH(ucp(cnti),",")
	. if (ucplen(cnti)>maxucplen) set maxucplen=ucplen(cnti)
	for cnti=1:1:cntstr  do
	. if '$DATA(utf8len(cnti)) set utf8len(cnti)=$LENGTH(utf8(cnti),",")
	. if (utf8len(cnti)>maxutf8len) set maxutf8len=utf8len(cnti)
	for cnti=1:1:cntstr do
	. if '$DATA(width(cnti)) set width(cnti)=ucplen(cnti)
	. if (width(cnti)>maxwidth) set maxwidth=width(cnti)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set u="do kill^unicodesampledata do ^unicodesampledata"
	set p="do print^unicodesampledata(1)"
	set ps="do print^unicodesampledata(0)"
	set check="do print^unicodesampledata(2)" ; check the arrays, as much as possible
	set l="zlink ""unicodesampledata"""
	set k="do kill^unicodesampledata"
	set putf8="do putf8^unicodesampledata"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	quit
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lbadchar ; also have a section of characters that would trigger the BADCHAR error if view "BADCHAR" is enabled.
	; we can have this section controlled by an argument or a local variable. We should test some mal-formed characters if we can, but if we are testing character based functions, they would error out, so we should not define them
	;
	; if badcharsamples is defined as is equal to 0, do not define BADCHAR samples. i.e. by default it will define BADCHAR samples.
	if ($DATA(badcharsamples)&(0=$GET(badcharsamples))) quit
	;
	; malformed byte sequences
	set cntstrbadchars=cnti+1	; start
	;
 	;tmp tmp tmp remove this call once $CHAR is tested and proven so we can use lbadchar without generating it
	do ^genbadchars
 	;tmp tmp tmp end
	do ^lbadchar ; use lbadchar.m generated from genbadchars.m(using V51000)
	;
	; the following can remain here, since they are well formed utf-8, but disallowed characters.
	;- any character in the surrogate range (U+D800-U+DFFF)
	set cnti=cnti+1,str(cnti)="���",ucp(cnti)="-1",width(cnti)=-1,utf8(cnti)="237,160,128",comments(cnti)="$CHAR(55296) -- surrogate range"
	set cnti=cnti+1,str(cnti)="���",ucp(cnti)="-1",width(cnti)=-1,utf8(cnti)="237,163,191",comments(cnti)="$CHAR(55551) -- surrogate range"
	set cnti=cnti+1,str(cnti)="���",ucp(cnti)="-1",width(cnti)=-1,utf8(cnti)="237,167,153",comments(cnti)="$CHAR(55769) -- surrogate range"
	set cnti=cnti+1,str(cnti)="���",ucp(cnti)="-1",width(cnti)=-1,utf8(cnti)="237,188,128",comments(cnti)="$CHAR(57088) -- surrogate range"
	set cnti=cnti+1,str(cnti)="���",ucp(cnti)="-1",width(cnti)=-1,utf8(cnti)="237,191,176",comments(cnti)="$CHAR(57327) -- surrogate range"
	set cnti=cnti+1,str(cnti)="���",ucp(cnti)="-1",width(cnti)=-1,utf8(cnti)="237,191,191",comments(cnti)="$CHAR(57343) -- surrogate range"
	;
	; sentinels
	;- The sentinels should remain here  as they issue BADCHAR error with VIEW:"BADCHAR" setting:
	; keep these separate cntstrsentinels[s,e] variables as well for $CHAR checks which gives INVDLRCVAL and not BADCHAR
	set cntstrsentinelss=cnti+1
	;- All 32 code point values between U+FDD0 and U+FDEF
	set cnti=cnti+1,str(cnti)="﷐﷑﷒﷓﷔﷕﷖﷗",width(cnti)=-1,ucp(cnti)="64976,64977,64978,64979,64980,64981,64982,64983",comments(cnti)="samples from $CHAR(64976-64983)"
	set utf8(cnti)="239,183,144,239,183,145,239,183,146,239,183,147,239,183,148,239,183,149,239,183,150,239,183,151"
	set cnti=cnti+1,str(cnti)="﷘﷙﷚﷛﷜﷝﷞﷟",width(cnti)=-1,ucp(cnti)="64984,64985,64986,64987,64988,64989,64990,64991",comments(cnti)="samples from $CHAR(64984-64991)"
	set utf8(cnti)="239,183,152,239,183,153,239,183,154,239,183,155,239,183,156,239,183,157,239,183,158,239,183,159"
	set cnti=cnti+1,str(cnti)="﷠﷡﷢﷣﷤﷥﷦﷧",width(cnti)=-1,ucp(cnti)="64992,64993,64994,64995,64996,64997,64998,64999",comments(cnti)="samples from $CHAR(64992-64999)"
	set utf8(cnti)="239,183,160,239,183,161,239,183,162,239,183,163,239,183,164,239,183,165,239,183,166,239,183,167"
	set cnti=cnti+1,str(cnti)="﷨﷩﷪﷫﷬﷭﷮﷯",width(cnti)=-1,ucp(cnti)="65000,65001,65002,65003,65004,65005,65006,65007",comments(cnti)="samples from $CHAR(65000-65007)"
	set utf8(cnti)="239,183,168,239,183,169,239,183,170,239,183,171,239,183,172,239,183,173,239,183,174,239,183,175"
	;
	;- All 34 code points U+nFFFE and U+nFFFF where n is [0x0,0x10]
	set cnti=cnti+1,str(cnti)="￾🿾𯿾𿿾񏿾񟿾񯿾񿿾",width(cnti)=-1,ucp(cnti)="65534",comments(cnti)="samples from $CHAR(65534-524286)"
	set utf8(cnti)="239,191,190,240,159,191,190,240,175,191,190,240,191,191,190,241,143,191,190,241,159,191,190,241,175,191,190,241,191,191,190"
	set cnti=cnti+1,str(cnti)="򏿾򟿾򯿾򿿾󏿾󟿾󯿾󿿾􏿾",width(cnti)=-1,ucp(cnti)="589822",comments(cnti)="samples from $CHAR(589822-1114110)"
	set utf8(cnti)="242,143,191,190,242,159,191,190,242,175,191,190,242,191,191,190,243,143,191,190,243,159,191,190,243,175,191,190,243,191,191,190,244,143,191,190"
	set cntstrsentinelse=cnti
	;- code points greater than 1114111 (U+10FFFF)
	set cnti=cnti+1,str(cnti)="����",ucp(cnti)="1114112",width(cnti)=-1,utf8(cnti)="244,144,128,128",comments(cnti)="$CHAR(1114112)"
	set cnti=cnti+1,str(cnti)="����������������",ucp(cnti)="1114555",width(cnti)=-1,comments(cnti)="samples from $CHAR(1114555-1114606)"
	set utf8(cnti)="244,144,134,187,244,144,135,140,244,144,135,157,244,144,135,174"
	;
	set cntstrbadchare=cnti		; end
	;
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	quit
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lnumeric
	if (0=$DATA(cnti)) set cnti=0 ;initialization is necessary if lnumeric^unicodesampledata is called explicitly
	set cntstrnumberss=cnti+1
	; numbers
	; to be used in tests where numbers may be used,
	set cnti=cnti+1,str(cnti)="1234",comments(cnti)="numbers",ucp(cnti)="49,50,51,52",utf8(cnti)="49,50,51,52"
	set cnti=cnti+1,str(cnti)="0.34",comments(cnti)="numbers",ucp(cnti)="48,46,51,52",utf8(cnti)="48,46,51,52"
	set cnti=cnti+1,str(cnti)="-0.34",comments(cnti)="numbers",ucp(cnti)="45,48,46,51,52",utf8(cnti)="45,48,46,51,52"
	set cnti=cnti+1,str(cnti)="1E6",comments(cnti)="numbers, note that $LENGTH(""1E6"")'=$LENGTH(+""1E6"")",ucp(cnti)="49,69,54",utf8(cnti)="49,69,54"
	set cnti=cnti+1,str(cnti)="1.468E3",comments(cnti)="numbers",ucp(cnti)="49,46,52,54,56,69,51",utf8(cnti)="49,46,52,54,56,69,51"
	set cntstrnumberse=cnti+1
	;
	;set cnti=cnti+1,str(cnti)="#",ucp(cnti)="35",utf8(cnti)="35",comments(cnti)="NUMBER SIGN" ; it is not a number by itself
	set cnti=cnti+1,str(cnti)="0",ucp(cnti)="48",utf8(cnti)="48",comments(cnti)="DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="1",ucp(cnti)="49",utf8(cnti)="49",comments(cnti)="DIGIT ONE"
	set cnti=cnti+1,str(cnti)="2",ucp(cnti)="50",utf8(cnti)="50",comments(cnti)="DIGIT TWO"
	set cnti=cnti+1,str(cnti)="3",ucp(cnti)="51",utf8(cnti)="51",comments(cnti)="DIGIT THREE"
	set cnti=cnti+1,str(cnti)="4",ucp(cnti)="52",utf8(cnti)="52",comments(cnti)="DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="5",ucp(cnti)="53",utf8(cnti)="53",comments(cnti)="DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="6",ucp(cnti)="54",utf8(cnti)="54",comments(cnti)="DIGIT SIX"
	set cnti=cnti+1,str(cnti)="7",ucp(cnti)="55",utf8(cnti)="55",comments(cnti)="DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="8",ucp(cnti)="56",utf8(cnti)="56",comments(cnti)="DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="9",ucp(cnti)="57",utf8(cnti)="57",comments(cnti)="DIGIT NINE"
	set cnti=cnti+1,str(cnti)="²",ucp(cnti)="178",utf8(cnti)="194,178",comments(cnti)="SUPERSCRIPT TWO"
	set cnti=cnti+1,str(cnti)="³",ucp(cnti)="179",utf8(cnti)="194,179",comments(cnti)="SUPERSCRIPT THREE"
	set cnti=cnti+1,str(cnti)="¹",ucp(cnti)="185",utf8(cnti)="194,185",comments(cnti)="SUPERSCRIPT ONE"
	;set cnti=cnti+1,str(cnti)="ʹ",ucp(cnti)="884",utf8(cnti)="205,180",comments(cnti)="GREEK NUMERAL SIGN" ; it is not a number by itself
	;set cnti=cnti+1,str(cnti)="͵",ucp(cnti)="885",utf8(cnti)="205,181",comments(cnti)="GREEK LOWER NUMERAL SIGN" ; it is not a number by itself
	;set cnti=cnti+1,str(cnti)="؀",ucp(cnti)="1536",utf8(cnti)="216,128",comments(cnti)="ARABIC NUMBER SIGN" ; it is not a number by itself
	;;;
	; we start numerics here to ensure str contains only unicode numeric literal and only one at that.This way there wil be a loop covering all such chars in patnumeric test.
	set cntstrnumerics=cnti+1
	set cnti=cnti+1,str(cnti)="٠",ucp(cnti)="1632",utf8(cnti)="217,160",comments(cnti)="ARABIC-INDIC DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="١",ucp(cnti)="1633",utf8(cnti)="217,161",comments(cnti)="ARABIC-INDIC DIGIT ONE"
	set cnti=cnti+1,str(cnti)="٢",ucp(cnti)="1634",utf8(cnti)="217,162",comments(cnti)="ARABIC-INDIC DIGIT TWO"
	set cnti=cnti+1,str(cnti)="٣",ucp(cnti)="1635",utf8(cnti)="217,163",comments(cnti)="ARABIC-INDIC DIGIT THREE"
	set cnti=cnti+1,str(cnti)="٤",ucp(cnti)="1636",utf8(cnti)="217,164",comments(cnti)="ARABIC-INDIC DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="٥",ucp(cnti)="1637",utf8(cnti)="217,165",comments(cnti)="ARABIC-INDIC DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="٦",ucp(cnti)="1638",utf8(cnti)="217,166",comments(cnti)="ARABIC-INDIC DIGIT SIX"
	set cnti=cnti+1,str(cnti)="٧",ucp(cnti)="1639",utf8(cnti)="217,167",comments(cnti)="ARABIC-INDIC DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="٨",ucp(cnti)="1640",utf8(cnti)="217,168",comments(cnti)="ARABIC-INDIC DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="٩",ucp(cnti)="1641",utf8(cnti)="217,169",comments(cnti)="ARABIC-INDIC DIGIT NINE"
	set cnti=cnti+1,str(cnti)="۰",ucp(cnti)="1776",utf8(cnti)="219,176",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="۱",ucp(cnti)="1777",utf8(cnti)="219,177",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT ONE"
	set cnti=cnti+1,str(cnti)="۲",ucp(cnti)="1778",utf8(cnti)="219,178",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT TWO"
	set cnti=cnti+1,str(cnti)="۳",ucp(cnti)="1779",utf8(cnti)="219,179",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT THREE"
	set cnti=cnti+1,str(cnti)="۴",ucp(cnti)="1780",utf8(cnti)="219,180",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="۵",ucp(cnti)="1781",utf8(cnti)="219,181",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="۶",ucp(cnti)="1782",utf8(cnti)="219,182",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT SIX"
	set cnti=cnti+1,str(cnti)="۷",ucp(cnti)="1783",utf8(cnti)="219,183",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="۸",ucp(cnti)="1784",utf8(cnti)="219,184",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="۹",ucp(cnti)="1785",utf8(cnti)="219,185",comments(cnti)="EXTENDED ARABIC-INDIC DIGIT NINE"
	set cnti=cnti+1,str(cnti)="०",ucp(cnti)="2406",utf8(cnti)="224,165,166",comments(cnti)="DEVANAGARI DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="१",ucp(cnti)="2407",utf8(cnti)="224,165,167",comments(cnti)="DEVANAGARI DIGIT ONE"
	set cnti=cnti+1,str(cnti)="२",ucp(cnti)="2408",utf8(cnti)="224,165,168",comments(cnti)="DEVANAGARI DIGIT TWO"
	set cnti=cnti+1,str(cnti)="३",ucp(cnti)="2409",utf8(cnti)="224,165,169",comments(cnti)="DEVANAGARI DIGIT THREE"
	set cnti=cnti+1,str(cnti)="४",ucp(cnti)="2410",utf8(cnti)="224,165,170",comments(cnti)="DEVANAGARI DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="५",ucp(cnti)="2411",utf8(cnti)="224,165,171",comments(cnti)="DEVANAGARI DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="६",ucp(cnti)="2412",utf8(cnti)="224,165,172",comments(cnti)="DEVANAGARI DIGIT SIX"
	set cnti=cnti+1,str(cnti)="७",ucp(cnti)="2413",utf8(cnti)="224,165,173",comments(cnti)="DEVANAGARI DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="८",ucp(cnti)="2414",utf8(cnti)="224,165,174",comments(cnti)="DEVANAGARI DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="९",ucp(cnti)="2415",utf8(cnti)="224,165,175",comments(cnti)="DEVANAGARI DIGIT NINE"
	set cnti=cnti+1,str(cnti)="௧",ucp(cnti)="3047",utf8(cnti)="224,175,167",comments(cnti)="TAMIL DIGIT ONE"
	set cnti=cnti+1,str(cnti)="௨",ucp(cnti)="3048",utf8(cnti)="224,175,168",comments(cnti)="TAMIL DIGIT TWO"
	set cnti=cnti+1,str(cnti)="௩",ucp(cnti)="3049",utf8(cnti)="224,175,169",comments(cnti)="TAMIL DIGIT THREE"
	set cnti=cnti+1,str(cnti)="௪",ucp(cnti)="3050",utf8(cnti)="224,175,170",comments(cnti)="TAMIL DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="௫",ucp(cnti)="3051",utf8(cnti)="224,175,171",comments(cnti)="TAMIL DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="௬",ucp(cnti)="3052",utf8(cnti)="224,175,172",comments(cnti)="TAMIL DIGIT SIX"
	set cnti=cnti+1,str(cnti)="௭",ucp(cnti)="3053",utf8(cnti)="224,175,173",comments(cnti)="TAMIL DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="௮",ucp(cnti)="3054",utf8(cnti)="224,175,174",comments(cnti)="TAMIL DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="௯",ucp(cnti)="3055",utf8(cnti)="224,175,175",comments(cnti)="TAMIL DIGIT NINE"
	;set cnti=cnti+1,str(cnti)="௺",ucp(cnti)="3066",utf8(cnti)="224,175,186",comments(cnti)="TAMIL NUMBER SIGN" ; it is not a number by itself
	set cnti=cnti+1,str(cnti)="౦",ucp(cnti)="3174",utf8(cnti)="224,177,166",comments(cnti)="TELUGU DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="౧",ucp(cnti)="3175",utf8(cnti)="224,177,167",comments(cnti)="TELUGU DIGIT ONE"
	set cnti=cnti+1,str(cnti)="౨",ucp(cnti)="3176",utf8(cnti)="224,177,168",comments(cnti)="TELUGU DIGIT TWO"
	set cnti=cnti+1,str(cnti)="౩",ucp(cnti)="3177",utf8(cnti)="224,177,169",comments(cnti)="TELUGU DIGIT THREE"
	set cnti=cnti+1,str(cnti)="౪",ucp(cnti)="3178",utf8(cnti)="224,177,170",comments(cnti)="TELUGU DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="౫",ucp(cnti)="3179",utf8(cnti)="224,177,171",comments(cnti)="TELUGU DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="౬",ucp(cnti)="3180",utf8(cnti)="224,177,172",comments(cnti)="TELUGU DIGIT SIX"
	set cnti=cnti+1,str(cnti)="౭",ucp(cnti)="3181",utf8(cnti)="224,177,173",comments(cnti)="TELUGU DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="౮",ucp(cnti)="3182",utf8(cnti)="224,177,174",comments(cnti)="TELUGU DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="౯",ucp(cnti)="3183",utf8(cnti)="224,177,175",comments(cnti)="TELUGU DIGIT NINE"
	set cnti=cnti+1,str(cnti)="೦",ucp(cnti)="3302",utf8(cnti)="224,179,166",comments(cnti)="KANNADA DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="೧",ucp(cnti)="3303",utf8(cnti)="224,179,167",comments(cnti)="KANNADA DIGIT ONE"
	set cnti=cnti+1,str(cnti)="೨",ucp(cnti)="3304",utf8(cnti)="224,179,168",comments(cnti)="KANNADA DIGIT TWO"
	set cnti=cnti+1,str(cnti)="೩",ucp(cnti)="3305",utf8(cnti)="224,179,169",comments(cnti)="KANNADA DIGIT THREE"
	set cnti=cnti+1,str(cnti)="೪",ucp(cnti)="3306",utf8(cnti)="224,179,170",comments(cnti)="KANNADA DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="೫",ucp(cnti)="3307",utf8(cnti)="224,179,171",comments(cnti)="KANNADA DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="೬",ucp(cnti)="3308",utf8(cnti)="224,179,172",comments(cnti)="KANNADA DIGIT SIX"
	set cnti=cnti+1,str(cnti)="೭",ucp(cnti)="3309",utf8(cnti)="224,179,173",comments(cnti)="KANNADA DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="೮",ucp(cnti)="3310",utf8(cnti)="224,179,174",comments(cnti)="KANNADA DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="೯",ucp(cnti)="3311",utf8(cnti)="224,179,175",comments(cnti)="KANNADA DIGIT NINE"
	set cnti=cnti+1,str(cnti)="൦",ucp(cnti)="3430",utf8(cnti)="224,181,166",comments(cnti)="MALAYALAM DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="൧",ucp(cnti)="3431",utf8(cnti)="224,181,167",comments(cnti)="MALAYALAM DIGIT ONE"
	set cnti=cnti+1,str(cnti)="൨",ucp(cnti)="3432",utf8(cnti)="224,181,168",comments(cnti)="MALAYALAM DIGIT TWO"
	set cnti=cnti+1,str(cnti)="൩",ucp(cnti)="3433",utf8(cnti)="224,181,169",comments(cnti)="MALAYALAM DIGIT THREE"
	set cnti=cnti+1,str(cnti)="൪",ucp(cnti)="3434",utf8(cnti)="224,181,170",comments(cnti)="MALAYALAM DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="൫",ucp(cnti)="3435",utf8(cnti)="224,181,171",comments(cnti)="MALAYALAM DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="൬",ucp(cnti)="3436",utf8(cnti)="224,181,172",comments(cnti)="MALAYALAM DIGIT SIX"
	set cnti=cnti+1,str(cnti)="൭",ucp(cnti)="3437",utf8(cnti)="224,181,173",comments(cnti)="MALAYALAM DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="൮",ucp(cnti)="3438",utf8(cnti)="224,181,174",comments(cnti)="MALAYALAM DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="൯",ucp(cnti)="3439",utf8(cnti)="224,181,175",comments(cnti)="MALAYALAM DIGIT NINE"
	set cnti=cnti+1,str(cnti)="๐",ucp(cnti)="3664",utf8(cnti)="224,185,144",comments(cnti)="THAI DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="๑",ucp(cnti)="3665",utf8(cnti)="224,185,145",comments(cnti)="THAI DIGIT ONE"
	set cnti=cnti+1,str(cnti)="๒",ucp(cnti)="3666",utf8(cnti)="224,185,146",comments(cnti)="THAI DIGIT TWO"
	set cnti=cnti+1,str(cnti)="๓",ucp(cnti)="3667",utf8(cnti)="224,185,147",comments(cnti)="THAI DIGIT THREE"
	set cnti=cnti+1,str(cnti)="๔",ucp(cnti)="3668",utf8(cnti)="224,185,148",comments(cnti)="THAI DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="๕",ucp(cnti)="3669",utf8(cnti)="224,185,149",comments(cnti)="THAI DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="๖",ucp(cnti)="3670",utf8(cnti)="224,185,150",comments(cnti)="THAI DIGIT SIX"
	set cnti=cnti+1,str(cnti)="๗",ucp(cnti)="3671",utf8(cnti)="224,185,151",comments(cnti)="THAI DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="๘",ucp(cnti)="3672",utf8(cnti)="224,185,152",comments(cnti)="THAI DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="๙",ucp(cnti)="3673",utf8(cnti)="224,185,153",comments(cnti)="THAI DIGIT NINE"
	set cnti=cnti+1,str(cnti)="໐",ucp(cnti)="3792",utf8(cnti)="224,187,144",comments(cnti)="LAO DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="໑",ucp(cnti)="3793",utf8(cnti)="224,187,145",comments(cnti)="LAO DIGIT ONE"
	set cnti=cnti+1,str(cnti)="໒",ucp(cnti)="3794",utf8(cnti)="224,187,146",comments(cnti)="LAO DIGIT TWO"
	set cnti=cnti+1,str(cnti)="໓",ucp(cnti)="3795",utf8(cnti)="224,187,147",comments(cnti)="LAO DIGIT THREE"
	set cnti=cnti+1,str(cnti)="໔",ucp(cnti)="3796",utf8(cnti)="224,187,148",comments(cnti)="LAO DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="໕",ucp(cnti)="3797",utf8(cnti)="224,187,149",comments(cnti)="LAO DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="໖",ucp(cnti)="3798",utf8(cnti)="224,187,150",comments(cnti)="LAO DIGIT SIX"
	set cnti=cnti+1,str(cnti)="໗",ucp(cnti)="3799",utf8(cnti)="224,187,151",comments(cnti)="LAO DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="໘",ucp(cnti)="3800",utf8(cnti)="224,187,152",comments(cnti)="LAO DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="໙",ucp(cnti)="3801",utf8(cnti)="224,187,153",comments(cnti)="LAO DIGIT NINE"
	set cnti=cnti+1,str(cnti)="၉",ucp(cnti)="4169",utf8(cnti)="225,129,137",comments(cnti)="MYANMAR DIGIT NINE"
	set cntstrnumerice=cnti
	; All the below samples are not recognized as numerals as per the unicode standard and so cntstrnumerice is set above
	set cnti=cnti+1,str(cnti)="௰",ucp(cnti)="3056",utf8(cnti)="224,175,176",comments(cnti)="TAMIL NUMBER TEN"
	set cnti=cnti+1,str(cnti)="௱",ucp(cnti)="3057",utf8(cnti)="224,175,177",comments(cnti)="TAMIL NUMBER ONE HUNDRED"
	set cnti=cnti+1,str(cnti)="௲",ucp(cnti)="3058",utf8(cnti)="224,175,178",comments(cnti)="TAMIL NUMBER ONE THOUSAND"
	set cnti=cnti+1,str(cnti)="፩",ucp(cnti)="4969",utf8(cnti)="225,141,169",comments(cnti)="ETHIOPIC DIGIT ONE"
	set cnti=cnti+1,str(cnti)="፪",ucp(cnti)="4970",utf8(cnti)="225,141,170",comments(cnti)="ETHIOPIC DIGIT TWO"
	set cnti=cnti+1,str(cnti)="፫",ucp(cnti)="4971",utf8(cnti)="225,141,171",comments(cnti)="ETHIOPIC DIGIT THREE"
	set cnti=cnti+1,str(cnti)="፬",ucp(cnti)="4972",utf8(cnti)="225,141,172",comments(cnti)="ETHIOPIC DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="፭",ucp(cnti)="4973",utf8(cnti)="225,141,173",comments(cnti)="ETHIOPIC DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="፮",ucp(cnti)="4974",utf8(cnti)="225,141,174",comments(cnti)="ETHIOPIC DIGIT SIX"
	set cnti=cnti+1,str(cnti)="፯",ucp(cnti)="4975",utf8(cnti)="225,141,175",comments(cnti)="ETHIOPIC DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="፰",ucp(cnti)="4976",utf8(cnti)="225,141,176",comments(cnti)="ETHIOPIC DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="፱",ucp(cnti)="4977",utf8(cnti)="225,141,177",comments(cnti)="ETHIOPIC DIGIT NINE"
	set cnti=cnti+1,str(cnti)="፲",ucp(cnti)="4978",utf8(cnti)="225,141,178",comments(cnti)="ETHIOPIC NUMBER TEN"
	set cnti=cnti+1,str(cnti)="፳",ucp(cnti)="4979",utf8(cnti)="225,141,179",comments(cnti)="ETHIOPIC NUMBER TWENTY"
	set cnti=cnti+1,str(cnti)="፴",ucp(cnti)="4980",utf8(cnti)="225,141,180",comments(cnti)="ETHIOPIC NUMBER THIRTY"
	set cnti=cnti+1,str(cnti)="፵",ucp(cnti)="4981",utf8(cnti)="225,141,181",comments(cnti)="ETHIOPIC NUMBER FORTY"
	set cnti=cnti+1,str(cnti)="፶",ucp(cnti)="4982",utf8(cnti)="225,141,182",comments(cnti)="ETHIOPIC NUMBER FIFTY"
	set cnti=cnti+1,str(cnti)="፷",ucp(cnti)="4983",utf8(cnti)="225,141,183",comments(cnti)="ETHIOPIC NUMBER SIXTY"
	set cnti=cnti+1,str(cnti)="፸",ucp(cnti)="4984",utf8(cnti)="225,141,184",comments(cnti)="ETHIOPIC NUMBER SEVENTY"
	set cnti=cnti+1,str(cnti)="፹",ucp(cnti)="4985",utf8(cnti)="225,141,185",comments(cnti)="ETHIOPIC NUMBER EIGHTY"
	set cnti=cnti+1,str(cnti)="፺",ucp(cnti)="4986",utf8(cnti)="225,141,186",comments(cnti)="ETHIOPIC NUMBER NINETY"
	set cnti=cnti+1,str(cnti)="፻",ucp(cnti)="4987",utf8(cnti)="225,141,187",comments(cnti)="ETHIOPIC NUMBER HUNDRED"
	set cnti=cnti+1,str(cnti)="፼",ucp(cnti)="4988",utf8(cnti)="225,141,188",comments(cnti)="ETHIOPIC NUMBER TEN THOUSAND"
	;set cnti=cnti+1,str(cnti)="ᛮ",ucp(cnti)="5870",utf8(cnti)="225,155,174",comments(cnti)="RUNIC ARLAUG SYMBOL" ; not a number by itself
	;set cnti=cnti+1,str(cnti)="ᛯ",ucp(cnti)="5871",utf8(cnti)="225,155,175",comments(cnti)="RUNIC TVIMADUR SYMBOL" ; not a number by itself
	;set cnti=cnti+1,str(cnti)="ᛰ",ucp(cnti)="5872",utf8(cnti)="225,155,176",comments(cnti)="RUNIC BELGTHOR SYMBOL" ; not a number by itself
	;set cnti=cnti+1,str(cnti)="⁮",ucp(cnti)="8302",utf8(cnti)="226,129,174",width(cnti)=-1,comments(cnti)="NATIONAL DIGIT SHAPES" ; not a number by itself
	;set cnti=cnti+1,str(cnti)="⁯",ucp(cnti)="8303",utf8(cnti)="226,129,175",width(cnti)=-1,comments(cnti)="NOMINAL DIGIT SHAPES" ; not a number by itself
	set cnti=cnti+1,str(cnti)="⁰",ucp(cnti)="8304",utf8(cnti)="226,129,176",comments(cnti)="SUPERSCRIPT ZERO"
	set cnti=cnti+1,str(cnti)="⁴",ucp(cnti)="8308",utf8(cnti)="226,129,180",comments(cnti)="SUPERSCRIPT FOUR"
	set cnti=cnti+1,str(cnti)="⁵",ucp(cnti)="8309",utf8(cnti)="226,129,181",comments(cnti)="SUPERSCRIPT FIVE"
	set cnti=cnti+1,str(cnti)="⁶",ucp(cnti)="8310",utf8(cnti)="226,129,182",comments(cnti)="SUPERSCRIPT SIX"
	set cnti=cnti+1,str(cnti)="⁷",ucp(cnti)="8311",utf8(cnti)="226,129,183",comments(cnti)="SUPERSCRIPT SEVEN"
	set cnti=cnti+1,str(cnti)="⁸",ucp(cnti)="8312",utf8(cnti)="226,129,184",comments(cnti)="SUPERSCRIPT EIGHT"
	set cnti=cnti+1,str(cnti)="⁹",ucp(cnti)="8313",utf8(cnti)="226,129,185",comments(cnti)="SUPERSCRIPT NINE"
	set cnti=cnti+1,str(cnti)="₀",ucp(cnti)="8320",utf8(cnti)="226,130,128",comments(cnti)="SUBSCRIPT ZERO"
	set cnti=cnti+1,str(cnti)="₁",ucp(cnti)="8321",utf8(cnti)="226,130,129",comments(cnti)="SUBSCRIPT ONE"
	set cnti=cnti+1,str(cnti)="₂",ucp(cnti)="8322",utf8(cnti)="226,130,130",comments(cnti)="SUBSCRIPT TWO"
	set cnti=cnti+1,str(cnti)="₃",ucp(cnti)="8323",utf8(cnti)="226,130,131",comments(cnti)="SUBSCRIPT THREE"
	set cnti=cnti+1,str(cnti)="₄",ucp(cnti)="8324",utf8(cnti)="226,130,132",comments(cnti)="SUBSCRIPT FOUR"
	set cnti=cnti+1,str(cnti)="₅",ucp(cnti)="8325",utf8(cnti)="226,130,133",comments(cnti)="SUBSCRIPT FIVE"
	set cnti=cnti+1,str(cnti)="₆",ucp(cnti)="8326",utf8(cnti)="226,130,134",comments(cnti)="SUBSCRIPT SIX"
	set cnti=cnti+1,str(cnti)="₇",ucp(cnti)="8327",utf8(cnti)="226,130,135",comments(cnti)="SUBSCRIPT SEVEN"
	set cnti=cnti+1,str(cnti)="₈",ucp(cnti)="8328",utf8(cnti)="226,130,136",comments(cnti)="SUBSCRIPT EIGHT"
	set cnti=cnti+1,str(cnti)="₉",ucp(cnti)="8329",utf8(cnti)="226,130,137",comments(cnti)="SUBSCRIPT NINE"
	;set cnti=cnti+1,str(cnti)="№",ucp(cnti)="8470",utf8(cnti)="226,132,150",comments(cnti)="NUMERO SIGN" ; it is not a number by itself
	set cnti=cnti+1,str(cnti)="⅟",ucp(cnti)="8543",utf8(cnti)="226,133,159",comments(cnti)="FRACTION NUMERATOR ONE"
	set cnti=cnti+1,str(cnti)="Ⅰ",ucp(cnti)="8544",utf8(cnti)="226,133,160",comments(cnti)="ROMAN NUMERAL ONE"
	set cnti=cnti+1,str(cnti)="Ⅱ",ucp(cnti)="8545",utf8(cnti)="226,133,161",comments(cnti)="ROMAN NUMERAL TWO"
	set cnti=cnti+1,str(cnti)="Ⅲ",ucp(cnti)="8546",utf8(cnti)="226,133,162",comments(cnti)="ROMAN NUMERAL THREE"
	set cnti=cnti+1,str(cnti)="Ⅳ",ucp(cnti)="8547",utf8(cnti)="226,133,163",comments(cnti)="ROMAN NUMERAL FOUR"
	set cnti=cnti+1,str(cnti)="Ⅴ",ucp(cnti)="8548",utf8(cnti)="226,133,164",comments(cnti)="ROMAN NUMERAL FIVE"
	set cnti=cnti+1,str(cnti)="Ⅵ",ucp(cnti)="8549",utf8(cnti)="226,133,165",comments(cnti)="ROMAN NUMERAL SIX"
	set cnti=cnti+1,str(cnti)="Ⅶ",ucp(cnti)="8550",utf8(cnti)="226,133,166",comments(cnti)="ROMAN NUMERAL SEVEN"
	set cnti=cnti+1,str(cnti)="Ⅷ",ucp(cnti)="8551",utf8(cnti)="226,133,167",comments(cnti)="ROMAN NUMERAL EIGHT"
	set cnti=cnti+1,str(cnti)="Ⅸ",ucp(cnti)="8552",utf8(cnti)="226,133,168",comments(cnti)="ROMAN NUMERAL NINE"
	set cnti=cnti+1,str(cnti)="Ⅹ",ucp(cnti)="8553",utf8(cnti)="226,133,169",comments(cnti)="ROMAN NUMERAL TEN"
	set cnti=cnti+1,str(cnti)="Ⅺ",ucp(cnti)="8554",utf8(cnti)="226,133,170",comments(cnti)="ROMAN NUMERAL ELEVEN"
	set cnti=cnti+1,str(cnti)="Ⅻ",ucp(cnti)="8555",utf8(cnti)="226,133,171",comments(cnti)="ROMAN NUMERAL TWELVE"
	set cnti=cnti+1,str(cnti)="Ⅼ",ucp(cnti)="8556",utf8(cnti)="226,133,172",comments(cnti)="ROMAN NUMERAL FIFTY"
	set cnti=cnti+1,str(cnti)="Ⅽ",ucp(cnti)="8557",utf8(cnti)="226,133,173",comments(cnti)="ROMAN NUMERAL ONE HUNDRED"
	set cnti=cnti+1,str(cnti)="Ⅾ",ucp(cnti)="8558",utf8(cnti)="226,133,174",comments(cnti)="ROMAN NUMERAL FIVE HUNDRED"
	set cnti=cnti+1,str(cnti)="Ⅿ",ucp(cnti)="8559",utf8(cnti)="226,133,175",comments(cnti)="ROMAN NUMERAL ONE THOUSAND"
	set cnti=cnti+1,str(cnti)="ⅰ",ucp(cnti)="8560",utf8(cnti)="226,133,176",comments(cnti)="SMALL ROMAN NUMERAL ONE"
	set cnti=cnti+1,str(cnti)="ⅱ",ucp(cnti)="8561",utf8(cnti)="226,133,177",comments(cnti)="SMALL ROMAN NUMERAL TWO"
	set cnti=cnti+1,str(cnti)="ⅲ",ucp(cnti)="8562",utf8(cnti)="226,133,178",comments(cnti)="SMALL ROMAN NUMERAL THREE"
	set cnti=cnti+1,str(cnti)="ⅳ",ucp(cnti)="8563",utf8(cnti)="226,133,179",comments(cnti)="SMALL ROMAN NUMERAL FOUR"
	set cnti=cnti+1,str(cnti)="ⅴ",ucp(cnti)="8564",utf8(cnti)="226,133,180",comments(cnti)="SMALL ROMAN NUMERAL FIVE"
	set cnti=cnti+1,str(cnti)="ⅵ",ucp(cnti)="8565",utf8(cnti)="226,133,181",comments(cnti)="SMALL ROMAN NUMERAL SIX"
	set cnti=cnti+1,str(cnti)="ⅶ",ucp(cnti)="8566",utf8(cnti)="226,133,182",comments(cnti)="SMALL ROMAN NUMERAL SEVEN"
	set cnti=cnti+1,str(cnti)="ⅷ",ucp(cnti)="8567",utf8(cnti)="226,133,183",comments(cnti)="SMALL ROMAN NUMERAL EIGHT"
	set cnti=cnti+1,str(cnti)="ⅸ",ucp(cnti)="8568",utf8(cnti)="226,133,184",comments(cnti)="SMALL ROMAN NUMERAL NINE"
	set cnti=cnti+1,str(cnti)="ⅹ",ucp(cnti)="8569",utf8(cnti)="226,133,185",comments(cnti)="SMALL ROMAN NUMERAL TEN"
	set cnti=cnti+1,str(cnti)="ⅺ",ucp(cnti)="8570",utf8(cnti)="226,133,186",comments(cnti)="SMALL ROMAN NUMERAL ELEVEN"
	set cnti=cnti+1,str(cnti)="ⅻ",ucp(cnti)="8571",utf8(cnti)="226,133,187",comments(cnti)="SMALL ROMAN NUMERAL TWELVE"
	set cnti=cnti+1,str(cnti)="ⅼ",ucp(cnti)="8572",utf8(cnti)="226,133,188",comments(cnti)="SMALL ROMAN NUMERAL FIFTY"
	set cnti=cnti+1,str(cnti)="ⅽ",ucp(cnti)="8573",utf8(cnti)="226,133,189",comments(cnti)="SMALL ROMAN NUMERAL ONE HUNDRED"
	set cnti=cnti+1,str(cnti)="ⅾ",ucp(cnti)="8574",utf8(cnti)="226,133,190",comments(cnti)="SMALL ROMAN NUMERAL FIVE HUNDRED"
	set cnti=cnti+1,str(cnti)="ⅿ",ucp(cnti)="8575",utf8(cnti)="226,133,191",comments(cnti)="SMALL ROMAN NUMERAL ONE THOUSAND"
	set cnti=cnti+1,str(cnti)="ↀ",ucp(cnti)="8576",utf8(cnti)="226,134,128",comments(cnti)="ROMAN NUMERAL ONE THOUSAND C D"
	set cnti=cnti+1,str(cnti)="ↁ",ucp(cnti)="8577",utf8(cnti)="226,134,129",comments(cnti)="ROMAN NUMERAL FIVE THOUSAND"
	set cnti=cnti+1,str(cnti)="ↂ",ucp(cnti)="8578",utf8(cnti)="226,134,130",comments(cnti)="ROMAN NUMERAL TEN THOUSAND"
	set cnti=cnti+1,str(cnti)="Ↄ",ucp(cnti)="8579",utf8(cnti)="226,134,131",comments(cnti)="ROMAN NUMERAL REVERSED ONE HUNDRED"
	set cnti=cnti+1,str(cnti)="⑉",ucp(cnti)="9289",utf8(cnti)="226,145,137",comments(cnti)="OCR CUSTOMER ACCOUNT NUMBER"
	set cnti=cnti+1,str(cnti)="①",ucp(cnti)="9312",utf8(cnti)="226,145,160",comments(cnti)="CIRCLED DIGIT ONE"
	set cnti=cnti+1,str(cnti)="②",ucp(cnti)="9313",utf8(cnti)="226,145,161",comments(cnti)="CIRCLED DIGIT TWO"
	set cnti=cnti+1,str(cnti)="③",ucp(cnti)="9314",utf8(cnti)="226,145,162",comments(cnti)="CIRCLED DIGIT THREE"
	set cnti=cnti+1,str(cnti)="④",ucp(cnti)="9315",utf8(cnti)="226,145,163",comments(cnti)="CIRCLED DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="⑤",ucp(cnti)="9316",utf8(cnti)="226,145,164",comments(cnti)="CIRCLED DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="⑥",ucp(cnti)="9317",utf8(cnti)="226,145,165",comments(cnti)="CIRCLED DIGIT SIX"
	set cnti=cnti+1,str(cnti)="⑦",ucp(cnti)="9318",utf8(cnti)="226,145,166",comments(cnti)="CIRCLED DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="⑧",ucp(cnti)="9319",utf8(cnti)="226,145,167",comments(cnti)="CIRCLED DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="⑨",ucp(cnti)="9320",utf8(cnti)="226,145,168",comments(cnti)="CIRCLED DIGIT NINE"
	set cnti=cnti+1,str(cnti)="⑩",ucp(cnti)="9321",utf8(cnti)="226,145,169",comments(cnti)="CIRCLED NUMBER TEN"
	set cnti=cnti+1,str(cnti)="⑪",ucp(cnti)="9322",utf8(cnti)="226,145,170",comments(cnti)="CIRCLED NUMBER ELEVEN"
	set cnti=cnti+1,str(cnti)="⑫",ucp(cnti)="9323",utf8(cnti)="226,145,171",comments(cnti)="CIRCLED NUMBER TWELVE"
	set cnti=cnti+1,str(cnti)="⑬",ucp(cnti)="9324",utf8(cnti)="226,145,172",comments(cnti)="CIRCLED NUMBER THIRTEEN"
	set cnti=cnti+1,str(cnti)="⑭",ucp(cnti)="9325",utf8(cnti)="226,145,173",comments(cnti)="CIRCLED NUMBER FOURTEEN"
	set cnti=cnti+1,str(cnti)="⑮",ucp(cnti)="9326",utf8(cnti)="226,145,174",comments(cnti)="CIRCLED NUMBER FIFTEEN"
	set cnti=cnti+1,str(cnti)="⑯",ucp(cnti)="9327",utf8(cnti)="226,145,175",comments(cnti)="CIRCLED NUMBER SIXTEEN"
	set cnti=cnti+1,str(cnti)="⑰",ucp(cnti)="9328",utf8(cnti)="226,145,176",comments(cnti)="CIRCLED NUMBER SEVENTEEN"
	set cnti=cnti+1,str(cnti)="⑱",ucp(cnti)="9329",utf8(cnti)="226,145,177",comments(cnti)="CIRCLED NUMBER EIGHTEEN"
	set cnti=cnti+1,str(cnti)="⑲",ucp(cnti)="9330",utf8(cnti)="226,145,178",comments(cnti)="CIRCLED NUMBER NINETEEN"
	set cnti=cnti+1,str(cnti)="⑳",ucp(cnti)="9331",utf8(cnti)="226,145,179",comments(cnti)="CIRCLED NUMBER TWENTY"
	set cnti=cnti+1,str(cnti)="⑴",ucp(cnti)="9332",utf8(cnti)="226,145,180",comments(cnti)="PARENTHESIZED DIGIT ONE"
	set cnti=cnti+1,str(cnti)="⑵",ucp(cnti)="9333",utf8(cnti)="226,145,181",comments(cnti)="PARENTHESIZED DIGIT TWO"
	set cnti=cnti+1,str(cnti)="⑶",ucp(cnti)="9334",utf8(cnti)="226,145,182",comments(cnti)="PARENTHESIZED DIGIT THREE"
	set cnti=cnti+1,str(cnti)="⑷",ucp(cnti)="9335",utf8(cnti)="226,145,183",comments(cnti)="PARENTHESIZED DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="⑸",ucp(cnti)="9336",utf8(cnti)="226,145,184",comments(cnti)="PARENTHESIZED DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="⑹",ucp(cnti)="9337",utf8(cnti)="226,145,185",comments(cnti)="PARENTHESIZED DIGIT SIX"
	set cnti=cnti+1,str(cnti)="⑺",ucp(cnti)="9338",utf8(cnti)="226,145,186",comments(cnti)="PARENTHESIZED DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="⑻",ucp(cnti)="9339",utf8(cnti)="226,145,187",comments(cnti)="PARENTHESIZED DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="⑼",ucp(cnti)="9340",utf8(cnti)="226,145,188",comments(cnti)="PARENTHESIZED DIGIT NINE"
	set cnti=cnti+1,str(cnti)="⑽",ucp(cnti)="9341",utf8(cnti)="226,145,189",comments(cnti)="PARENTHESIZED NUMBER TEN"
	set cnti=cnti+1,str(cnti)="⑾",ucp(cnti)="9342",utf8(cnti)="226,145,190",comments(cnti)="PARENTHESIZED NUMBER ELEVEN"
	set cnti=cnti+1,str(cnti)="⑿",ucp(cnti)="9343",utf8(cnti)="226,145,191",comments(cnti)="PARENTHESIZED NUMBER TWELVE"
	set cnti=cnti+1,str(cnti)="⒀",ucp(cnti)="9344",utf8(cnti)="226,146,128",comments(cnti)="PARENTHESIZED NUMBER THIRTEEN"
	set cnti=cnti+1,str(cnti)="⒁",ucp(cnti)="9345",utf8(cnti)="226,146,129",comments(cnti)="PARENTHESIZED NUMBER FOURTEEN"
	set cnti=cnti+1,str(cnti)="⒂",ucp(cnti)="9346",utf8(cnti)="226,146,130",comments(cnti)="PARENTHESIZED NUMBER FIFTEEN"
	set cnti=cnti+1,str(cnti)="⒃",ucp(cnti)="9347",utf8(cnti)="226,146,131",comments(cnti)="PARENTHESIZED NUMBER SIXTEEN"
	set cnti=cnti+1,str(cnti)="⒄",ucp(cnti)="9348",utf8(cnti)="226,146,132",comments(cnti)="PARENTHESIZED NUMBER SEVENTEEN"
	set cnti=cnti+1,str(cnti)="⒅",ucp(cnti)="9349",utf8(cnti)="226,146,133",comments(cnti)="PARENTHESIZED NUMBER EIGHTEEN"
	set cnti=cnti+1,str(cnti)="⒆",ucp(cnti)="9350",utf8(cnti)="226,146,134",comments(cnti)="PARENTHESIZED NUMBER NINETEEN"
	set cnti=cnti+1,str(cnti)="⒇",ucp(cnti)="9351",utf8(cnti)="226,146,135",comments(cnti)="PARENTHESIZED NUMBER TWENTY"
	; the FULL STOP literals are not number by themselves
	;set cnti=cnti+1,str(cnti)="⒈",ucp(cnti)="9352",utf8(cnti)="226,146,136",comments(cnti)="DIGIT ONE FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒉",ucp(cnti)="9353",utf8(cnti)="226,146,137",comments(cnti)="DIGIT TWO FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒊",ucp(cnti)="9354",utf8(cnti)="226,146,138",comments(cnti)="DIGIT THREE FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒋",ucp(cnti)="9355",utf8(cnti)="226,146,139",comments(cnti)="DIGIT FOUR FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒌",ucp(cnti)="9356",utf8(cnti)="226,146,140",comments(cnti)="DIGIT FIVE FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒍",ucp(cnti)="9357",utf8(cnti)="226,146,141",comments(cnti)="DIGIT SIX FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒎",ucp(cnti)="9358",utf8(cnti)="226,146,142",comments(cnti)="DIGIT SEVEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒏",ucp(cnti)="9359",utf8(cnti)="226,146,143",comments(cnti)="DIGIT EIGHT FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒐",ucp(cnti)="9360",utf8(cnti)="226,146,144",comments(cnti)="DIGIT NINE FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒑",ucp(cnti)="9361",utf8(cnti)="226,146,145",comments(cnti)="NUMBER TEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒒",ucp(cnti)="9362",utf8(cnti)="226,146,146",comments(cnti)="NUMBER ELEVEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒓",ucp(cnti)="9363",utf8(cnti)="226,146,147",comments(cnti)="NUMBER TWELVE FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒔",ucp(cnti)="9364",utf8(cnti)="226,146,148",comments(cnti)="NUMBER THIRTEEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒕",ucp(cnti)="9365",utf8(cnti)="226,146,149",comments(cnti)="NUMBER FOURTEEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒖",ucp(cnti)="9366",utf8(cnti)="226,146,150",comments(cnti)="NUMBER FIFTEEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒗",ucp(cnti)="9367",utf8(cnti)="226,146,151",comments(cnti)="NUMBER SIXTEEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒘",ucp(cnti)="9368",utf8(cnti)="226,146,152",comments(cnti)="NUMBER SEVENTEEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒙",ucp(cnti)="9369",utf8(cnti)="226,146,153",comments(cnti)="NUMBER EIGHTEEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒚",ucp(cnti)="9370",utf8(cnti)="226,146,154",comments(cnti)="NUMBER NINETEEN FULL STOP"
	;set cnti=cnti+1,str(cnti)="⒛",ucp(cnti)="9371",utf8(cnti)="226,146,155",comments(cnti)="NUMBER TWENTY FULL STOP"
	set cnti=cnti+1,str(cnti)="⓪",ucp(cnti)="9450",utf8(cnti)="226,147,170",comments(cnti)="CIRCLED DIGIT ZERO"
	set cnti=cnti+1,str(cnti)="❶",ucp(cnti)="10102",utf8(cnti)="226,157,182",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT ONE"
	set cnti=cnti+1,str(cnti)="❷",ucp(cnti)="10103",utf8(cnti)="226,157,183",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT TWO"
	set cnti=cnti+1,str(cnti)="❸",ucp(cnti)="10104",utf8(cnti)="226,157,184",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT THREE"
	set cnti=cnti+1,str(cnti)="❹",ucp(cnti)="10105",utf8(cnti)="226,157,185",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="❺",ucp(cnti)="10106",utf8(cnti)="226,157,186",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="❻",ucp(cnti)="10107",utf8(cnti)="226,157,187",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT SIX"
	set cnti=cnti+1,str(cnti)="❼",ucp(cnti)="10108",utf8(cnti)="226,157,188",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="❽",ucp(cnti)="10109",utf8(cnti)="226,157,189",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="❾",ucp(cnti)="10110",utf8(cnti)="226,157,190",comments(cnti)="DINGBAT NEGATIVE CIRCLED DIGIT NINE"
	set cnti=cnti+1,str(cnti)="❿",ucp(cnti)="10111",utf8(cnti)="226,157,191",comments(cnti)="DINGBAT NEGATIVE CIRCLED NUMBER TEN"
	set cnti=cnti+1,str(cnti)="➀",ucp(cnti)="10112",utf8(cnti)="226,158,128",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT ONE"
	set cnti=cnti+1,str(cnti)="➁",ucp(cnti)="10113",utf8(cnti)="226,158,129",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT TWO"
	set cnti=cnti+1,str(cnti)="➂",ucp(cnti)="10114",utf8(cnti)="226,158,130",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT THREE"
	set cnti=cnti+1,str(cnti)="➃",ucp(cnti)="10115",utf8(cnti)="226,158,131",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="➄",ucp(cnti)="10116",utf8(cnti)="226,158,132",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="➅",ucp(cnti)="10117",utf8(cnti)="226,158,133",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT SIX"
	set cnti=cnti+1,str(cnti)="➆",ucp(cnti)="10118",utf8(cnti)="226,158,134",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="➇",ucp(cnti)="10119",utf8(cnti)="226,158,135",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="➈",ucp(cnti)="10120",utf8(cnti)="226,158,136",comments(cnti)="DINGBAT CIRCLED SANS-SERIF DIGIT NINE"
	set cnti=cnti+1,str(cnti)="➉",ucp(cnti)="10121",utf8(cnti)="226,158,137",comments(cnti)="DINGBAT CIRCLED SANS-SERIF NUMBER TEN"
	set cnti=cnti+1,str(cnti)="➊",ucp(cnti)="10122",utf8(cnti)="226,158,138",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT ONE"
	set cnti=cnti+1,str(cnti)="➋",ucp(cnti)="10123",utf8(cnti)="226,158,139",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT TWO"
	set cnti=cnti+1,str(cnti)="➌",ucp(cnti)="10124",utf8(cnti)="226,158,140",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT THREE"
	set cnti=cnti+1,str(cnti)="➍",ucp(cnti)="10125",utf8(cnti)="226,158,141",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FOUR"
	set cnti=cnti+1,str(cnti)="➎",ucp(cnti)="10126",utf8(cnti)="226,158,142",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FIVE"
	set cnti=cnti+1,str(cnti)="➏",ucp(cnti)="10127",utf8(cnti)="226,158,143",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SIX"
	set cnti=cnti+1,str(cnti)="➐",ucp(cnti)="10128",utf8(cnti)="226,158,144",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SEVEN"
	set cnti=cnti+1,str(cnti)="➑",ucp(cnti)="10129",utf8(cnti)="226,158,145",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT EIGHT"
	set cnti=cnti+1,str(cnti)="➒",ucp(cnti)="10130",utf8(cnti)="226,158,146",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT NINE"
	set cnti=cnti+1,str(cnti)="➓",ucp(cnti)="10131",utf8(cnti)="226,158,147",comments(cnti)="DINGBAT NEGATIVE CIRCLED SANS-SERIF NUMBER TEN"
	do wrapup	; cntstr should be maintained in case lnumeric^unicodesampledata is called explicitly
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
global	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; entry-point to define all of the above arrays in globals as well. Note that the local arrays will be defined as well.
	;
	do ^unicodesampledata
	; varsdefined holds a list of the local variables defined in this routine
	for vi=1:1:$LENGTH(varsdefined,",")  do
	. set vari=$PIECE(varsdefined,",",vi)
	. set varig="^"_vari
	. ; if the unsubscripted local variable has a value, define the unsubsripted global:
	. if 1=$DATA(@vari)#10 set @varig=@vari
	. ; if there are subscripted variables, define the matching globals:
	. if 9<$DATA(@vari) set xi="" for  set xi=$order(@vari@(xi)) quit:xi=""  set @varig@(xi)=@vari@(xi)
	;. write vari,!
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	quit
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;tmp tmp tmp remove after this point on
 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print(xx)	;
	;for cnti=1:1:cntstr w "-----------",! zwrite str(cnti),ucp(cnti),utf8(cnti) ;; ZWRITE cannot handle multi-byte chars yet
	if 'xx do
	. set maxstrwidth=maxwidth
	. write $JUSTIFY("",9) for idash=1:1:(maxstrwidth+4) write "_"
	. write !
	. for cnti=1:1:cntstr  do
	. . write "cnti:",$JUSTIFY(cnti,3)," |"
	. . if (0<$GET(width(cnti))) write $JUSTIFY(str(cnti),maxstrwidth+2),"|"
	. . else  do
	. . . write $JUSTIFY("__not_printable__",maxstrwidth+2),"|"
	. . write ?maxstrwidth+12," --> ",$GET(comments(cnti)),!
	. write $JUSTIFY("",9) for idash=1:1:(maxstrwidth+4) write "_"
	. quit
	if (xx) do
	. for cnti=1:1:cntstr  do
	. . write "===========",!,"str(",cnti,")="""
	. . if (0<$GET(width(cnti))) write str(cnti),"""",!
	. . else  write "_not_printable_""",!
	. . zwrite ucp(cnti),utf8(cnti),ucplen(cnti),utf8len(cnti),width(cnti)
	. . if $DATA(comments(cnti)) write "comments(",cnti,")=""",comments(cnti),"""",!
	. . if $DATA(width(cnti)) write "width(",cnti,")=",width(cnti),"",!
	. . if (2=xx) do
	. . . w "-----------",!
	. . . write "calc $LENGTH: " write $LENGTH(str(cnti)),!
	. . . if $LENGTH(str(cnti))'=ucplen(cnti) write "--> ucplen incorrect ($LENGTH(str(cnti)):",$LENGTH(str(cnti))," vs ucplen(cnti):",ucplen(cnti),") XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",!
	. . . set casc=$ASCII(str(cnti),1) for i=2:1:$LENGTH(str(cnti)) set casc=casc_","_$ASCII(str(cnti),i)
	. . . write "calc $ASCII:  ",casc,!
	. . . if casc'=ucp(cnti) write "--> ucp incorrect XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",!
	. write "----------------------"
	quit
putf8	; temp entrypoint, "printf utf8" of a range, specified by cntib and cntif
	; useful in filling up un-filled arrays (usually marked with __FILL_IN__)
	for cnti=cntib:1:cntif set x=str(cnti) write """",!,"--->",$GET(comments(cnti)),!,"set utf8(cnti)=""",$ASCII(x) f i=2:1:$LENGTH(x) w ",",$ASCII(x,i)
	;; the way to set up cntib and cnti:
	;set cntib=cnti+1
	;set cnti=cnti+1,str(cnti)="..."
	;set cntif=cnti
	; when $ASCII() starts operating on multi-byte characters, this entrypoint can help fill in the ucp() array (using $ASCII()) as well as utf8() array (using $ZASCII())
	quit
	; to print the ucp values for a range of str(), use the above putf8 entrypoint with $ZCHSET value of "UTF-8"
kill	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	kill (u,p,ps,l,k,badcharsamples)

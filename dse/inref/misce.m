misce
	; set some globals in misc.dat
        s ^misc(123)="string"
        s ^misc(456)=456
        s ^misc("string")="string1"
        s ^misc("string1")=12345
        s ^misc($zchar(255))=$zchar(255)
        s ^misc($zchar(25))=12345
        s ^misc($zchar(25),$zchar(42))="string"
        s ^misc($zchar(25),$zchar(42),"string")=12345
        s ^misc($zchar(25),$zchar(42),"string",123)="abcd"
        s ^misc($zchar(25),$zchar(43))=$zchar(25)
        s ^misc(123,456)=123456
        s ^misc("str1")=123456
        s ^misc("str1","str2")=123456
        s ^misc("str1","str3")=$zchar(43)
        s ^misc="0"
        s ^misc("""")="1"
        s ^misc("""a""")=""""
        s ^misc("b")="ad"""

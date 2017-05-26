;	routine checks for call-by reference in longnames truncating above 31chars
xcessvar;
;	more than 31 char set here
        set %havealongnamegreaterthanthirtyonetocheck=5409
        set iamgreaterthanthirtyoneheretoensuretruncation=4578
	set ^%Myageis31amitoooldtobecalledoldieiwantto=467 ;check for globals too here on proper truncation
;	varaiables above truncated to 31 char & set here
	set %havealongnamegreaterthanthirty=786
	set iamgreaterthanthirtyoneheretoen=876
	set ^%Myageis31amitoooldtobecalledol=678 ;check for globals too here on proper truncation
;	call sub-routine
        do MYLABELLONGONE(.%havealongnamegreaterthanthirtyonetocheck,.iamgreaterthanthirtyoneheretoensuretruncation)
	if (1572=%havealongnamegreaterthanthirtyonetocheck)&(899=iamgreaterthanthirtyoneheretoensuretruncation) do
	. write "Call by reference is correct for truncated varables",!
	else  do
	. write "TEST-E-INCORRECT! variables not truncated properly",!
	. write "%havealongnamegreaterthanthirtyonetocheck = ",%havealongnamegreaterthanthirtyonetocheck,!
	. write "iamgreaterthanthirtyoneheretoensuretruncation = ",iamgreaterthanthirtyoneheretoensuretruncation,!
	do GLOBALMECHK(^%Myageis31amitoooldtobecalledoldieiwantto)
	quit
MYLABELLONGONE(truncateitandget,thishouldbetruncatedtooasverylongname)
	set truncateitandget=truncateitandget*2
	set thishouldbetruncatedtooasverylongname=thishouldbetruncatedtooasverylongname+23
	if thishouldbetruncatedtooasverylo'=thishouldbetruncatedtooasverylongname write "TEST-E-ERROR in formal list truncation",!
	quit
GLOBALMECHK(var1234567890)
	if (var1234567890'=678)&(^%Myageis31amitoooldtobecalledoldieiwantto'=%Myageis31amitoooldtobecalledol) write "TEST-E-ERROR in globals truncation",!
	quit

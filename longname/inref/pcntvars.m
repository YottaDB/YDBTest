;	routine checks for call-by reference in longnames beginning with %
pcntvars;
        set %var135358347560964867445674724="initialvalue"
        set %num138975967336490845684456456=55
        set %var2w89r73447573="beforechange"
        set %num2348734534534534=100
	set ^%globalcheckforlongnames="iamAlright" ;added some globals here to check callbyreference on them too.
	set ^%numericglobalsonlong=456
;	check here for some false values due to truncation
	set %var1353="wrongtrunc"
	set %num1389=777
	set %var2w89="totallywrong"
	set %num2348=945
	set ^%globalc="iamsickhere"
	set ^%numeric=334
;	call sub-routine
        do STRCHG(.%var135358347560964867445674724,%var2w89r73447573,^%globalcheckforlongnames,%num138975967336490845684456456,.%num2348734534534534,^%numericglobalsonlong)
	if ("initialvaluechangedtonew"=%var135358347560964867445674724)&(166=%num2348734534534534)&("beforechange"=%var2w89r73447573)&(55=%num138975967336490845684456456)&("iamAlrightaftercall"=^%globalcheckforlongnames)&(557=^%numericglobalsonlong) do
	. write "Call by reference is correct for %variables",!
	else  do
	. write "TEST-E-INCORRECT! variables %varables & %numbers not referenced",!
	. write "%var135358347560964867445674724 = ",%var135358347560964867445674724," , ""%num2348734534534534 = ",%num2348734534534534," , ""^%globalcheckforlongnames = ",^%globalcheckforlongnames," , ""^%numericglobalsonlong = ",^%numericglobalsonlong,!
	. write "%var2w89r73447573 = ",%var2w89r73447573," , ","%num138975967336490845684456456 = ",%num138975967336490845684456456,!
	quit
STRCHG(%aforansistd,bforborland,%cforcplusplus,%dfordevelopment,%eforenterprisejava,fforfortranbutold)
        set %aforansistd=%aforansistd_"changedtonew"
        set bforborland=bforborland_"cannotchangetoNew"
	set ^%globalcheckforlongnames=%cforcplusplus_"aftercall"
	set %dfordevelopment=%dfordevelopment+90
        set %eforenterprisejava=%eforenterprisejava+66
	set ^%numericglobalsonlong=fforfortranbutold+101
        quit

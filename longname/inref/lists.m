;	M routine to check parameter passing works fine with LongNames
;
MYLABEL(shinjuku,shinokobu,takadanobaba,tokyo)
	write "I'll give the sum of the numbers",!
	set beijing=shinjuku+shinokobu+takadanobaba
	write "SUM = ",beijing,!
	if tokyo'=beijing write "TEST-E-ERROR, sum is wrong, was expecting: ",tokyo," but got: ",beijing,!
	Quit
CHKLABEL(harajukuhara,meigurudesu)
	write "I'll print the numbers passed",!
	write harajukuhara," ",meigurudesu,!
	Quit
CHARLAB8(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,japanesenamesloveit,r,s,t,u,v,w,x,y,z,aa,bb,cc,dd,ee,ff)
	write "I'll produce the sum of all numbers passed",!
	set zigma=a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+japanesenamesloveit+r+s+t+u+v+w+x+y+z+aa+bb+cc+dd+ee+ff
	write "ZIGMA = ",zigma,!
	if 948'=zigma write " TEST-E-ERROR, sum is wrong, was expecting:948 but got: ",zigma,!
	Quit
LABELNEW(odakyo,hammatsucho)
	write "I'll use only one variable & double it",!
	new hammatsucho
	set bigstoreodakyo=odakyo*2
	write "Doubled value = ",bigstoreodakyo,!
	Quit
IAMLONGL(aa,bb,cc)
	write "TEST-E-INCORRECT LABEL invoked",!
	write "THIS IS ERROR",!
	Quit
IAMLONGLABELLENGTHTOOLONGSAY30(kawasakiodesu,arigato,oyasuminasai)
	write ">8 char label correctly called"
	set goodnight=kawasakiodesu+arigato
	write "SUM = ",goodnight,!
	if oyasuminasai'=goodnight write "TEST-E-ERROR, sum is wrong, was expecting: ",oyasuminasai," but got: ",goodnight,!
	Quit
CANIGOALENGTHTOOLONGINNATURE30(gozaimasu,tabemasu,mirukudesu)
	write "This is the product of two numbers passed in actual",!
	set prod=gozaimasu*tabemasu
	write "PROD = ",prod,!
	Quit
LONGLONGLABELLONGLONGLABELLONGM(a,b,c,d,e,f,g,h,i,j,k,milkismiruku,m,n,o,p,q,r,s,t,u,v,w,x,y,z,aa,bb,cc,dd,ee,ff)
	write "I'll produce the sum of all numbers passed",!
	set bigzigma=a+b+c+d+e+f+g+h+i+j+k+milkismiruku+m+n+o+p+q+r+s+t+u+v+w+x+y+z+aa+bb+cc+dd+ee+ff
	write "BIGZIGMA = ",bigzigma,!
	Quit
DUMMYLONGLONGLONGLONGLONGLONG(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,aa,bb,cc,dd,ee,ff,gg)
	write "TEST-E-INCORRECT CALL"
	write "I should not be called . 32 params limit exceeded.",!
	Quit
NEWEDCHK(retainmexx,metootoretain)
	write "I'll print the numbers passed",!
        if '$DATA(retainmexx) write "first parameter not passed in",!
        if '$DATA(metootoretain) write "second parameter not passed in",!
        write $GET(retainmexx)," ",$GET(metootoretain),!
        Quit
FIVELABELCHECK(variab,variabl,variable,variable1,variable2)
	write "I'll check whether parameters are truncated",!
	write "passed in parameters are:",variab," , ",variabl," , ",variable," , ",variable1," , ",variable2,!
	if (222'=variab)&(333'=variabl)&(444'=variable)&(555'=variable1)&(666'=variable2) do
	. write "TEST-E-ERROR formal list incorrect truncation",!
	. zwrite ^getme,^getmecorr,^getmecorre,^getmecorrect,^getmecorrect1
	Quit

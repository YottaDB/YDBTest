GT.M MUPIP EXTRACT
18-NOV-1996  18:51:07
^cd("ar","ama")
1\patient signed out
^cd("ar","cd")
1\Cancelled by referring doctor
^cd("ar","cf")
1\cancelled by floor
^cd("ar","cfn")
1\cancelled floor nurse
^cd("ar","cn")
1\Conflict of examinations
^cd("ar","cor")
1\cancelled OR
^cd("ar","cp")
1\cancelled by patient
^cd("ar","cr")
1\Cancelled by Radiologist
^cd("ar","ct")
1\cancelled by tech
^cd("ar","ctd")
1\ctdown
^cd("ar","dr")
1\duplicate request
^cd("ar","ec")
1\exam(s) changed
^cd("ar","ee")
1\Error entry
^cd("ar","fm")
1\files merged
^cd("ar","nc")
1\no consent
^cd("ar","nd")
1\not done by tech
^cd("ar","no")
1\no orders
^cd("ar","np")
1\Patient not prepped
^cd("ar","ns")
1\No show
^cd("ar","nt")
1\no time
^cd("ar","pa")
1\patient ate
^cd("ar","pc")
1\procedure cancellled
^cd("ar","pd")
1\patient discharged
^cd("ar","pe")
1\patient expired
^cd("ar","pid")
1\patient left dept.
^cd("ar","pnf")
1\Patient not on floor
^cd("ar","po")
1\patient obese
^cd("ar","pp")
1\Postponed
^cd("ar","pr")
1\patient refused
^cd("ar","pu")
1\Patient uncooperative
^cd("ar","rs")
1\Rescheduled for another date
^cd("cd","ar")
1\Abort Reason
^cd("cd","ar","acpock")

^cd("cd","ar","acprck")

^cd("cd","ar","iapock")

^cd("cd","ar","iaprck")

^cd("cd","ar","in")
5\40\1\1
^cd("cd","ar","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","bm")
1\Billing Modifier
^cd("cd","bm","acpock")

^cd("cd","bm","acprck")

^cd("cd","bm","iapock")

^cd("cd","bm","iaprck")

^cd("cd","bm","in")
5\40\1\1
^cd("cd","bm","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","cd")
1\Code Type
^cd("cd","cd","acpock")

^cd("cd","cd","acprck")

^cd("cd","cd","iapock")

^cd("cd","cd","iaprck")

^cd("cd","cd","in")
5\40\1\0
^cd("cd","cd","rt")
^cdencd\cnlc^cdst\cnlc^cdst\cd^cdds10\
^cd("cd","cr")
1\Cancellation Reason
^cd("cd","cr","acpock")

^cd("cd","cr","acprck")

^cd("cd","cr","iapock")

^cd("cd","cr","iaprck")

^cd("cd","cr","in")
5\40\1\1
^cd("cd","cr","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","di")
1\Data Item
^cd("cd","di","acpock")

^cd("cd","di","acprck")

^cd("cd","di","iapock")

^cd("cd","di","iaprck")

^cd("cd","di","in")
10\40\1\0
^cd("cd","di","rt")
^cdendi\cnlc^cdst\cnlc^cdst\di^cdds08\
^cd("cd","dm")
1\Deamon
^cd("cd","dm","acpock")

^cd("cd","dm","acprck")

^cd("cd","dm","iapock")

^cd("cd","dm","iaprck")

^cd("cd","dm","in")
5\40\1\0
^cd("cd","dm","rt")
^cdendm\cnlc^cdst\cnlc^cdst\dm^cdds08\
^cd("cd","dp")
1\Department
^cd("cd","dp","acpock")

^cd("cd","dp","acprck")

^cd("cd","dp","iapock")

^cd("cd","dp","iaprck")

^cd("cd","dp","in")
5\40\1\0
^cd("cd","dp","rt")
^cdendp\cnlc^cdst\cnlc^cdst\dp^cdds01\
^cd("cd","dr")
1\Doctor
^cd("cd","dr","acpock")

^cd("cd","dr","acprck")

^cd("cd","dr","iapock")

^cd("cd","dr","iaprck")

^cd("cd","dr","in")
9\40\1\0
^cd("cd","dr","rt")
^cdendr\cnlc^cdst\cnlc^cdst\dr^cddsdr02\
^cd("cd","ds")
1\Date Style
^cd("cd","ds","acpock")

^cd("cd","ds","acprck")

^cd("cd","ds","iapock")

^cd("cd","ds","iaprck")

^cd("cd","ds","in")
5\40\1\0
^cd("cd","ds","rt")
^cdends\cnlc^cdst\cnlc^cdst\ds^cdds08\
^cd("cd","dt")
1\Device Type
^cd("cd","dt","acpock")

^cd("cd","dt","acprck")

^cd("cd","dt","iapock")

^cd("cd","dt","iaprck")

^cd("cd","dt","in")
5\40\1\0
^cd("cd","dt","rt")
^cdendt\cnlc^cdst\cnlc^cdst\dt^cdds05\
^cd("cd","dv")
1\Device
^cd("cd","dv","acpock")

^cd("cd","dv","acprck")

^cd("cd","dv","iapock")

^cd("cd","dv","iaprck")

^cd("cd","dv","in")
5\40\1\0
^cd("cd","dv","rt")
^cdendv\cnlc^cdst\cnlc^cdst\dv^cdds04\
^cd("cd","dy")
1\Day
^cd("cd","dy","acpock")

^cd("cd","dy","acprck")
@s:$d(^cdx("dy","no",$p(^cd("dy",code,"in"),"\",1)))'[0 scer="@innmdy"
^cd("cd","dy","iapock")

^cd("cd","dy","iaprck")
@k ^cdx("dy","no",$p(^cd("dy",code,"in"),"\",1))
^cd("cd","dy","in")
5\40\1\0
^cd("cd","dy","rt")
^cdendy\cnlc^cdst\cnlc^cdst\dy^cdds03\
^cd("cd","er")
1\Error Message
^cd("cd","er","acpock")

^cd("cd","er","acprck")

^cd("cd","er","iapock")

^cd("cd","er","iaprck")

^cd("cd","er","in")
10\50\1\1
^cd("cd","er","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","fd")
1\Field
^cd("cd","fd","acpock")

^cd("cd","fd","acprck")

^cd("cd","fd","iapock")

^cd("cd","fd","iaprck")

^cd("cd","fd","in")
10\40\1\1
^cd("cd","fd","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","fk")
1\Function Key
^cd("cd","fk","acpock")

^cd("cd","fk","acprck")

^cd("cd","fk","iapock")

^cd("cd","fk","iaprck")

^cd("cd","fk","in")
10\40\1\1
^cd("cd","fk","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","fl")
1\Film Location
^cd("cd","fl","acpock")

^cd("cd","fl","acprck")

^cd("cd","fl","iapock")

^cd("cd","fl","iaprck")
flia^cdac01
^cd("cd","fl","in")
5\40\1\0
^cd("cd","fl","rt")
^cdenfl\cnlc^cdst\cnlc^cdst\fl^cdds10\
^cd("cd","fn")
1\Function
^cd("cd","fn","acpock")
fn^cdac01
^cd("cd","fn","acprck")

^cd("cd","fn","iapock")
fn^cdac01
^cd("cd","fn","iaprck")

^cd("cd","fn","in")
10\40\1\0
^cd("cd","fn","rt")
^cdenfc\cnlc^cdst\cnlc^cdst\fn^cdds04\
^cd("cd","fq")
1\Film Quality
^cd("cd","fq","acpock")

^cd("cd","fq","acprck")

^cd("cd","fq","iapock")

^cd("cd","fq","iaprck")

^cd("cd","fq","in")
5\40\1\1
^cd("cd","fq","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","fr")
1\Form Type
^cd("cd","fr","acpock")

^cd("cd","fr","acprck")

^cd("cd","fr","iapock")

^cd("cd","fr","iaprck")

^cd("cd","fr","in")
5\40\1\0
^cd("cd","fr","rt")
^cdenfr\cnlc^cdst\cnlc^cdst\fr^cdds09\
^cd("cd","fs")
1\Film Size
^cd("cd","fs","acpock")

^cd("cd","fs","acprck")

^cd("cd","fs","iapock")

^cd("cd","fs","iaprck")

^cd("cd","fs","in")
5\40\1\1
^cd("cd","fs","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","ft")
1\Film Type
^cd("cd","ft","acpock")

^cd("cd","ft","acprck")

^cd("cd","ft","iapock")

^cd("cd","ft","iaprck")

^cd("cd","ft","in")
5\40\1\1
^cd("cd","ft","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","gar")
1\Groups of Abort Reason
^cd("cd","gar","acpock")

^cd("cd","gar","acprck")

^cd("cd","gar","iapock")

^cd("cd","gar","iaprck")

^cd("cd","gar","in")
5\40\0\0
^cd("cd","gar","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gbm")
1\Groups of Billing Modifier
^cd("cd","gbm","acpock")

^cd("cd","gbm","acprck")

^cd("cd","gbm","iapock")

^cd("cd","gbm","iaprck")

^cd("cd","gbm","in")
5\40\0\0
^cd("cd","gbm","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gcd")
1\Groups of Code Type
^cd("cd","gcd","acpock")

^cd("cd","gcd","acprck")

^cd("cd","gcd","iapock")

^cd("cd","gcd","iaprck")

^cd("cd","gcd","in")
5\40\0\0
^cd("cd","gcd","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gcr")
1\Groups of Cancellation Reason
^cd("cd","gcr","acpock")

^cd("cd","gcr","acprck")

^cd("cd","gcr","iapock")

^cd("cd","gcr","iaprck")

^cd("cd","gcr","in")
5\40\0\0
^cd("cd","gcr","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gdi")
1\Groups of Data Item
^cd("cd","gdi","acpock")

^cd("cd","gdi","acprck")

^cd("cd","gdi","iapock")

^cd("cd","gdi","iaprck")

^cd("cd","gdi","in")
5\40\0\0
^cd("cd","gdi","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gdm")
1\Groups of Deamon
^cd("cd","gdm","acpock")

^cd("cd","gdm","acprck")

^cd("cd","gdm","iapock")

^cd("cd","gdm","iaprck")

^cd("cd","gdm","in")
5\40\0\0
^cd("cd","gdm","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gdp")
1\Groups of Department
^cd("cd","gdp","acpock")

^cd("cd","gdp","acprck")

^cd("cd","gdp","iapock")

^cd("cd","gdp","iaprck")

^cd("cd","gdp","in")
5\40\0\0
^cd("cd","gdp","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gdr")
1\Groups of Doctor
^cd("cd","gdr","acpock")

^cd("cd","gdr","acprck")

^cd("cd","gdr","iapock")

^cd("cd","gdr","iaprck")

^cd("cd","gdr","in")
5\40\0\0
^cd("cd","gdr","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gds")
1\Groups of Date Style
^cd("cd","gds","acpock")

^cd("cd","gds","acprck")

^cd("cd","gds","iapock")

^cd("cd","gds","iaprck")

^cd("cd","gds","in")
5\40\0\0
^cd("cd","gds","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gdt")
1\Groups of Device Type
^cd("cd","gdt","acpock")

^cd("cd","gdt","acprck")

^cd("cd","gdt","iapock")

^cd("cd","gdt","iaprck")

^cd("cd","gdt","in")
5\40\0\0
^cd("cd","gdt","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gdv")
1\Groups of Device
^cd("cd","gdv","acpock")

^cd("cd","gdv","acprck")

^cd("cd","gdv","iapock")

^cd("cd","gdv","iaprck")

^cd("cd","gdv","in")
5\40\0\0
^cd("cd","gdv","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gdy")
1\Groups of Day
^cd("cd","gdy","acpock")

^cd("cd","gdy","acprck")

^cd("cd","gdy","iapock")

^cd("cd","gdy","iaprck")

^cd("cd","gdy","in")
5\40\0\0
^cd("cd","gdy","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","ger")
1\Groups of Error Message
^cd("cd","ger","acpock")

^cd("cd","ger","acprck")

^cd("cd","ger","iapock")

^cd("cd","ger","iaprck")

^cd("cd","ger","in")
5\40\0\0
^cd("cd","ger","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gfk")
1\Groups of Function Key
^cd("cd","gfk","acpock")

^cd("cd","gfk","acprck")

^cd("cd","gfk","iapock")

^cd("cd","gfk","iaprck")

^cd("cd","gfk","in")
5\40\0\0
^cd("cd","gfk","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gfl")
1\Groups of Film Location/Folder
^cd("cd","gfl","acpock")

^cd("cd","gfl","acprck")

^cd("cd","gfl","iapock")

^cd("cd","gfl","iaprck")

^cd("cd","gfl","in")
5\40\0\0
^cd("cd","gfl","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gfn")
1\Groups of Function
^cd("cd","gfn","acpock")

^cd("cd","gfn","acprck")

^cd("cd","gfn","iapock")

^cd("cd","gfn","iaprck")

^cd("cd","gfn","in")
5\40\0\0
^cd("cd","gfn","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gfq")
1\Groups of Film Quality
^cd("cd","gfq","acpock")

^cd("cd","gfq","acprck")

^cd("cd","gfq","iapock")

^cd("cd","gfq","iaprck")

^cd("cd","gfq","in")
5\40\0\0
^cd("cd","gfq","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gfr")
1\Groups of Form Type
^cd("cd","gfr","acpock")

^cd("cd","gfr","acprck")

^cd("cd","gfr","iapock")

^cd("cd","gfr","iaprck")

^cd("cd","gfr","in")
5\40\0\0
^cd("cd","gfr","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gfs")
1\Groups of Film Size
^cd("cd","gfs","acpock")

^cd("cd","gfs","acprck")

^cd("cd","gfs","iapock")

^cd("cd","gfs","iaprck")

^cd("cd","gfs","in")
5\40\0\0
^cd("cd","gfs","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gft")
1\Groups of Film Type
^cd("cd","gft","acpock")

^cd("cd","gft","acprck")

^cd("cd","gft","iapock")

^cd("cd","gft","iaprck")

^cd("cd","gft","in")
5\40\0\0
^cd("cd","gft","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","ggl")
1\Groups of Glossary Term
^cd("cd","ggl","acpock")

^cd("cd","ggl","acprck")

^cd("cd","ggl","iapock")

^cd("cd","ggl","iaprck")

^cd("cd","ggl","in")
5\40\0\0
^cd("cd","ggl","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gho")
1\Groups of Holiday
^cd("cd","gho","acpock")

^cd("cd","gho","acprck")

^cd("cd","gho","iapock")

^cd("cd","gho","iaprck")

^cd("cd","gho","in")
5\40\0\0
^cd("cd","gho","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gio")
1\Groups of Output
^cd("cd","gio","acpock")

^cd("cd","gio","acprck")

^cd("cd","gio","iapock")

^cd("cd","gio","iaprck")

^cd("cd","gio","in")
5\40\0\0
^cd("cd","gio","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","git")
1\Groups of Insurance
^cd("cd","git","acpock")

^cd("cd","git","acprck")

^cd("cd","git","iapock")

^cd("cd","git","iaprck")

^cd("cd","git","in")
5\40\0\0
^cd("cd","git","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gl")
1\Glossary Term
^cd("cd","gl","acpock")

^cd("cd","gl","acprck")

^cd("cd","gl","iapock")

^cd("cd","gl","iaprck")

^cd("cd","gl","in")
5\60\1\1
^cd("cd","gl","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","glc")
1\Groups of Patient Location
^cd("cd","glc","acpock")

^cd("cd","glc","acprck")

^cd("cd","glc","iapock")

^cd("cd","glc","iaprck")

^cd("cd","glc","in")
5\40\0\0
^cd("cd","glc","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gmn")
1\Groups of Mnemonic Function
^cd("cd","gmn","acpock")

^cd("cd","gmn","acprck")

^cd("cd","gmn","iapock")

^cd("cd","gmn","iaprck")

^cd("cd","gmn","in")
10\40\0\0
^cd("cd","gmn","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gmo")
1\Groups of Patient Mobility
^cd("cd","gmo","acpock")

^cd("cd","gmo","acprck")

^cd("cd","gmo","iapock")

^cd("cd","gmo","iaprck")

^cd("cd","gmo","in")
5\40\0\0
^cd("cd","gmo","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gms")
1\Groups of Marital Status
^cd("cd","gms","acpock")

^cd("cd","gms","acprck")

^cd("cd","gms","iapock")

^cd("cd","gms","iaprck")

^cd("cd","gms","in")
5\40\0\0
^cd("cd","gms","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gop")
1\Groups of Option
^cd("cd","gop","acpock")

^cd("cd","gop","acprck")

^cd("cd","gop","iapock")

^cd("cd","gop","iaprck")

^cd("cd","gop","in")
5\40\0\0
^cd("cd","gop","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gpp")
1\Groups of Prep. Category
^cd("cd","gpp","acpock")

^cd("cd","gpp","acprck")

^cd("cd","gpp","iapock")

^cd("cd","gpp","iaprck")

^cd("cd","gpp","in")
5\40\0\0
^cd("cd","gpp","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gpr")
1\Groups of Procedure
^cd("cd","gpr","acpock")

^cd("cd","gpr","acprck")

^cd("cd","gpr","iapock")

^cd("cd","gpr","iaprck")

^cd("cd","gpr","in")
5\40\0\0
^cd("cd","gpr","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gps")
1\Groups of Patient Status
^cd("cd","gps","acpock")

^cd("cd","gps","acprck")

^cd("cd","gps","iapock")

^cd("cd","gps","iaprck")

^cd("cd","gps","in")
5\40\0\0
^cd("cd","gps","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gpt")
1\Groups of Patient Type
^cd("cd","gpt","acpock")

^cd("cd","gpt","acprck")

^cd("cd","gpt","iapock")

^cd("cd","gpt","iaprck")

^cd("cd","gpt","in")
5\40\0\0
^cd("cd","gpt","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gra")
1\Groups of Room Availability
^cd("cd","gra","acpock")

^cd("cd","gra","acprck")

^cd("cd","gra","iapock")

^cd("cd","gra","iaprck")

^cd("cd","gra","in")
5\40\0\0
^cd("cd","gra","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","grc","acpock")

^cd("cd","grc","acprck")

^cd("cd","grc","iapock")

^cd("cd","grc","iaprck")

^cd("cd","grc","in")
5\40\0\0
^cd("cd","grc","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","grl")
1\Groups of Requesting Location
^cd("cd","grl","acpock")

^cd("cd","grl","acprck")

^cd("cd","grl","iapock")

^cd("cd","grl","iaprck")

^cd("cd","grl","in")
5\40\0\0
^cd("cd","grl","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","grm")
1\Groups of Procedure Room
^cd("cd","grm","acpock")

^cd("cd","grm","acprck")

^cd("cd","grm","iapock")

^cd("cd","grm","iaprck")

^cd("cd","grm","in")
5\40\0\0
^cd("cd","grm","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","grp")
1\Groups of Report Type
^cd("cd","grp","acpock")

^cd("cd","grp","acprck")

^cd("cd","grp","iapock")

^cd("cd","grp","iaprck")

^cd("cd","grp","in")
5\40\0\0
^cd("cd","grp","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","grt")
1\Groups of Patient Race
^cd("cd","grt","acpock")

^cd("cd","grt","acprck")

^cd("cd","grt","iapock")

^cd("cd","grt","iaprck")

^cd("cd","grt","in")
5\40\0\0
^cd("cd","grt","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","grw")
1\Groups of Report Writer Queries
^cd("cd","grw","acpock")

^cd("cd","grw","acprck")

^cd("cd","grw","iapock")

^cd("cd","grw","iaprck")

^cd("cd","grw","in")
5\40\0\0
^cd("cd","grw","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gsc")
1\Groups of Screen ID
^cd("cd","gsc","acpock")

^cd("cd","gsc","acprck")

^cd("cd","gsc","iapock")

^cd("cd","gsc","iaprck")

^cd("cd","gsc","in")
5\40\0\0
^cd("cd","gsc","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gst")
1\Groups of State
^cd("cd","gst","acpock")

^cd("cd","gst","acprck")

^cd("cd","gst","iapock")

^cd("cd","gst","iaprck")

^cd("cd","gst","in")
5\40\0\0
^cd("cd","gst","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gsx")
1\Groups of Sex
^cd("cd","gsx","acpock")

^cd("cd","gsx","acprck")

^cd("cd","gsx","iapock")

^cd("cd","gsx","iaprck")

^cd("cd","gsx","in")
5\40\0\0
^cd("cd","gsx","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gtl")
1\Groups of Tracking Location
^cd("cd","gtl","acpock")

^cd("cd","gtl","acprck")

^cd("cd","gtl","iapock")

^cd("cd","gtl","iaprck")

^cd("cd","gtl","in")
5\40\0\0
^cd("cd","gtl","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gts")
1\Groups of Time Style
^cd("cd","gts","acpock")

^cd("cd","gts","acprck")

^cd("cd","gts","iapock")

^cd("cd","gts","iaprck")

^cd("cd","gts","in")
5\40\0\0
^cd("cd","gts","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gtx")
1\Groups of Predefined Text
^cd("cd","gtx","acpock")

^cd("cd","gtx","acprck")

^cd("cd","gtx","iapock")

^cd("cd","gtx","iaprck")

^cd("cd","gtx","in")
5\40\0\0
^cd("cd","gtx","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gus")
1\Groups of User
^cd("cd","gus","acpock")

^cd("cd","gus","acprck")

^cd("cd","gus","iapock")

^cd("cd","gus","iaprck")

^cd("cd","gus","in")
5\40\0\0
^cd("cd","gus","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","gzp")
1\Groups of Zip
^cd("cd","gzp","acpock")

^cd("cd","gzp","acprck")

^cd("cd","gzp","iapock")

^cd("cd","gzp","iaprck")

^cd("cd","gzp","in")
5\40\0\0
^cd("cd","gzp","rt")
^cdgr\cnlc^cdst\cnlc^cdst\gr^cdgrds01\
^cd("cd","ho")
1\Holiday
^cd("cd","ho","acpock")

^cd("cd","ho","acprck")

^cd("cd","ho","iapock")

^cd("cd","ho","iaprck")

^cd("cd","ho","in")
5\40\1\0
^cd("cd","ho","rt")
^cdenho\cnlc^cdst\cnlc^cdst\ho^cdds01\
^cd("cd","id")
1\Id
^cd("cd","id","acpock")

^cd("cd","id","acprck")

^cd("cd","id","iapock")

^cd("cd","id","iaprck")

^cd("cd","id","in")
5\40\1\1
^cd("cd","io")
1\Output
^cd("cd","io","acpock")

^cd("cd","io","acprck")

^cd("cd","io","iapock")

^cd("cd","io","iaprck")

^cd("cd","io","in")
5\40\1\1
^cd("cd","io","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","it")
1\Insurance
^cd("cd","it","acpock")

^cd("cd","it","acprck")

^cd("cd","it","iapock")

^cd("cd","it","iaprck")

^cd("cd","it","in")
5\40\1\1
^cd("cd","it","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","lc")
1\Patient Location
^cd("cd","lc","acpock")

^cd("cd","lc","acprck")

^cd("cd","lc","iapock")

^cd("cd","lc","iaprck")

^cd("cd","lc","in")
5\40\1\1
^cd("cd","lc","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","mn")
1\Mnemonic
^cd("cd","mn","acpock")

^cd("cd","mn","acprck")

^cd("cd","mn","iapock")

^cd("cd","mn","iaprck")

^cd("cd","mn","in")
10\40\1\1
^cd("cd","mn","rt")
^cdenmn\cnlc^cdst\cnlc^cdst\mn^cdds06\
^cd("cd","mo")
1\Patient Mobility
^cd("cd","mo","acpock")

^cd("cd","mo","acprck")

^cd("cd","mo","iapock")

^cd("cd","mo","iaprck")

^cd("cd","mo","in")
5\40\1\1
^cd("cd","mo","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","ms")
1\Marital Status
^cd("cd","ms","acpock")

^cd("cd","ms","acprck")

^cd("cd","ms","iapock")

^cd("cd","ms","iaprck")

^cd("cd","ms","in")
5\40\1\1
^cd("cd","ms","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","op")
1\Option
^cd("cd","op","acpock")

^cd("cd","op","acprck")

^cd("cd","op","iapock")

^cd("cd","op","iaprck")

^cd("cd","op","in")
10\40\1\1
^cd("cd","op","rt")
^cdenop\cnlc^cdst\cnlc^cdst\op^cdds06\
^cd("cd","pp")
1\Prep. Category
^cd("cd","pp","acpock")

^cd("cd","pp","acprck")

^cd("cd","pp","iapock")

^cd("cd","pp","iaprck")

^cd("cd","pp","in")
5\40\1\0
^cd("cd","pp","rt")
^cdenpp\cnlc^cdst\cnlc^cdst\pp^cdds03\
^cd("cd","pr")
1\Procedure
^cd("cd","pr","acpock")

^cd("cd","pr","acprck")

^cd("cd","pr","iapock")

^cd("cd","pr","iaprck")

^cd("cd","pr","in")
10\40\1\0
^cd("cd","pr","rt")
^cdenpr\cnlc^cdst\cnlc^cdst\pr^cdds02\
^cd("cd","ps")
1\Patient Status
^cd("cd","ps","acpock")

^cd("cd","ps","acprck")

^cd("cd","ps","iapock")

^cd("cd","ps","iaprck")

^cd("cd","ps","in")
5\40\1\1
^cd("cd","ps","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","pt")
1\Patient Type
^cd("cd","pt","acpock")

^cd("cd","pt","acprck")

^cd("cd","pt","iapock")

^cd("cd","pt","iaprck")

^cd("cd","pt","in")
5\40\1\1
^cd("cd","pt","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","ra")
1\Room Availability 
^cd("cd","ra","acpock")

^cd("cd","ra","acprck")

^cd("cd","ra","iapock")

^cd("cd","ra","iaprck")

^cd("cd","ra","in")
5\40\1\0
^cd("cd","ra","rt")
^cdenra\cnlc^cdst\cnlc^cdst\ra^cdds03\
^cd("cd","rc")
1\Patient Race
^cd("cd","rc","acpock")

^cd("cd","rc","acprck")

^cd("cd","rc","iapock")

^cd("cd","rc","iaprck")

^cd("cd","rc","in")
5\40\1\1
^cd("cd","rc","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","rf")
1\Raport Form Type
^cd("cd","rf","acpock")

^cd("cd","rf","acprck")

^cd("cd","rf","iapock")

^cd("cd","rf","iaprck")

^cd("cd","rf","in")
2\40\1\1
^cd("cd","rf","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","rl")
1\Requesting Location
^cd("cd","rl","acpock")

^cd("cd","rl","acprck")

^cd("cd","rl","iapock")

^cd("cd","rl","iaprck")

^cd("cd","rl","in")
5\40\1\1
^cd("cd","rl","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","rm")
1\Procedure Room
^cd("cd","rm","acpock")

^cd("cd","rm","acprck")

^cd("cd","rm","iapock")

^cd("cd","rm","iaprck")

^cd("cd","rm","in")
5\40\1\0
^cd("cd","rm","rt")
^cdenrm\cnlc^cdst\cnlc^cdst\rm^cdds03\
^cd("cd","rp")
1\Report Type
^cd("cd","rp","acpock")

^cd("cd","rp","acprck")

^cd("cd","rp","iapock")

^cd("cd","rp","iaprck")

^cd("cd","rp","in")
5\40\1\0
^cd("cd","rp","rt")
^cdenrp\cnlc^cdst\cnlc^cdst\rp^cdds07\
^cd("cd","rt")
1\Routine
^cd("cd","rt","acpock")

^cd("cd","rt","acprck")

^cd("cd","rt","iapock")

^cd("cd","rt","iaprck")

^cd("cd","rt","in")
10\40\1\1
^cd("cd","rt","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","rw")
1\Report Writer Query
^cd("cd","rw","acpock")

^cd("cd","rw","acprck")

^cd("cd","rw","iapock")

^cd("cd","rw","iaprck")

^cd("cd","rw","in")
15\40\1\0
^cd("cd","rw","rt")
^rwen\rw^cdst\rw^cdst\^rwds\^rwdl
^cd("cd","sc")
1\Screen ID
^cd("cd","sc","acpock")

^cd("cd","sc","acprck")

^cd("cd","sc","iapock")

^cd("cd","sc","iaprck")

^cd("cd","sc","in")
10\40\1\1
^cd("cd","sc","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","st")
1\State
^cd("cd","st","acpock")

^cd("cd","st","acprck")

^cd("cd","st","iapock")

^cd("cd","st","iaprck")

^cd("cd","st","in")
5\40\1\1
^cd("cd","st","rt")
^cdenms\cnuc^cdst\cnuc^cdst\ms^cdds01\
^cd("cd","sx")
1\Sex
^cd("cd","sx","acpock")

^cd("cd","sx","acprck")

^cd("cd","sx","iapock")

^cd("cd","sx","iaprck")

^cd("cd","sx","in")
1\40\1\1
^cd("cd","sx","rt")
^cdenms\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","tl")
1\Tracking Location
^cd("cd","tl","acpock")

^cd("cd","tl","acprck")

^cd("cd","tl","iapock")

^cd("cd","tl","iaprck")

^cd("cd","tl","in")
5\40\1\1
^cd("cd","tl","rt")
^cdentl\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","tr")
1\Transaction
^cd("cd","tr","acpock")

^cd("cd","tr","acprck")

^cd("cd","tr","iapock")

^cd("cd","tr","iaprck")

^cd("cd","tr","in")
10\40\1\1
^cd("cd","tr","rt")
\cnlc^cdst\cnlc^cdst\ms^cdds01\
^cd("cd","ts")
1\Time Style
^cd("cd","ts","acpock")

^cd("cd","ts","acprck")

^cd("cd","ts","iapock")

^cd("cd","ts","iaprck")

^cd("cd","ts","in")
5\40\1\0
^cd("cd","ts","rt")
^cdents\cnlc^cdst\cnlc^cdst\ts^cdds03\
^cd("cd","tx")
1\Predefined Text
^cd("cd","tx","acpock")

^cd("cd","tx","acprck")

^cd("cd","tx","iapock")

^cd("cd","tx","iaprck")

^cd("cd","tx","in")
10\40\1\0
^cd("cd","tx","rt")
^cdentx\cnlc^cdst\cnlc^cdst\tx^cdds08\
^cd("cd","us")
1\User
^cd("cd","us","acpock")

^cd("cd","us","acprck")

^cd("cd","us","iapock")

^cd("cd","us","iaprck")

^cd("cd","us","in")
5\40\1\0
^cd("cd","us","rt")
^cdenus\cnlc^cdst\cnlc^cdst\us^cdds06\
^cd("cd","zp")
1\Zip
^cd("cd","zp","acpock")

^cd("cd","zp","acprck")

^cd("cd","zp","iapock")

^cd("cd","zp","iaprck")

^cd("cd","zp","in")
10\40\1\1
^cd("cd","zp","rt")
^cdenms\zp^cdst\zp^cdst\ms^cdds01\
^cd("cr","ama")
1\Patient signed out
^cd("cr","cbd")
1\called, did not bring to xray
^cd("cr","cd")
1\Cancelled by referring doctor
^cd("cr","cf")
1\Cancelled by Floor
^cd("cr","cfn")
1\cancelled floor nurse
^cd("cr","cn")
1\Conflict of examinations
^cd("cr","cor")
1\cancelled OR
^cd("cr","cp")
1\cancelled by patient
^cd("cr","cr")
1\Cancelled by radiologist
^cd("cr","ct")
1\cancelled by tech
^cd("cr","ctd")
1\ctdown
^cd("cr","dr")
1\duplicate request
^cd("cr","ec")
1\exam(s) changed
^cd("cr","ee")
1\error entry
^cd("cr","fm")
1\files merged
^cd("cr","lx")
1\lost xrays
^cd("cr","mrid")
1\mri down
^cd("cr","nc")
1\no consent
^cd("cr","nd")
1\not done by tech
^cd("cr","no")
1\no orders
^cd("cr","np")
1\Patient not prepped
^cd("cr","ns")
1\No show
^cd("cr","nt")
1\no time
^cd("cr","pa")
1\patient ate
^cd("cr","pc")
1\procedure cancelled
^cd("cr","pd")
1\patient discharged
^cd("cr","pe")
1\patient expired
^cd("cr","per")
1\postponed due to emergencies
^cd("cr","pip")
1\patient is pregnant
^cd("cr","pld")
1\patient left dept.
^cd("cr","pnf")
1\patient not on floor
^cd("cr","po")
1\patient obesc
^cd("cr","pp")
1\postponed
^cd("cr","pr")
1\Patient refused
^cd("cr","pu")
1\Patient uncooperative
^cd("cr","rs")
1\Rescheduled for another date
^cd("cr","unt")
1\unable to tolerate mri
^cd("di","amdt")
1\Amended date (internal)
^cd("di","amdt","in")
11\@d amdttm^cdendi04 s vl=$e(vl,1,5)\1\0\0
^cd("di","amtm")
1\Amended time (internal)
^cd("di","amtm","in")
8\@d amdttm^cdendi04 s vl=$e(vl,6,10)\1\0\0
^cd("di","ardt")
1\Arrival date (internal)
^cd("di","ardt","in")
11\$e($p(^ar(arid,"in"),$c(92),1),1,5)\1\1\0
^cd("di","artm")
1\Arrival time (internal)
^cd("di","artm","in")
8\$e($p(^ar(arid,"in"),$c(92),1),6,10)\1\1\0
^cd("di","bcdrid")
1\Internal doctor id for BC label
^cd("di","bcdrid","in")
20\@s vl="i:"_drid\0\1\1
^cd("di","bcfkcd")
1\Function key code for BC label
^cd("di","bcfkcd","in")
20\@d fkcd^cdendi02\0\1\1
^cd("di","bcflcd")
1\Film location code for BC label
^cd("di","bcflcd","in")
20\@s vl=flcd\0\1\1
^cd("di","bcflpt")
1\Film location/patient id for BC label
^cd("di","bcflpt","in")
20\@s vl=flcd_"%i:"_ptid\0\1\1
^cd("di","bcfncd")
1\Function code for BC label
^cd("di","bcfncd","in")
20\@s vl="i:"_fncd\0\1\1
^cd("di","bcfrtx5")
1\Bar code free text line 5
^cd("di","bcfrtx5","in")
20\@s vl=tx(5)\0\1\1
^cd("di","bcprid")
1\Procedure ID for BC label
^cd("di","bcprid","in")
20\@s vl="p:"_prid\0\1\1
^cd("di","bcpthn")
1\Patient ID for BC label
^cd("di","bcpthn","in")
20\$p(^pt(ptid,"hn"),$c(92),1)\0\1\1
^cd("di","bcrmcd")
1\Procedure room code for BC label
^cd("di","bcrmcd","in")
20\@s vl=rmcd\0\1\1
^cd("di","bctlcd")
1\Barcode function/tracking location code
^cd("di","bctlcd","in")
15\@s vl="tkmv%"_tlcd\0\1\1
^cd("di","bctxcd")
1\Predefined text code for BC label
^cd("di","bctxcd","in")
20\@s vl=txcd\0\1\1
^cd("di","bcuscd")
1\User code for BC label
^cd("di","bcuscd","in")
20\@s vl=uscd\0\1\1
^cd("di","bddt")
1\Date of birth (internal)
^cd("di","bddt","in")
11\@d bd^cdendi02\1\1\0
^cd("di","blno")
1\Billing number
^cd("di","blno","in")
11\$p(^pr(prid,"pt"),$c(92),4)\1\1\0
^cd("di","csno")
1\Case number
^cd("di","csno","in")
6\$p(^pr(prid,"in"),$c(92),10)\1\1\0
^cd("di","cudt")
1\Current date (internal)
^cd("di","cudt","in")
11\@s vl=$c(92)_"d"\1\1\0
^cd("di","cutm")
1\Current time (internal)
^cd("di","cutm","in")
8\@s vl=$c(92)_"t"\1\1\0
^cd("di","dpcd")
1\Department (code)
^cd("di","dpcd","in")
5\$p(^ar(arid,"in"),$c(92),5)\1\1\0
^cd("di","dpdt")
1\Recorded complete date (internal)
^cd("di","dpdt","in")
11\$e($p(^ar(arid,"in"),$c(92),2),1,5)\1\1\0
^cd("di","dptm")
1\Recorded complete time (internal)
^cd("di","dptm","in")
8\$e($p(^ar(arid,"in"),$c(92),2),6,10)\1\1\0
^cd("di","drhn")
1\Doctor external id
^cd("di","drhn","in")
11\$p(^cdi("dr",drid,"hn"),$c(92),1)\1\1\0
^cd("di","drnm")
1\Doctor name
^cd("di","drnm","in")
35\$e($p(^cdi("dr",drid,"rd"),$c(92),3),1,35)\1\1\0
^cd("di","dtlv")
1\Date of last visit (internal)
^cd("di","dtlv","in")
11\@d dtlv^cdendi04\1\1\0
^cd("di","endt")
1\Initial date entered (internal)
^cd("di","endt","in")
11\@d endttm^cdendi04 s vl=$e(vl,1,5)\1\0\0
^cd("di","entm")
1\Initial time entered (internal)
^cd("di","entm","in")
8\@d endttm^cdendi04 s vl=$e(vl,6,10)\1\0\0
^cd("di","fkcd")
1\Function key (code)
^cd("di","fkcd","in")
10\@s vl=fkcd\0\1\0
^cd("di","flcd")
1\Film location (code)
^cd("di","flcd","in")
5\@d flcd^cdendi02\1\1\0
^cd("di","fncd")
1\Function (code)
^cd("di","fncd","in")
10\@s vl=fncd\0\1\0
^cd("di","frtx")
1\Free text
^cd("di","frtx","in")
0\\1\1\0
^cd("di","frtx1")
1\Free text line 1 for label
^cd("di","frtx1","in")
0\@s vl=tx(1)\0\1\0
^cd("di","frtx2")
1\Free text line 2 for label
^cd("di","frtx2","in")
0\@s vl=tx(2)\0\1\0
^cd("di","frtx3")
1\Free text line 3 for label
^cd("di","frtx3","in")
0\@s vl=tx(3)\0\1\0
^cd("di","frtx4")
1\Free text line 4 for label
^cd("di","frtx4","in")
0\@s vl=tx(4)\0\1\0
^cd("di","frtx5")
1\Free text line 5 for label
^cd("di","frtx5","in")
0\@s vl=tx(5)\0\1\0
^cd("di","iocd")
1\Ouput (code)
^cd("di","iocd","in")
5\$p(^pr(prid,"in"),$c(92),11)\1\1\0
^cd("di","itcd")
1\Insurance type (code)
^cd("di","itcd","in")
5\$p(^pr(prid,"pt"),$c(92),1)\1\1\0
^cd("di","lccd")
1\Location (code)
^cd("di","lccd","in")
5\$p(^pr(prid,"pt"),$c(92),5)\1\1\0
^cd("di","mocd")
1\Mobility (code)
^cd("di","mocd","in")
5\$p(^pr(prid,"pt"),$c(92),8)\1\1\0
^cd("di","mscd")
1\Marital status (code)
^cd("di","mscd","in")
5\$p(^pt(ptid,"in"),$c(92),4)\1\1\0
^cd("di","mxnm")
1\Hospital name
^cd("di","mxnm","in")
25\^cd("op","mx.nm","vl")\1\1\0
^cd("di","nofn")
1\Page number (n of n)
^cd("di","nofn","in")
10\@d nofn^cdendi02\0\1\0
^cd("di","pgno")
1\Page number on report header
^cd("di","pgno","in")
3\@s vl=$c(92)_"p"\1\0\0
^cd("di","prcm1")
1\Procedure comment #1
^cd("di","prcm1","in")
60\@s n=1 d prcm^cdendi02\1\1\0
^cd("di","prcm2")
1\Procedure comment #2
^cd("di","prcm2","in")
60\@s n=2 d prcm^cdendi02\1\1\0
^cd("di","prcm3")
1\Procedure comment #3
^cd("di","prcm3","in")
60\@s n=3 d prcm^cdendi02\1\1\0
^cd("di","prlb1")
1\Procedure 1 on label (id)
^cd("di","prlb1","in")
8\@d prsb1^cdendi02\0\1\0
^cd("di","prlb10")
1\Procedure 10 on label (id)
^cd("di","prlb10","in")
8\@s nm=10 d prsbn^cdendi02\0\1\0
^cd("di","prlb2")
1\Procedure 2 on label (id)
^cd("di","prlb2","in")
8\@s nm=2 d prsbn^cdendi02\0\1\0
^cd("di","prlb3")
1\Procedure 3 on label (id)
^cd("di","prlb3","in")
8\@s nm=3 d prsbn^cdendi02\0\1\0
^cd("di","prlb4")
1\Procedure 4 on label (id)
^cd("di","prlb4","in")
8\@s nm=4 d prsbn^cdendi02\0\1\0
^cd("di","prlb5")
1\Procedure 5 on label (id)
^cd("di","prlb5","in")
8\@s nm=5 d prsbn^cdendi02\0\1\0
^cd("di","prlb6")
1\Procedure 6 on label (id)
^cd("di","prlb6","in")
8\@s nm=6 d prsbn^cdendi02\0\1\0
^cd("di","prlb7")
1\Procedure 7 on label (id)
^cd("di","prlb7","in")
8\@s nm=7 d prsbn^cdendi02\0\1\0
^cd("di","prlb8")
1\Procedure 8 on label (id)
^cd("di","prlb8","in")
8\@s nm=8 d prsbn^cdendi02\0\1\0
^cd("di","prlb9")
1\Procedure 9 on label (id)
^cd("di","prlb9","in")
8\@s nm=9 d prsbn^cdendi02\0\1\0
^cd("di","prrp1")
1\Procedure 1 on report header (id)
^cd("di","prrp1","in")
8\@s n=1 d prn^cdendi02\1\0\0
^cd("di","prrp10")
1\Procedure 10 on report header (id)
^cd("di","prrp10","in")
8\@s n=10 d prn^cdendi02\1\0\0
^cd("di","prrp2")
1\Procedure 2 on report header (id)
^cd("di","prrp2","in")
8\@s n=2 d prn^cdendi02\1\0\0
^cd("di","prrp3")
1\Procedure 3 on report header (id)
^cd("di","prrp3","in")
8\@s n=3 d prn^cdendi02\1\0\0
^cd("di","prrp4")
1\Procedure 4 on report header (id)
^cd("di","prrp4","in")
8\@s n=4 d prn^cdendi02\1\0\0
^cd("di","prrp5")
1\Procedure 5 on report header (id)
^cd("di","prrp5","in")
8\@s n=5 d prn^cdendi02\1\0\0
^cd("di","prrp6")
1\Procedure 6 on report header (id)
^cd("di","prrp6","in")
8\@s n=6 d prn^cdendi02\1\0\0
^cd("di","prrp7")
1\Procedure 7 on report header (id)
^cd("di","prrp7","in")
8\@s n=7 d prn^cdendi02\1\0\0
^cd("di","prrp8")
1\Procedure 8 on report header (id)
^cd("di","prrp8","in")
8\@s n=8 d prn^cdendi02\1\0\0
^cd("di","prrp9")
1\Procedure 9 on report header (id)
^cd("di","prrp9","in")
8\@s n=9 d prn^cdendi02\1\0\0
^cd("di","prss1")
1\Procedure site specific item 1
^cd("di","prss1","in")
10\@s n=1 d prssn^cdendi02\1\1\0
^cd("di","prss10")
1\Procedure site specific item 10
^cd("di","prss10","in")
10\@s n=10 d prssn^cdendi02\1\1\0
^cd("di","prss2")
1\Procedure site specific item 2
^cd("di","prss2","in")
10\@s n=2 d prssn^cdendi02\1\1\0
^cd("di","prss3")
1\Procedure site specific item 3
^cd("di","prss3","in")
10\@s n=3 d prssn^cdendi02\1\1\0
^cd("di","prss4")
1\Procedure site specific item 4
^cd("di","prss4","in")
10\@s n=4 d prssn^cdendi02\1\1\0
^cd("di","prss5")
1\Procedure site specific item 5
^cd("di","prss5","in")
10\@s n=5 d prssn^cdendi02\1\1\0
^cd("di","prss6")
1\Procedure site specific item 6
^cd("di","prss6","in")
10\@s n=6 d prssn^cdendi02\1\1\0
^cd("di","prss7")
1\Procedure site specific item 7
^cd("di","prss7","in")
10\@s n=7 d prssn^cdendi02\1\1\0
^cd("di","prss8")
1\Procedure site specific item 8
^cd("di","prss8","in")
10\@s n=8 d prssn^cdendi02\1\1\0
^cd("di","prss9")
1\Procedure site specific item 9
^cd("di","prss9","in")
10\@s n=9 d prssn^cdendi02\1\1\0
^cd("di","ptag")
1\Age
^cd("di","ptag","in")
3\@d ag^cdendi02\1\1\0
^cd("di","ptcd")
1\Type (code)
^cd("di","ptcd","in")
5\$p(^pr(prid,"pt"),$c(92),7)\1\1\0
^cd("di","ptcm1")
1\Patient comments line 1
^cd("di","ptcm1","in")
60\@s:$d(^pt(ptid,"cm",1))'[0 vl=^pt(ptid,"cm",1)\1\0\0
^cd("di","ptcm2")
1\Patient comments line 2
^cd("di","ptcm2","in")
60\@s:$d(^pt(ptid,"cm",2))'[0 vl=^pt(ptid,"cm",2)\1\0\0
^cd("di","ptcm3")
1\Patient comments line 3
^cd("di","ptcm3","in")
60\@s:$d(^pt(ptid,"cm",3))'[0 vl=^pt(ptid,"cm",3)\1\0\0
^cd("di","pthn")
1\Primary patient ID
^cd("di","pthn","in")
14\$p(^pt(ptid,"hn"),$c(92),1)\1\1\0
^cd("di","pthn2")
1\Secondary patient ID
^cd("di","pthn2","in")
14\$p(^pt(ptid,"hn"),$c(92),2)\1\1\0
^cd("di","pthn3")
1\Tertiary patient ID
^cd("di","pthn3","in")
14\$p(^pt(ptid,"hn"),$c(92),3)\1\1\0
^cd("di","ptid")
1\Patient ID (internal)
^cd("di","ptid","in")
8\@s vl=ptid\1\1\0
^cd("di","ptpg")
1\Patient pregnant status
^cd("di","ptpg","in")
10\$p(^pr(prid,"pt"),$c(92),11)\0\1\0
^cd("di","ptss1")
1\Patient site specific item 1
^cd("di","ptss1","in")
10\@s n=1 d ptssn^cdendi02\1\1\0
^cd("di","ptss10")
1\Patient site specific item 10
^cd("di","ptss10","in")
10\@s n=10 d ptssn^cdendi02\1\1\0
^cd("di","ptss2")
1\Patient site specific item 2
^cd("di","ptss2","in")
10\@s n=2 d ptssn^cdendi02\1\1\0
^cd("di","ptss3")
1\Patient site specific item 3
^cd("di","ptss3","in")
10\@s n=3 d ptssn^cdendi02\1\1\0
^cd("di","ptss4")
1\Patient site specific item 4
^cd("di","ptss4","in")
10\@s n=4 d ptssn^cdendi02\1\1\0
^cd("di","ptss5")
1\Patient site specific item 5
^cd("di","ptss5","in")
10\@s n=5 d ptssn^cdendi02\1\1\0
^cd("di","ptss6")
1\Patient site specific item 6
^cd("di","ptss6","in")
10\@s n=6 d ptssn^cdendi02\1\1\0
^cd("di","ptss7")
1\Patient site specific item 7
^cd("di","ptss7","in")
10\@s n=7 d ptssn^cdendi02\1\1\0
^cd("di","ptss8")
1\Patient site specific item 8
^cd("di","ptss8","in")
10\@s n=8 d ptssn^cdendi02\1\1\0
^cd("di","ptss9")
1\Patient site specific item 9
^cd("di","ptss9","in")
10\@s n=9 d ptssn^cdendi02\1\1\0
^cd("di","rccd")
1\Race (code)
^cd("di","rccd","in")
5\$p(^pt(ptid,"in"),$c(92),6)\1\1\0
^cd("di","rfdrid1")
1\Referring physician 1 (internal id)
^cd("di","rfdrid1","in")
6\@s n=1 d rfdrid^cdendi02\1\1\0
^cd("di","rfdrid2")
1\Referring physician 2 (internal id)
^cd("di","rfdrid2","in")
6\@s n=2 d rfdrid^cdendi02\1\1\0
^cd("di","rfdrid3")
1\Referring physician 3 (internal id)
^cd("di","rfdrid3","in")
6\@s n=3 d rfdrid^cdendi02\1\1\0
^cd("di","rfdrid4")
1\Referring physician 4 (internal id)
^cd("di","rfdrid4","in")
6\@s n=4 d rfdrid^cdendi02\1\1\0
^cd("di","rlcd")
1\Requesting location (code)
^cd("di","rlcd","in")
5\$p(^pr(prid,"pt"),$c(92),9)\1\1\0
^cd("di","rmcd")
1\Room (code)
^cd("di","rmcd","in")
5\@s vl=$s($d(rmcd)[0:$p(^pr(prid,"in"),$c(92),4),1:rmcd)\1\1\0
^cd("di","rpam")
1\Report ammended flag
^cd("di","rpam","in")
5\@s vl=$s($d(rpam)[0:$p(^rp(rpid,"st"),$c(92),2),1:rpam)\1\1\0
^cd("di","sxcd")
1\Sex (code)
^cd("di","sxcd","in")
1\$p(^pt(ptid,"in"),$c(92),1)\1\1\0
^cd("di","tkrqcm")
1\Transport Request comment
^cd("di","tkrqcm","in")
60\@s:$d(^tk(tkid,"cm"))'[0 vl=^tk(tkid,"cm")\0\1\0
^cd("di","tkrqdt")
1\Transport request date
^cd("di","tkrqdt","in")
11\$e($p(^tk(tkid,"in"),$c(92),4),1,5)\0\1\0
^cd("di","tkrqlc1")
1\Transport to location
^cd("di","tkrqlc1","in")
5\$p(^tk(tkid,"in"),$c(92),2)\0\1\0
^cd("di","tkrqlc2")
1\Transport from location
^cd("di","tkrqlc2","in")
5\$p(^tk(tkid,"in"),$c(92),3)\0\1\0
^cd("di","tkrqtm")
1\Transport request time
^cd("di","tkrqtm","in")
8\$e($p(^tk(tkid,"in"),$c(92),4),6,10)\0\1\0
^cd("di","tlcd")
1\Tracking location code
^cd("di","tlcd","in")
5\@s vl=tlcd\0\1\0
^cd("di","txcd")
1\Predefined text (code)
^cd("di","txcd","in")
10\@s vl=txcd\0\1\0
^cd("di","uscd")
1\User (code)
^cd("di","uscd","in")
10\@d uscd^cdendi04\1\1\0
^cd("dm","cm")
1\Communications background job

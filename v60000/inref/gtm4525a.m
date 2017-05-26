gtm4525a
  halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; rtcinstcheck
;
;	- reads GDE output from $principal, specifically:
;		* show -region
;		* show -template
;		* show -command
;	- picks out and displays inst freeze on error information

rtcinstcheck
  new row,fields,spec
  ;
  ;; region
  ;
  set row=$$readrowmatch("*** REGIONS ***")
  if row=""  write "REGIONS Not Found",!  quit
  set *row=$$readfieldequal("Region",1)
  if row=""  write "Region Header Not Found",!  quit
  read row	; skip separator line
  ; Anticipatory Freeze flag is field 9
  ; Read until we hit a blank line
  for  read row  quit:row=""  set *fields=$$SPLIT^%MPIECE(row)  write "REGION(",fields(1),")=",fields(9),!
  ;
  ;; template
  ;
  set row=$$readrowmatch("*** TEMPLATES ***")
  if row=""  write "TEMPLATES Not Found",!  quit
  set *row=$$readfieldequal("Region",1)
  if row=""  write "Template Region Header Not Found",!  quit
  read row	; skip separator line
  ; Anticipatory Freeze flag is field 8 in the template section
  ; Read until we hit a blank line
  for  read row  quit:row=""  set *fields=$$SPLIT^%MPIECE(row)  write "TEMPLATE(",fields(1),")=",fields(8),!
  ;
  ;; command
  ;
  ; find region template command line
  ;
  kill spec
  set spec(1)="TEMPLATE",spec(2)="-REGION"
  set *fields=$$readmultifieldequal(.spec)
  if fields=""  write "TEMPLATE -REGION Command Not Found",!  quit
  write "COMMAND: ",fields(1)," ",fields(2)," ",$$firstfieldmatch(.fields,"INST"),!
  ;
  ; find each region change command line
  ;
  kill spec
  set spec(1)="CHANGE",spec(2)="-REGION"
  for  set *fields=$$readmultifieldequal(.spec)  quit:fields=""  do
  . write "COMMAND: ",fields(1)," ",fields(2)," ",fields(3)," ",$$firstfieldmatch(.fields,"INST"),!
  ;
  quit


; dseinstcheck
;
;	- reads DSE file dump of the given space-delimited regions on $principal
;	- region order from DSE and "regions" argument must match
;	- picks out and displays inst freeze on error information

dseinstcheck(regions)
  new row,fields,spec,rf
  ;
  set *regions=$$SPLIT^%MPIECE(regions),rf=0
  ;
  ; Iterate over regions. The subscript is the field number, and the value is the region name.
  ;
  for  set rf=$order(regions(rf))  quit:rf=""  do
  . ;
  . ; find the region entry for this region
  . ;
  . kill spec
  . set spec(1)="Region",spec(2)=regions(rf)
  . set *fields=$$readmultifieldequal(.spec)
  . if fields="" write "Region "_regions(rf)_" not found",!
  . ;
  . ; find the next inst freeze on error entry
  . ;
  . kill spec
  . set spec(5)="Inst",spec(6)="Freeze",spec(7)="on",spec(8)="Error"
  . set *fields=$$readmultifieldequal(.spec)
  . if fields="" write "Inst Freeze on Error not found",!
  . else  write "Region(",regions(rf),")=",fields(9),!
  ;
  quit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; readrowmatch(str)
;	- reads $principal until a line matches str
;	- returns the matching line

readrowmatch(str)
  new row
  for  read row  quit:$zeof!(row[str)
  quit row

; readfieldequal(str,fnum)
;	- reads $principal until a line has field #fnum with the value str
;	- returns an aliased variable
;		* contains empty string if not found
;		* contains matching row, all fields in subscripts if found

readfieldequal(str,fnum)
  new row,fields
  for  read row  quit:$zeof  set *fields=$$SPLIT^%MPIECE(row)  quit:$data(fields(fnum))&(fields(fnum)=str)
  set fields=row
  quit *fields
  ;; Or in terms of readmultifieldequal...
  ; new spec,fields
  ; set spec(fnum)=str,*fields=$$readmultifieldequal(.spec)
  ; quit *fields


; readmultifieldequal(spec)
;	- reads $principal until a line matches the given spec
;		* spec must be passed by reference
;		* spec must have field number subscripts with field values
;		* matches if the values of the spec fields match the field of the input row
;	- returns an aliased variable
;		* contains empty string if not found
;		* contains matching row, all fields in subscripts if found

readmultifieldequal(spec)
  new row,fields
  for  read row  quit:$zeof  set *fields=$$SPLIT^%MPIECE(row) quit:$$multifieldequal(.fields,.spec)
  set fields=row
  quit *fields

; multifieldequal(fields,spec)
;	- matches the given fields against the given spec
;		* fields and spec must be passed by reference
;		* fields must have [1..n] subscripts with field values
;		* spec must have field number subscripts with field values
;		* matches if the values of the spec fields match the corresponding values in "fields"
;	- returns 1 if matched, 0 otherwise

multifieldequal(fields,spec)
  new sf,matched
  set sf=0,matched=1
  ; iterate over each spec entry and check the corresponding field
  for  set sf=$order(spec(sf))  quit:sf=""  if '$data(fields(sf))!(fields(sf)'[spec(sf))  set matched=0  quit
  quit matched

; firstfieldmatch(fields,str)
;	- returns the first field in fields which has str as a substring
;		* returns empty string if not found
;		* fields must be passed by reference
;		* fields must have [1..n] subscripts with field values

firstfieldmatch(fields,str)
  new match,f
  set match="",f=0
  for  set f=$order(fields(f))  quit:f=""  if fields(f)[str  set match=fields(f)  quit
  quit match


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

io	;Tools to aid in IO devices tests,
	; will print information and open/use/close a device
	; will zshow a device
open(device,openpararametertocontrolbehavior,encoding,timeout) ; OPEN device with the parameters supplied
        if '$DATA(openpararametertocontrolbehavior) set openpararametertocontrolbehavior="append"
	if $l(openpararametertocontrolbehavior)  do
	. if $l(encoding) do
	. . if $DATA(timeout) s openargument=""""_device_""":("_openpararametertocontrolbehavior_":CHSET="_""""_encoding_""""_"):"_timeout
	. . else  set openargument=""""_device_""":("_openpararametertocontrolbehavior_":CHSET="_""""_encoding_""""_")"
	. else  do
	. . if $DATA(timeout) s openargument=""""_device_""":("_openpararametertocontrolbehavior_"):"_timeout
	. . else  set openargument=""""_device_""":("_openpararametertocontrolbehavior_")"
        if '$L(openpararametertocontrolbehavior)  do
	. if $DATA(timeout) set openargument=""""_device_"""::"_timeout
	. else  set openargument=""""_device_""""
	if $get(verbose)=1 use $PRINCIPAL write "-> OPEN ",openargument,!
        open @openargument
	quit

use(device,useparametertocontrolbehavior)	; USE device with the parameters supplied
        if '$DATA(useparametertocontrolbehavior) set useparametertocontrolbehavior=""
        if $l(useparametertocontrolbehavior) set useargument=""""_device_""":("_useparametertocontrolbehavior_")"
        else  set useargument=""""_device_""""
	if $get(verbose)=1 use $PRINCIPAL write "-> USE ",useargument,!
        use @useargument
	quit

close(device,closeparametertocontrolbehavior)	; CLOSE device with the parameters supplied
        if '$DATA(closeparametertocontrolbehavior) set closeparametertocontrolbehavior=""
        if $l(closeparametertocontrolbehavior) set closeargument=""""_device_""":("_closeparametertocontrolbehavior_")"
        else  set closeargument=""""_device_""""
	if $get(verbose)=1 use $PRINCIPAL write "-> CLOSE ",closeargument,!
        close @closeargument
	quit

showdev(device) ;performs a ZSHOW on the device requested
        new (device)
	set prevdev=$IO
        ZSHOW "D":showtmp
	use $PRINCIPAL
        set tmp="showtmp"
        for  set tmp=$QUERY(@tmp) quit:tmp=""  do
        . if $F(@tmp,device) write "ZSHOW ""D"" output: ",@tmp,!
	use prevdev
        quit

C9L03003394	; check $REFERENCE after a MERGE
  ;
  new (act)
  if '$data(act) new act set act="zshow ""*"""
  new $etrap
  set $etrap="goto err",zl=$zl
  kill ^a,^b,^c
  set (a(1),^a(1))=1,(a("foo","bar"),^a("foo","bar"))="foobar"
  merge ^b=^a
  if "^b"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge ^b(52)=^a
  if "^b(52)"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge ^b=^c
  if "^b"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge ^b(52)=^c
  if "^b(52)"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge ^b=a
  if "^b"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge ^b(52)=a
  if "^b(52)"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge ^b=c
  if "^b"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge ^b(52)=c
  if "^b(52)"'=$reference,$increment(cnt) xecute act
  kill b
  merge b=^a
  if "^a"'=$reference,$increment(cnt) xecute act
  kill b
  merge b(52)=^a
  if "^a"'=$reference,$increment(cnt) xecute act
  kill b
  merge b=^c
  if "^c"'=$reference,$increment(cnt) xecute act
  kill b
  merge b(52)=^c
  if "^c"'=$reference,$increment(cnt) xecute act
  kill b
  merge b=a
  if "^c"'=$reference,$increment(cnt) xecute act
  kill b
  merge b(52)=a
  if "^c"'=$reference,$increment(cnt) xecute act
  kill b
  merge b=c
  if "^c"'=$reference,$increment(cnt) xecute act
  kill ^b
  merge b(52)=c
  if "^b"'=$reference,$increment(cnt) xecute act
end 
  write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
  quit
err
  write !,$zstatus
  xecute act
  if $increment(cnt) set $ecode=""
  set lab=$piece($piece($zstatus,"+"),",",2)
  if "err"=lab zgoto zl:end
  goto @(lab_"+"_($piece($zstatus,"+",2)+1))
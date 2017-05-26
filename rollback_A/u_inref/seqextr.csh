#! /usr/local/bin/tcsh -f
#
foreach t (a b c d e f g h mumps)
  setenv alist `ls -rt $t.mjl*`
  unsetenv aalist
  foreach afile ($alist)
    if !($?aalist) then
      setenv aalist $afile
    else
      setenv aalist "$aalist,$afile"
    endif
  end
  echo " "
  echo "********** $t.mjf **********"
  $MUPIP journal -extra=$t.mjf -forw $aalist
end


tp;
t1;
        FOR i=1:1:5 DO
        . ZTS
        . s ^a(i)=i
        . s ^b(i)="B"_i
        . s ^c(i)="C"_i
        . ZTC
        Q
t2;
        FOR i=1:1:5 DO
        . ZTS
        . s ^a(i)=i*i
        . s ^b(i)=i
        . s ^c(i)=i
        . ZTC
        . h 1
        Q

t3;
        FOR i=1:1:5 DO
        . ZTS
        . s ^c(i)=i*i
        . s ^d(i)=i
        . s ^e(i)=i
        . ZTC
        Q

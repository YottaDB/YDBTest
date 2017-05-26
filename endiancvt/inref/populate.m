populate        ;
        for i=1:1:100 s ^aglobal(i)=i
        for i=1:1:250 s ^bglobal(i)="This is a larger value global"_i
        for i=1:1:500 s ^cglobal(i)=i*i
        quit

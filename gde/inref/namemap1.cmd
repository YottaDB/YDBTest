template ~region ~stdnull
change ~region DEFAULT ~stdnullcoll
ADD ~NAME X(1:10)           ~reg=AREG
ADD ~NAME X(10,:15)         ~reg=BREG
ADD ~NAME X(10,15,:)        ~reg=CREG
ADD ~NAME X($c(0))	    ~reg=DEFAULT
ADD ~NAME X(10,15,"abcd",:) ~reg=DREG
ADD ~NAME X(10,15:)         ~reg=DREG
ADD ~NAME X(10:)            ~reg=DREG
add ~reg AREG ~d=ASEG
add ~reg BREG ~d=BSEG
add ~reg CREG ~d=CSEG
add ~reg DREG ~d=DSEG
add ~seg ASEG ~f=a.dat
add ~seg BSEG ~f=b.dat
add ~seg CSEG ~f=c.dat
add ~seg DSEG ~f=d.dat

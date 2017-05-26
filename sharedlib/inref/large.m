large
    Set filenumber=5
    For i=1:1:filenumber-1 d
    . S filename="a"_i_".m"
    . Open filename Use filename 
    . W " W ""I am in filename"""
    C filename

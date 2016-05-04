subroutine dint3( RANGE,EL,D,VRINT)
 !Numerical integration of 1/V(R-x)
 DOUBLE PRECISION RANGE, EL, D, VRINT,VT
 REAL (8), DIMENSION (100) :: P
REAL (8), DIMENSION (101) :: XK,YK
REAL (8) H, SUMA
 H=(D-EL)/100.D0
 DO I=1,101
XK(I)=EL+H*(I-1)
YK(I)=1.D0/VT(RANGE-XK(I))
END DO
SUMA=0.D0
 DO I=1,100
P(I)=(YK(I)+YK(I+1))/2.D0 *H
SUMA=SUMA+P(I)
END DO
 VRINT=SUMA
END SUBROUTINE DINT3
  


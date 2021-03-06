SUBROUTINE TRACK_OPTICS_P( N,NC,NPOINT,X,Y,Z,FINALRES, CRNIDEO)
!SIMULATE THE TRANSPORT OF LIGHT THROUGH THE TRACK.
							  
IMPLICIT REAL (8) (A-H, O-Z)
REAL(4) CRNIDEO
ALLOCATABLE :: XT(:),YT(:),ZT(:)
REAL(8), ALLOCATABLE :: SJAJ(:)
ALLOCATABLE :: X1(:),X2(:),X3(:),X4(:),Y1(:),Y2(:),Y3(:),Y4(:),Z1(:),Z2(:),Z3(:),Z4(:), SURFACE(:)
REAL (8), ALLOCATABLE :: NX(:),NY(:),NZ(:)			! NORMAL ON POLYGON DIRECTED INSIDE THE TRACK
REAL (8), ALLOCATABLE :: XUDAR(:),YUDAR(:),ZUDAR(:)
ALLOCATABLE ::IVIDIO(:)								!INDICATES IS THE POLYGON SEEN FROM ABOVE
REAL (8) :: INDEXP									!REFRACTION INDEX
 
REAL (8), DIMENSION(N),INTENT(IN):: X ,Y ,Z 
REAL (8), DIMENSION(NC,9), INTENT(OUT):: FINALRES	 


OPEN(25,FILE='BE.DAT')

INDEXP = 1.5D0 !INDEX OF REFRECTION CR-39
 
 PI=4.D0*DATAN(1.D0)
 ALFATOT=DASIN(1.D0/INDEXP)
 

PRINT *, 'TOTAL NUMBER OF POINTS REPRESENTING THE TRACK IN 3-D IS N=',N		

ALLOCATE ( XT(N),YT(N),ZT(N) )			

XT=X
YT=Y
ZT=Z 	    
 
 					   
NPOINT2=2*NPOINT-2  !NUMBER OF POINTS ON THE CIRCLE NPOINT2, IF THE NUMBER OF POINT ON HALF OF CIRCLE IS NPOINT
  


KRUGOVA=N/NPOINT2 

NC=(KRUGOVA-1)*NPOINT2   !NUMBER OF POLYGONS

PRINT *, 'NUMBER OF POLYGONS REPRESENTING TRACK IS',NC
ALLOCATE (SJAJ(NC))							!SJAJ IS BRIGHTNESS LEVEL OF SOME POLYGON
ALLOCATE (X1(NC),X2(NC),X3(NC),X4(NC),Y1(NC),Y2(NC),Y3(NC),Y4(NC),Z1(NC),Z2(NC),Z3(NC),Z4(NC))
ALLOCATE (SURFACE(NC))  ! THE SURFACE AREA OF POLYGONS
ALLOCATE (IVIDIO(NC))

ALLOCATE (NX(NC),NY(NC),NZ(NC))		    	!NORMALS ON POLYGONS
ALLOCATE (XUDAR(NC),YUDAR(NC),ZUDAR(NC))	!MIDDLE POINTS OF POLYGONS

 IVIDIO=1
L=1											!THIS INDEX L REFERS TO THE POLYGON NUMBER
CRNO=0.
DO K=1,KRUGOVA-1   
DO I=NPOINT2*K-NPOINT2+1,NPOINT2*K 		
 
IF(I<NPOINT2*K)THEN
XPRVI=XT(I)
YPRVI=YT(I)
ZPRVI=ZT(I)
XDRUGI=XT(I+1)
YDRUGI=YT(I+1)
ZDRUGI=ZT(I+1) 
XTRECI=XT(I+NPOINT2)
YTRECI=YT(I+NPOINT2)
ZTRECI=ZT(I+NPOINT2)					
XCETVRTI=XT(I+NPOINT2+1)				!POINT 3 IS BELOW POINT 1, POINT 4 IS BELOW POINT 2		
YCETVRTI=YT(I+NPOINT2+1)
ZCETVRTI=ZT(I+NPOINT2+1)

X1(L)=XPRVI 
Y1(L)=YPRVI
Z1(L)=ZPRVI

X2(L)=XDRUGI
Y2(L)=YDRUGI
Z2(L)=ZDRUGI

X3(L)=XTRECI
Y3(L)=YTRECI
Z3(L)=ZTRECI

X4(L)=XCETVRTI
Y4(L)=YCETVRTI
Z4(L)=ZCETVRTI
END IF


IF(I==NPOINT2*K)THEN	!THE LAST POLYGON, SPECIAL TREATMEN
  
XPRVI=XT(I)
YPRVI=YT(I)
ZPRVI=ZT(I)

XDRUGI=XT(I-NPOINT2+1)
YDRUGI=YT(I-NPOINT2+1)
ZDRUGI=ZT(I-NPOINT2+1)

XTRECI=XT(I+NPOINT2)
YTRECI=YT(I+NPOINT2)		   
ZTRECI=ZT(I+NPOINT2)

XCETVRTI=XT(I+1)
YCETVRTI=YT(I+1)
ZCETVRTI=ZT(I+1)

X1(L)=XPRVI 
Y1(L)=YPRVI
Z1(L)=ZPRVI
X2(L)=XDRUGI
Y2(L)=YDRUGI
Z2(L)=ZDRUGI

X3(L)=XTRECI
Y3(L)=YTRECI
Z3(L)=ZTRECI
X4(L)=XCETVRTI
Y4(L)=YCETVRTI
Z4(L)=ZCETVRTI
END IF

 
CALL ANORMALA(XPRVI,YPRVI,ZPRVI,XDRUGI,YDRUGI,ZDRUGI,XTRECI,YTRECI,ZTRECI,XCETVRTI,YCETVRTI,ZCETVRTI,NX(L),NY(L),NZ(L))
   
XUDAR(L)=(XPRVI+XDRUGI+XTRECI+XCETVRTI)/4.	!MIDDLE POINT OF POLYGON IS REPRESENTATIVE FOR WHOLE POLYGON
YUDAR(L)=(YPRVI+YDRUGI+YTRECI+YCETVRTI)/4.
ZUDAR(L)=(ZPRVI+ZDRUGI+ZTRECI+ZCETVRTI)/4.
SURFACE(L) =ABS(NZ(L))* SQRT( ( XPRVI-XDRUGI)**2+(YPRVI-YDRUGI)**2+(ZPRVI-ZDRUGI)**2)*SQRT( (XPRVI-XTRECI)**2 + &
(YPRVI-YTRECI)**2+(ZPRVI-ZTRECI)**2 )
 L=L+1
END DO
END DO

 					
L=L-1


DO I=1,NC   !LOOP VARY POLYGONS, I IS  THE NUMBER OF POLYGON

 IF(NZ(I)<0.)THEN
IVIDIO(I)=-1		 
CYCLE
END IF
							  

PX=0.		!RAYS PROPAGATE IN VERTICAL DIRECTION UP AND THEY ARE PARALLEL
PY=0. 		   			   
PZ=1.

 				
UGAO=DACOS(NX(I)*PX+NY(I)*PY+NZ(I)*PZ)
 IND=0

 IF(UGAO>ALFATOT)THEN
IND=1
SJAJ(I)=0.				!TOTAL REFLEXION 


WRITE(25,100)X1(I),Y1(I),X2(I),Y2(I),X3(I),Y3(I),X4(I),Y4(I),SJAJ(I)		
FINALRES(I,1)=X1(I)
FINALRES(I,2)=Y1(I)
FINALRES(I,3)=X2(I)
FINALRES(I,4)=Y2(I)
FINALRES(I,5)=X3(I)
FINALRES(I,6)=Y3(I)
FINALRES(I,7)=X4(I)
FINALRES(I,8)=Y4(I)
FINALRES(I,9)=SJAJ(I)
CRNO=CRNO+SURFACE(I)
CYCLE ! THE BRIGHTNESS OF THE ELEMENT IS ZERO
 ELSE
  END IF
  
  SJAJ(I)=DEO(INDEXP,UGAO)
			   
CALL PRELOM(INDEXP,PX,PY,PZ,NX(I),NY(I),NZ(I),P1X,P1Y,P1Z)	!refraction
   
T=-ZUDAR(I)/P1Z
XRAVAN=XUDAR(I)+T*P1X		 
YRAVAN=YUDAR(I)+T*P1Y		 

 
IZASO=0 ! indicates does the ray exit on the track opening or not. IZASO=0  means ray did  not exit on the opening

J=1

DO   

 
IF(XRAVAN<XT(J).AND.XRAVAN>=XT(J+1)) THEN	
AK=(YT(J+1)-YT(J) )/(XT(J+1)-XT(J))
EN=YT(J)-AK*XT(J)

YPRES=AK*XRAVAN+EN
IF (YRAVAN<DABS(YPRES))THEN
!IF(DABS(YRAVAN)<DABS(YT(J))) THEN !ray exit on the opening
SJAJ(I)=SJAJ(I)*P1Z    
WRITE(25,100)X1(I),Y1(I),X2(I),Y2(I),X3(I),Y3(I),X4(I),Y4(I),SJAJ(I)
FINALRES(I,1)=X1(I)
FINALRES(I,2)=Y1(I)
FINALRES(I,3)=X2(I)
FINALRES(I,4)=Y2(I)
FINALRES(I,5)=X3(I)
FINALRES(I,6)=Y3(I)
FINALRES(I,7)=X4(I)
FINALRES(I,8)=Y4(I)
FINALRES(I,9)=SJAJ(I)

 
	IZASO=1
 	
	EXIT
	END IF

	END IF
	J=J+1
	IF(J>NPOINT-1)EXIT
END DO
 IF(IZASO==1)CYCLE	    

								!ray comeback in the detector body
   
	NPOVRATAK=NPOVRATAK+1		!counts how many tracks return in the detector, only for control
 								
 	CALL TACKA_POVRATKA()		!determines the point where ray comeback in the detector
	 
 ALFA=DACOS(NX(JJ)*P1X+NY(JJ)*P1Y+NZ(JJ)*P1Z)		
   
 IF(ALFA>PI/2.)  ALFA=PI-ALFA
					 			     
		TRA=DEO(INDEXP,ALFA)
		SJAJ(I)=SJAJ(I)*TRA
 	
CALL PRELOMGR(P1X,P1Y,P1Z,-NX(JJ),-NY(JJ),-NZ(JJ),P2X,P2Y,P2Z)
  	FI=DACOS(P2Z)
 	IF(FI>ALFATOT)THEN		!TOTAL REFLECTION ON THE DETECTOR SURFACE 
T=-ZUDAR(JJ)/P2Z				
XRAVAN=XUDAR(JJ)+T*P2X		
YRAVAN=YUDAR(JJ)+T*P2Y
SJAJ(I)=0.
CRNO=CRNO+SURFACE(I)
 
		ELSE												  
      !point where the ray come to the detector post etch surface

T=-ZUDAR(JJ)/P2Z				
XRAVAN=XUDAR(JJ)+T*P2X		
YRAVAN=YUDAR(JJ)+T*P2Y
TRA=DEO(INDEXP,FI)
SJAJ(I)=SJAJ(I)*TRA			!grey level of particular elements
CALL PRELOM(INDEXP,P2X,P2Y,P2Z,0.D0,0.D0,1.D0,P3X,P3Y,P3Z)
SJAJ(I)=SJAJ(I)*P3Z
END IF

				         		    
WRITE(25,100)X1(I),Y1(I),X2(I),Y2(I),X3(I),Y3(I),X4(I),Y4(I),SJAJ(I) 	
FINALRES(I,1)=X1(I)
FINALRES(I,2)=Y1(I)
FINALRES(I,3)=X2(I)
FINALRES(I,4)=Y2(I)
FINALRES(I,5)=X3(I)
FINALRES(I,6)=Y3(I)
FINALRES(I,7)=X4(I)
FINALRES(I,8)=Y4(I)
FINALRES(I,9)=SJAJ(I)
CYCLE			     
 
									   
END DO  !END OF LOOP THAT VARIES THE POLYGONS 
	 		   
100 FORMAT(' ', 8(D12.4,3X),F8.5)
!PRINT *, SURFACE


PRINT *, 'PROJECTED TRACK SURFACE', SUM(SURFACE)
 CRNIDEO=CRNO/SUM(SURFACE)
!PRINT *, 'PART OF BLACK SURFACE', CRNIDEO

CLOSE (25)  							     
CONTAINS			   	    

SUBROUTINE TACKA_POVRATKA()
!DETERMINE THE POINT WHERE THE RAY COMEBACK IN THE BODY OF THE DETECTOR	
IMPLICIT REAL (8) (A-H, O-Z)
DIMENSION :: ALFAS(N)   

ALFAMIN=1.E5							  

DO M=I-1,1,-1

DX=XUDAR(M)-XUDAR(I)
DY=YUDAR(M)-YUDAR(I)
DZ=ZUDAR(M)-ZUDAR(I)

ANORMA=SQRT(DX**2+DY**2+DZ**2)

DX=DX/ANORMA
DY=DY/ANORMA
DZ=DZ/ANORMA
 
ALFAS(M)=ACOS(DX*P1X+DY*P1Y+DZ*P1Z)

IF(ALFAS(M)<ALFAMIN)THEN
ALFAMIN=ALFAS(M)
JJ=M			!JJ IS THE NUMBER OF POLYGON 
END IF

END DO

ANAJ=ALFAMIN

END SUBROUTINE TACKA_POVRATKA

END 





		   




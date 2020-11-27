;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_clean_standardize
;
; PURPOSE           : standardizing the image to given parameters by rotating
;                     and shrinking/stretching  i.e. ellipse to cirle
;
; EXPLANATION       : Having determined the elliptical geometry of a solar limb using egso_limb_efit function
;                     a single transformation combining all the geometrical corrections is applied in order
;                     to correct the shape back to a circle before applying the limb darkening corrections,
;
;
; CALLING SEQUENCE  : egso_clean_standardize, image, xc, yc, R1, R2, theta, N1, N2, Rad, xcn, ycn
;
;
; INPUT             : image       input image
;                     xc, yc      ellipse (disk) centre coordinates
;                     R1, R2      ellipse axis
;                     theta       ellipse angle
;                     N1, N2      dimensions of the resulting image
;                     Rad         Radius of the target disk
;                     xcen, ycen  pixel coordinates for the new disk centre
;
; OUTPUT            : result   Standardize cleaned with N1 by N2 with circular Sun disk of Rad radius
;
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : None
;
; EXAMPLE           : cs_im = egso_clean_standardize (image, xc, yc, R1, R2, theta, 1024, 1024, 420, 511.5, 511.5)
;
; SIDE EFFECTS      : None
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003   added percent keyword
;
;========================================================================================================================

function egso_clean_standardize, image, xc, yc, R1, R2, theta, N1, N2, Rad, xcn, ycn



info=size(image)
nx=info[1]
ny=info[2]


Sx=double(R1)/Rad
Sy=double(R2)/Rad

St=sin(theta)
Ct=cos(theta)



;St=sin(theta*!pi/180)
;Ct=cos(theta*!pi/180)


;xcn=(N1-1)/2.
;ycn=(N2-1)/2.

;   set up the transfromation matrix

A11=Sx*Ct*Ct+Sy*St*St
A12=St*Ct*(Sx-Sy)
A21=A12
A22=Sx*St*St+Sy*Ct*Ct

d1=A11*(xc-xcn)+A12*(yc-ycn)
d2=A21*(xc-xcn)+A22*(yc-ycn)

imR=intarr(N1,N1)


for i=0, N2-1 do $
    for j=0, N1-1 do begin
       xn=A11*(j-xc)+A12*(i-yc)
       yn=A21*(j-xc)+A22*(i-yc)
       n=fix(xn+xc+d1+.5)
       m=fix(yn+yc+d2+.5)
       if n lt nx and m lt ny and n ge 0 and m ge 0 then begin
          imR[j,i]=image[n, m]
          endif else imR[j,i]=0
endfor


return, imR



end


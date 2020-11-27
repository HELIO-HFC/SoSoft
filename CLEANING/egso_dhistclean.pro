;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_dhistclean
;
; PURPOSE           : Distance Histogram cleaning
;
; EXPLANATION       : Distance Histogram cleaning
;
;
; CATEGORY          : EGSO_WP5, Fitting an Ellipse
;
; CALLING SEQUENCE  : egso_dhistclean, binary, xc, yc, R, R1, R2, flag
;
;
; INPUT             : binary   binary image (representing the full sun disk)
;                     xc, yc   gravity centre pixel coordinates
;                     R        Initial Radius Estimate
;
; OUTPUT            : R1, R2
;                     flag     0 if cleaning is successful, 1 otherwise
;
; KEYWORDS          : None
;
; PROCEDURE         : egso_dhistclean, binary, xc, yc, R, R1, R2, flag
;
; CALLS             : cv_coord
;
; EXAMPLE           : egso_dhistclean, binary, xc, yc, R, R1, R2, flag
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================


pro egso_dhistclean, binary, xc, yc, R, R1, R2, flag


;im=binary
info=size(binary)
nx=info[1]
ny=info[2]
di=xc<(nx-xc)<yc<(ny-yc)>(R+10) ;>R+10 nf2005


x=(di-2.)*(di-2.)

nelm=fix(di+.5)
DistH_arr=intarr(nelm)

count=0ul

;
;   !!!   loop can be substituted by one going through all non-zero locations !!!
;
;   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
for i=0, nx-1,1 do $
for j=0, ny-1,1 do $
    if binary[i,j] ne 0 then begin
       dd=(xc-i)^2+(yc-j)^2
       d=fix(sqrt(dd)+.5)
       if dd lt x then begin
         count=count+1
         DistH_arr[d]=DistH_arr[d]+1
       endif
    end

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;   print, 'Count:', count
;nf2004:2.5->1.5
;print,count,2.2*!pi*R
if count lt 2.2 * !pi * R then flag=1 else begin
    flag=0


; work outwards and inwards from the initial radius counting edge pixels until the total count reaches two pi R
; add a distance margin to ensure all limb pixels included
         R1 = long (R+0.5)
         R2 = long (R+0.5)

         count1 = DistH_arr[R1] ;
         print, 'target:', 2.0*!pi*R
         while (count1 lt 2.0*!pi*R) do begin
          R2=R2+1
           if (R2 gt nelm-1) then break else count1 = count1+DistH_arr[R2]
          R1=R1-1
          if R1 lt 0 then break else count1 = count1+DistH_arr[R1]
         endwhile

;     print, 'result:', count1, ' counts'
       R1=R1-5
       R2=R2+5

       print, 'Radius:', R1, R2
endelse
end

;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_pol2pixarray
;
; PURPOSE           : Transferring polar coordinate image to rectangular
;
; EXPLANATION       : Transferring polar coordinate image to rectangular
;
;
; CATEGORY          : EGSO_WP5, Image Cleanning
;
; CALLING SEQUENCE  : egso_pol2pixarray, image, pixel_array, R1, xc, yc
;
;
; INPUT             : image         ?????
;                     pixel_array   image
;                     R1            disk Radius
;                     xc, yc        disk centre coordinates
;
; OUTPUT            : rectangular array corresponding to the initial disk of radius R
;                     centred at xc, yc
;
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : None
;
; EXAMPLE           : reconstructed_median2 = egso_pol2pixarray(image, p_arr_median2, R, xc,yc)
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================
function egso_pol2pixarray, image, pixel_array, R1, xc, yc


info=size(image)

image1x = info[1]
image1y = info[2]


imbg = MAKE_ARRAY(image1x,image1y, /INT, VALUE = 0)
Rmax=fix(R1)
FOR i=0, image1x-1 DO BEGIN
    FOR j=0, image1y-1 DO BEGIN

       ixc = (i - xc)
       jyc = (j - yc)
       rr = jyc^2 + ixc^2
       r  = fix(SQRT(rr)+0.5)

       IF r LT Rmax THEN BEGIN

         theta = ATAN(jyc,ixc)

         IF (theta LT 0)THEN theta = ((2*!DPI) + theta)
         ;theta1 = LONG((theta *1023)/(2*!DPI) + 0.5)
         ;    theta1 = LONG((theta *image1x)/(2*!DPI) + 0.5)
         theta1 = fix((theta *(image1x-1))/(2*!DPI) + 0.5)
         imbg(i,j) = pixel_array(theta1,r)



       ENDIF ;r LE Rmax-1 (i.e. inside the disk)
    ENDFOR
ENDFOR

return, imbg
end


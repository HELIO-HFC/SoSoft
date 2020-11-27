;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_pix2polarray
;
; PURPOSE           : Transferring rectangular image to polar coordinate
;
; EXPLANATION       : Transferring rectangular image to polar coordinate
;
;
; CATEGORY          : EGSO_WP5, Image Cleanning
;
; CALLING SEQUENCE  : egso_pix2polarray, image, R, xc, yc
;
;
; INPUT             : image         image
;                     R1            disk Radius
;                     xc, yc        disk centre coordinates
;
; OUTPUT            : polar coordimnate  image corresponding to the initial disk of radius R
;                     centred at xc, yc
;
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : None
;
; EXAMPLE           : p_arr_median2 = egso_pix2polarray(image, R, xc,yc)
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================
function egso_pix2polarray, image, R, xc, yc



info=size(image)

image1x = info[1]
image1y = info[2]

Rmax=fix(R)
Rmax2 = Rmax*Rmax
R2PI = fix (2 * !DPI * Rmax +0.5)

pixel_array = MAKE_ARRAY(image1x, Rmax, /INT, VALUE = 0)

FOR i=0, Rmax-1 DO BEGIN
    FOR j=0, image1x-1 DO BEGIN
       ; i  r
       ; j is the widith of Array
       ; theta = j * ((2*!DPI)/image1x)
       theta = j * ((2*!DPI)/(image1x-1))
       x = i * COS(theta)
       y = i * SIN(theta)
       X= fix(x+xc+0.5)
       Y= fix(y+yc+0.5)
       pixel_array(j,i) = image(X,Y)
    ENDFOR
ENDFOR

return, pixel_array

end

;==========================================================================
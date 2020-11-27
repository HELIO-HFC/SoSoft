;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_gcentre
;
; PURPOSE           : Calculates the gravity centre of the input image
;
; EXPLANATION       : Calculates the gravity centre of the input image that includes one object (which the sun disk in this case)
;
;
; CATEGORY          : EGSO_WP5, Fitting an Ellipse
;
; CALLING SEQUENCE  : egso_gcentre, im
;
;
; INPUT             : im    Image
;
;
; OUTPUT            : cc    gravity centre coordinates
;
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : None
;
; Restrictions      : Grayscale Input Image (use of size function)
;
; EXAMPLE           : grv_cen= egso_gcentre (imageB)
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================

function egso_gcentre, im


info=size(im)
nx=info[1]
ny=info[2]
cc=dblarr(2)

sum=0.D0
xmom=0.D0
ymom=0.D0

for i=0,nx-1,1 do $
    for j=0, ny-1,1 do begin
       sum=sum+im[i,j]
       xmom=xmom+double(im[i,j])*double(i)
       ymom=ymom+double(im[i,j])*double(j)
    end
cc[0]=xmom/sum
cc[1]=ymom/sum

return, cc
end


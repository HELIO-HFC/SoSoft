;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_ellipsefit
;
; PURPOSE           : fitting the ellipse to the binary image
;
; EXPLANATION       : fitting the ellipse to the binary image
;
;
; CATEGORY          : EGSO_WP5, Fitting an Ellipse
;
; CALLING SEQUENCE  : egso_ellipsefit, binary, xc, yc, xc1, yc1, R1, R2, theta, stdev, stdevGeo, algerr
;
;
; INPUT             :  binary    cleaned binary image
;                      xc, yc    gravity centre coordinates in pixel coordinates
;
; OUTPUT            : xc1, yc1   ellipse centre coordiinates
;                     R1, R2     ellipse axis
;                     theta      ellipse angle
;                     stdev      fits standard deviation (algebraic)
;                     stdevGeo   fits standard deviation (geometric)
;                     algerr     fits algebraic error
;
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : fitellipselsq, egso_efiterr, egso_ealgdata
;
; EXAMPLE           : egso_ellipsefit, binary2, xc, yc,  xc1, yc1, R1, R2, theta, stdev, stdevGeo, algerr
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================
pro egso_ellipsefit, binary, xc, yc, xc1, yc1, R1, R2, theta, stdev, stdevGeo, algerr

binary_copy=binary
vector=fitellipselsq(binary,  xc, yc)
print, 'first fit'

egso_ealgdata, xc, yc, vector, xc1, yc1, R1, R2, theta

count=0
stdev=1.
while stdev ge .3e-02 and count lt 200 do begin
       count=count+1

       vector=fitellipselsq(binary,  xc, yc)
       egso_efiterr, binary, xc, yc, vector, binary2, stdev
       binary=binary2
endwhile

       vector=fitellipselsq(binary,  xc, yc)
       egso_ealgdata, xc, yc, vector, xc1, yc1, R1, R2, theta
       color=max(binary)/2


egso_efiterr, binary, xc, yc, vector, binary2, stdev, stdevGeo, algerr, geoErr

;stdev=stdev
;stdevGeo=stdevGeo
;algerr=algerr


end
;=============================================================================

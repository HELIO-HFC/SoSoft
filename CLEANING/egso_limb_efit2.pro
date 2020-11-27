;+
; PROJECT          : EGSO, WP5
;
; NAME              : egso_limb_efit
;
; PURPOSE           : Fitting an Ellipse to the Full Disk Solar Image
;
; EXPLANATION       : The limb fitting method has the following three stages:
;                     (1) an initial approximation of the disk centre and radius is computed;
;                     (2) edge-detection is performed using the Canny edge detection algorithm
;                         with selection of candidate points for fitting to an ellipse using
;                         information from the initial estimate
;                     (3) an ellipse is fitted to the candidate limb points using a least squares
;                         approach, iteratively removing points which are off the limb
;
;
; CALLING SEQUENCE  : egso_limb_efit, im, xc, yc, R1, R2, theta [percent=percent, /verbose, /e_specific]
;
;
; INPUT             : image     The full disk solar image
;
; OUTPUT            : xc1, yc1  ellipse centre pixel coordinates
;                     R1, R2      ellipse axis
;                     theta     angle
;                     stdev     standard deviation
;                     stdevGeo    standard deviation geometric
;                     algerr  algebraic error
;                     binary  cleaned binary image for the last fit (to be removed)
;                     binary2 initial binary image (to be removed?)
;
; KEYWORDS          : e_specific    if set non_svd (ellipse specific) algorithm is used for fitting (useful when testing)
;                     percent
;                     verbose
;
; PROCEDURE         :
;
; CALLS             : egso_clim, egso_gcentre, egso_clbin, egso_checkgap, egso_dhistclean,
;                     gauss_smoothing, canny, egso_ellipsefit, egso_ellipsefitsvd
;
; EXAMPLE           :
;
; SIDE EFFECTS      : not reliable when working with 8-bit data due to current implementation of Canny (to be resolved soon)
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003   added percent keyword
;                        02-06-2004   NF added prominence keyword and
;                        clean code
;                        Apr 2005     NF copy of egso_limb_efit ->
;                                     threshold becomes a input 
;=============================================================================================================================

pro egso_limb_efit2, image,thr, xc1, yc1, R1, R2, theta, stdev, stdevGeo, algerr, $
                  e_specific=e_specific, verbose=verbose, binary, binary2,prom=prom


print,'Version2'
info=size(image)
nx=info[1]
ny=info[2]
type=info[3]


; checking input image data type (see KNOWN ISSUES)
; if not byte or integer, then scaling to Byte
if type ne 1 and type ne 2 then image=bytscl(image)
image_copy=image


cenx=nx/2.
ceny=ny/2.
box_size=(nx < ny) /16

thr_value = thr
ww = WHERE(image GT thr)
ave_value = MEAN(image[ww])

if keyword_set(verbose) then begin
    print, 'Threshold Value:', thr_value
    print, 'Average Value:', ave_value
endif



; Clean Image by LabelRegion
egso_clim, image, thr_value, imageB, count

; (OR) Clean Image by rastering
;imageB=image
;ww=WHERE(image GT thr_value AND image LT MAX(image),count,comp=wwcomp)
;imageB[wwcomp]=0

tvscl,CONGRID(imageB,510,456),512,0

R=sqrt(double(count)/!pi)

; calculate the gravity centre of the cleaned image
grv_cen= egso_gcentre(imageB GE thr_value) ;nf (prise en compte du disque mais pas de ses valeurs pour le calcul du centre de gravite)
;;;grv_cen= egso_gcentre(imageB) ;original


if keyword_set(verbose) then begin
    print, 'Count:', count
    print, 'Radius:', R
    print, 'Gravity Centre:', grv_cen
endif
xc=grv_cen[0]
yc=grv_cen[1]

; produce the binary image suitable for the ellipse fit

im=gauss_smoothing(image_copy, 2l)
IF KEYWORD_SET(prom) THEN BEGIN
 im[WHERE(im GT thr_value)]=thr_value
ENDIF

;im[WHERE(im GE thr_value)]=2000. ;nf pour debut 96/97


if type eq 2 then begin
         CannyUpperThreshold=400
         CannyDelta=40
         CannyLowerThreshold=40
  IF thr_value LT 1000. THEN BEGIN ;nf
         CannyUpperThreshold=200   ;nf
         CannyDelta=20             ;nf
         CannyLowerThreshold=20    ;nf
     ENDIF                         ;nf
endif else begin
          CannyUpperThreshold=50
          CannyDelta=5
          CannyLowerThreshold=5
endelse


times=0

; Ellipse Fitting Loop:
jump0:  binary=canny(im, CannyUpperThreshold, CannyLowerThreshold)

        tvscl,CONGRID(binary,510,456,/interp),512,0


       egso_dhistclean, binary, xc, yc, R, R1, R2, flag
       times=times+1
;flag=0
       if flag eq 1 and times lt 12 then begin
         if keyword_set(verbose) then $
          print, 'Not Enough Points, Changing Threshold'
         CannyUpperThreshold=CannyUpperThreshold-CannyDelta

       ; print, times, canny_threshold
         goto, jump0
       endif
       if flag eq 1 then begin
         print,'Failed. Could not determine Canny Threshold.'
	       ;RLT=dialog_message('Failed. Could not determine Canny Threshold', /error)
         retall
     end
;egso_clbin?can be supp in some cases
       IF KEYWORD_SET(prom) THEN R2=R2-5
       binary=egso_clbin(binary, xc, yc, R1, R2 )
       tvscl,CONGRID(binary,510,456,/interp),512,0
       gap=egso_checkgap(binary, xc, yc)
       if keyword_set(verbose) then $
         print, 'gap=', gap
       if gap gt 20 and times lt 12 then begin
         if keyword_set(verbose) then $
          print, 'Big Gap, Changing Threshold'
         CannyUpperThreshold=CannyUpperThreshold-CannyDelta
       ; print, times, canny_threshold
         goto, jump0
       endif

; fit the ellipse to the binary image using SVD fit procedure
binary2=binary


if keyword_set(e_specific) then $
    egso_ellipsefit, binary2, xc, yc,  xc1, yc1, R1, R2, theta, stdev, stdevGeo, algerr $
    else egso_ellipsefitsvd, binary2, xc, yc,  xc1, yc1, R1, R2, theta, stdev, stdevGeo, algerr
end










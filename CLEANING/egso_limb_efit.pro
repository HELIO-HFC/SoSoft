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
;=============================================================================================================================

pro egso_limb_efit, image, xc1, yc1, R1, R2, theta, stdev, stdevGeo, algerr, percent=percent, $
                  e_specific=e_specific, verbose=verbose, binary, binary2,prom=prom



	  print,'New Version'
info=size(image)
nx=info[1]
ny=info[2]
type=info[3]


; checking input image data type (see KNOWN ISSUES)
; if not byte or integer, then scaling to Byte
;if type ne 1 and type ne 2 then image=bytscl(image)

;NF 2013 quelque soit l'image (diff de byte) on passe en byte
if type ne 1 then BEGIN
   image=bytscl(image)
   print,'image scale to byte'
endif
image_copy=image


cenx=nx/2.
ceny=ny/2.
box_size=(nx < ny) /16

HistImage=histogram(image)
n=n_elements(HistImage)

; Generate a Smoothed Histogram

 Ni=n/128
 AveHistImage = SMOOTH(HistImage,2*Ni) ;(no edge_truncate)

; Get average intensity value around the centre of the image

 average=MEAN(image[FIX(cenx+0.5-box_size):FIX(cenx+0.5+box_size),$
                    FIX(ceny+0.5-box_size):FIX(ceny+0.5+box_size)])
 ave_value=long(average+.5)

; Analyse Histogram to get the cutoff intensity around limb

 ind=fix(average+.5)

 value=AveHistImage[ind]
 print, keyword_set(percent)

if not keyword_set(percent) then percent= 0.2 ;.05


  while ind gt 2 and (HistImage[ind-1] lt HistImage[ind] or HistImage[ind] gt percent*value) do ind=ind-1


;;IF MAX(image) LT 256 THEN BEGIN
;;thr_value=1
;;if keyword_set(verbose) then begin
;;    print, 'Threshold Value:', thr_value
;;    print, 'Average Value:', ave_value
;;endif
;;GOTO,next8b
;;ENDIF


thr_value=ind*0.7;> 0.93*ave_value;
;thr_value=500
goto,nocalcul

;###CALCUL THRESOLD par analyse de la derivee de la courbe
;###du nombre de point de valeur sup. a thr_value
 tabl=LONARR(45)
 vari=0.6
 FOR ii=0,44 DO BEGIN
   ww=WHERE(image GT vari*ave_value,cci)
   vari=vari+0.01
   tabl[ii]=cci
 ENDFOR
 tabl2=(tabl-SHIFT(tabl,-1))[0:43]

 indi=WHERE(tabl2 EQ MAX(tabl2))
 indi = indi[0]
 WHILE tabl2[indi] GT tabl2[indi-1] AND indi GT 0 DO indi=indi-1
 IF indi[0] EQ 0 THEN BEGIN
   	print,'Failed. Could not find threshold cutoff value'
	 ;RLT=dialog_message('Failed. Could not find threshold cutoff value', /error)
   RETALL
 ENDIF
 IF indi[0] GT 40 THEN BEGIN
	 print,'Failed. Could not find threshold cutoff value'
   ;RLT=dialog_message('Failed. Could not find threshold cutoff value', /error)
   RETALL
 ENDIF 
 thr_value=(indi[0]*0.01+vari)*ave_value
;#####
nocalcul:


if keyword_set(verbose) then begin
    print, 'Threshold Value:', thr_value
    print, 'Average Value:', ave_value
endif


; If threshold value found is equal to zero then stop
if thr_value lt 5 then begin
    print,'Failed. Could not find threshold cutoff value'
	;RLT=dialog_message('Failed. Could not find threshold cutoff value', /error)
    retall
endif

next8b:

; Clean Image by LabelRegion
egso_clim, image, thr_value, imageB, count

; (OR) Clean Image by rastering
;imageB=image
;ww=WHERE(image GT thr_value AND image LT MAX(image),count,comp=wwcomp)
;imageB[wwcomp]=0

;Renaud
;tvscl,CONGRID(imageB,512,FIX(512*(ny*1./nx))),550,0

R=sqrt(double(count)/!pi)

; calculate the gravity centre of the cleaned image
grv_cen= egso_gcentre(imageB GE thr_value) ;nf (prise en compte du disque mais pas de ses valeurs pour le calcul du centre de gravite)
;;;grv_cen= egso_gcentre(imageB) ;original


if keyword_set(verbose) then begin
    print, 'Count:', count
    print, 'Radius:', R
    print, 'Gravity Centre:.........', grv_cen
endif
xc=grv_cen[0]
yc=grv_cen[1]

; produce the binary image suitable for the ellipse fit

im=gauss_smoothing(image_copy, 2l)

IF KEYWORD_SET(prom) THEN BEGIN
 ;im[WHERE(im GT thr_value)]=thr_value
 im = (im GT thr_value)*thr_value
ENDIF

;im[WHERE(im GE thr_value)]=2000. ;nf pour debut 96/97


if type eq 2 then begin
        CannyUpperThreshold=400
        CannyDelta=40
        CannyLowerThreshold=40
	IF ave_value LT 1100. THEN BEGIN ;nf
        	CannyUpperThreshold=300   ;nf
        	CannyDelta=30             ;nf
        	CannyLowerThreshold=30    ;nf
     	ENDIF                         ;nf
endif else begin
        CannyUpperThreshold=50
        CannyDelta=5
        CannyLowerThreshold=5
endelse

CannyUpperThreshold=20 ;nf temporaire heliograph 28oct2003
CannyDelta=2           ;nf "
CannyLowerThreshold=2  ;nf "


times=0

; Ellipse Fitting Loop:
jump0:  binary=canny(im, CannyUpperThreshold, CannyLowerThreshold)

	;Renaud
        ;tvscl,CONGRID(binary,512,FIX(512*(ny*1./nx))),550,0

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
         print,'Failed. Could not determine Cnny Threshold'
	       ;RLT=dialog_message('Failed. Could not determine Canny Threshold', /error)
         retall
     end
;egso_clbin?can be supp in some cases
       IF KEYWORD_SET(prom) THEN R2=R2-5
       binary=egso_clbin(binary, xc, yc, R1, R2 )
       ;Renaud
       ;tvscl,CONGRID(binary,512,FIX(512*(ny*1./nx))),550,0
       gap=egso_checkgap(binary, xc, yc)
       if keyword_set(verbose) then $
         print, 'gap=', gap
       if gap gt 30 and times lt 12 then begin
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










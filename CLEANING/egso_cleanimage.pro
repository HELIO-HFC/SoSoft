;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_CleanImage
;
; PURPOSE           : Standardizing and Cleaning Full Disk Solar Image
;
; EXPLANATION       : Code developed to put the Halpha and Ca K lines full disk images taken at the Meudon Observatory
;                     into a standardised form of a ’virtual solar image’. The procudeure include limb fitting,
;                     removal of geometrical distortion, centre position and size standardisation and intensity normalisation
;
; CATEGORY          : EGSO_WP5 image cleanning
;
; CALLING SEQUENCE  : result = egso_cleanImage(im, result  [delta=delta, subtract=subtract, percent=percent])
;
;
; INPUT             : image     The full disk solar image
;
; OUTPUT            : result   Standardize cleaned images with the following specefactions:
;                     Size: 1024 by 1024
;                     Sun disk circular of radiuse 420
;                     Centred at 511.5, 511.5 pixel coordinates
;
; KEYWORDS          : delta
;                      subtract if set, the code uses subtraction to remove limb darkening instead of division
;                      percent  defualt = 0.5
;
; PROCEDURE         :
;
; CALLS             : egso_limb_efit, egso_standardize, egso_qsmedian, egso_getcontrastimage
;                     To clean a full disk image the following list of actions can be performed:
;                          - Fit an ellipse to the full disk image, using the limb_efit.pro
;                          - Correct irregularly shaped disk to a circle and resize the image, using  frclean_standardize.pro
;                          - Evaluate Quiet Sun using qsmedian.pro and consequently,
;                          remove Quiet Sun contribution from the image using getcontrastimage.pro.
;
; EXAMPLE           :
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003   added percent keyword
;
;====================================================================================================================================


pro egso_cleanimage, im, result,  delta=delta, subtract=subtract, percent=percent, lineclean=lineclean, flatten=flatten;, prominences=prominences

if not keyword_set(delta) then delta=0.0 else delta=fix(delta)


; fit ellipse to the input image (im), results of the fits are xc, yc, R1, R2, theta - others are optional (see the code)
egso_limb_efit, im, xc, yc, R1, R2, theta, percent=percent, /verbose

; standardize the image to 1024 by 1024, making Sun disk circular of radiuse 420, centred at 511.5, 511.5 pixel coordinates
imst = egso_standardize(im, xc, yc, R1, R2, theta, 1024, 1024, 420.+delta, 511.5, 511.5)

; generate the quiet sun image based on standardized image
Qsim = egso_qsmedian(imst, 420, 511.5, 511.5)

; clean the image by taking into account the quiet sun
;   either by division or subtraction

if keyword_set(subtract) then result=egso_getcontrastimage(imst, qsim, 420., 511.5, 511.5, /subtract) else $
       result = egso_getcontrastimage(imst, qsim, 420., 511.5, 511.5, Inorm=1000)  ;OR result = egso_getcontrastimage(imst, qsim, 420., 512, 512.)

; flattening and/or line cleaning
if keyword_set(flatten)                                then result = efr_flatten(result,840)
if keyword_set(lineclean) and keyword_set(flatten)     then result = efr_line_remove(result,840,/flatok)
if keyword_set(lineclean) and not keyword_set(flatten) then result = efr_line_remove(result,840,/noflatres)


window, 0, xs=1024, ys=1024
tvscl, result

end

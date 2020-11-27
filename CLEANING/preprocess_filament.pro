pro preprocess_filament,filename,stype,wpath,out_filename=final_filename

delta=1.

IF stype EQ 2 THEN BEGIN
   R=840.
   N=2048
ENDIF ELSE IF stype EQ 1 THEN BEGIN
   R=420.
   N=1024
ENDIF ELSE BEGIN
   PRINT,'Size not correct'
   RETALL
ENDELSE


image1x=N
image1y=N
cx=(N-1)/2.
cy=(N-1)/2.


im = READFITS(filename,header)
PRINT,filename
info=size(im)


;########cas des fichiers meudon a plusieurs dim
;########NB: l'utilisation du keyword nslice de readfits necessite de connaitre
;########la taille tu tableau a l'avance

nbarr=info[0]
IF nbarr GT 2 THEN BEGIN
	dim  = info[3]
	dimi = dim - FIX(dim/2.) - 1
	im   = im[*,*,dimi]
ENDIF
info = SIZE(im)
ny=info[2]
nx=info[1]

;#######display##################
;if keyword_set(display) then begin
;	sizi = FIX((FLOAT(info[1])/FLOAT(info[2]))*512+1)
;	WINDOW,/FREE,xs=(512+sizi),ys=512
;	wnum=!d.window
;	TVSCL,CONGRID(im,sizi,512)
;	splitab = STRSPLIT(filename,'/',/EXTRACT,COUNT=nsubstr)
;	XYOUTS,10,10,STRTRIM(splitab[nsubstr-1],2),/device,charsize=1.3
;endif
;#################################


; (egso_cleanimage)
; fit ellipse to the input image (im), results of the fits are xc, yc, R1,
; R2, theta - others are optional (see the code)
imtmp = im
egso_limb_efit,imtmp,xc,yc,R1,R2,theta,percent=0.15,/verbose,stdev,stdevGeo
imtmp = 0

;unsigned type image from Meudon Solar Tower
IF info[3] EQ 12 THEN BEGIN
	im = FIX(im/2)
ENDIF

; standardize the image to 1024 by 1024, making Sun disk circular of
; radiuse 420, centred at 511.5, 511.5 pixel coordinates
imst = egso_standardize(im, xc, yc, R1, R2, theta, N, N, R+delta, cx, cy)

; generate the quiet sun image based on standardized image
Qsim = egso_qsmedian(imst, R, cx, cy)

; clean the image by taking into account the quiet sun
result_subtract=egso_getcontrastimage(imst, qsim, R, cx, cy, /subtract)

;#######display###################
;if keyword_set(display) then begin
;	WSET,wnum
;	TVSCL,rebin(result_subtract,512,512),sizi,0
;endif
;##################################


;####### write fits file
H1= HEADFITS(filename)
H_old=H1
len=strlen(filename)
kx=strpos( filename , '/', /reverse_search)
kx2=STRPOS( filename , '.fits')
IF kx2 EQ -1 THEN BEGIN
	kx2=STRPOS( filename , '.fts')
ENDIF
        
Xfname=strmid(filename, kx+1, kx2-(kx+1))

date_old = FXPAR(H_old,'DATE')           ;Finds the value of DATE
NAXIS_old = FXPAR(H_old,'NAXIS*')         ;Returns array dimensions as vector
SOLAR_R_old = FXPAR(H_old,'SOLAR_R')
CENTER_X_old = FXPAR(H_old,'CENTER_X')
CENTER_Y_old = FXPAR(H_old,'CENTER_Y')
CRPIX1_old = FXPAR(H_old,'CRPIX1')
CRPIX2_old = FXPAR(H_old,'CRPIX2')

XSCALE_old = FXPAR(H_old,'XSCALE')
YSCALE_old = FXPAR(H_old,'YSCALE')

CDELT1_old = FXPAR(H_old,'CDELT1')
CDELT2_old = FXPAR(H_old,'CDELT2')

cdelt1=cdelt1_old*solar_r_old/R
cdelt2=cdelt2_old*solar_r_old/R

xscale=xscale_old*solar_r_old/R
yscale=yscale_old*solar_r_old/R

SXADDPAR, H1, 'CLEANED', 'YES'
SXADDPAR, H1, 'NAXIS1', image1x,'/Number of positions along axis 1'
SXADDPAR, H1, 'NAXIS2', image1y,'/Number of positions along axis 2'
date= SYSTIME()
SXADDPAR, H1, 'DATE', date
SXADDPAR, H1, 'SOLAR_R', R, '/ Solar radius in pixels'
SXADDPAR, H1, 'CENTER_X', cx, '/ Solar center in x direction (pixels)'
SXADDPAR, H1, 'CENTER_Y', cy, '/ Solar center in y direction (pixels)'
SXADDPAR, H1, 'CRPIX1', cx, '/ Solar center in x direction (pixels)'
SXADDPAR, H1, 'CRPIX2', cy, '/ Solar center in y direction (pixels)'
SXADDPAR, H1, 'XSCALE', xscale, '/ Scale along X_axis in arc sec/pixel'
SXADDPAR, H1, 'YSCALE', yscale, '/ Scale along Y_axis in arc sec/pixel'
SXADDPAR, H1, 'CDELT1', cdelt1, '/ Scale along X_axis in arc sec/pixel'
SXADDPAR, H1, 'CDELT2', cdelt2, '/ Scale along Y_axis in arc sec/pixel'
hist1 = strarr(13)
hist1[0] = '/The Old Header Parameter before Cleaning'
hist1[1] = 'DATE:/' +string(date_old)
hist1[2] = 'Number of positions along axis 1:/' +string(NAXIS_old[0])
hist1[3] = 'Number of positions along axis 2:/' +string(NAXIS_old[1])
hist1[4] = 'Solar radius in pixels:/' +string(SOLAR_R_old)
hist1[5] = 'Solar center in x direction (pixels):/' +string(CENTER_X_old)
hist1[6] = 'Solar center in y direction (pixels):/' +string(CENTER_Y_old)
hist1[7] = 'Solar center in x direction (pixels):/' +string(CRPIX1_old)
hist1[8] = 'Solar center in y direction (pixels):/' +string(CRPIX2_old)
hist1[9] = 'Scale along X_axis in arc sec/pixel:/' +string(XSCALE_old)
hist1[10] = 'Scale along Y_axis in arc sec/pixel:/' +string(YSCALE_old)
hist1[11] = 'Scale along X_axis in arc sec/pixel:/' +string(CDELT1_old)
hist1[12] = 'Scale along Y_axis in arc sec/pixel:/' +string(CDELT2_old)
sxaddhist, hist1, H1

history=strarr(5)
history[0]='ELLIPSE FIT RESULTS:'
history[1]='Ellipse Center: ' + string(xc)+', '+string(ny-yc)
history[2]='Ellipse Angle: '+string(theta)
history[3]='Ellipse Axis: '+string(R1)+', '+string(R2)
history[4]='Ellipse Fit Deviation: '+string(stdevGeo)
sxaddhist, history, H1

print,'min value:', min(result_subtract)
print,'max value:',max(result_subtract)
print,'dim and type:',size(result_subtract)

WRITEFITS, wpath+'/'+Xfname+'_subtract_processed.fits', result_subtract, H1 ;, /APPEND]

final_filename = Xfname+'_subtract_processed.fits'

im=0

end

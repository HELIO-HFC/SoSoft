
;===========================================================================
;".r inicleansession" first for linkimage

;########Color Display
;DEVICE,DECOMPOSED=0
;LOADCT,1


;########constantes
path='/home/cnudde/data4/FITS/K3p/'
delta=0.1;0.5
R=420
N=1024
image1x=N
image1y=N
cx=(N-1)/2.
cy=(N-1)/2.

;########choix des fichiers a standardizer
filenames = DIALOG_PICKFILE(PATH=path, /multiple_files,GET_PATH=wpath)
IF filenames(0) EQ '' THEN RETALL
k = N_ELEMENTS(filenames)
wpath = wpath + 'PROCESSED/'
help, filenames

;########boucle sur les fichiers selectionnes
FOR i=0, k-1 DO BEGIN

        ;lecture fits
        im = READFITS(filenames[i],header)
        PRINT,filenames[i]
	info=size(im)


;########cas des fichiers meudon a plusieurs dim
;########NB: l'utilisation du keyword nslice de readfits necessite de connaitre
;########la taille tu tableau a l'avance (pas necessaire pour les
;fichiers protu ?)

        nbarr=info[0]
        IF nbarr GT 2 THEN BEGIN
           dim  = info[3]
           dimi = dim - FIX(dim/2.) - 1 
           im   = im[*,*,dimi]
        ENDIF
        info = SIZE(im)
        nx = info[1]
	ny = info[2]

;#######display
        loadct,0
        sizj = 1024
        sizi = FIX((FLOAT(info[1])/FLOAT(info[2]))*sizj+1)
        WINDOW,/free,xs=(sizi+sizi),ys=sizj,xpos=0,ypos=0
        wnum=!d.window
        TVSCL,CONGRID(im,sizi,sizj)


;######################################################
;## Try to compute automatically a threshold value
;## (part of egso_limb_efit code)

  HistImage=histogram(im)
  n=n_elements(HistImage)
  ; Generate a Smoothed Histogram
  Ni=n/128
  AveHistImage = SMOOTH(HistImage,2*Ni) ;(no edge_truncate)
  ; Get average intensity value around the centre of the image
  cenx=nx/2.
  ceny=ny/2.
  box_size=(nx < ny) /16
  average=MEAN(im[FIX(cenx+0.5-box_size):FIX(cenx+0.5+box_size),$
                  FIX(ceny+0.5-box_size):FIX(ceny+0.5+box_size)])
  ; Analyse Histogram to get the cutoff intensity around limb
  ind=fix(average+.5)
  value=AveHistImage[ind]
  percent= 0.1
  while ind gt 2 and (HistImage[ind-1] lt HistImage[ind] or HistImage[ind] gt percent*value) do ind=ind-1
  thr=ind*0.7

;######################################################          
  
  TVSCL,CONGRID(im GT thr,sizi,sizj),sizi,0

;########choix auto ou manuel######
  FLAGM = 0
  rep = DIALOG_MESSAGE('Fitting manuel?',/question,/cancel)
  IF rep EQ 'Yes' Then FLAGM = 1           
  IF rep EQ 'Cancel' THEN GOTO,endf


        ; (egso_cleanimage)
        ; fit ellipse to the input image (im), results of the fits are xc, yc, R1,
        ; R2, theta - others are optional (see the code)
        IF FLAGM EQ 0 THEN BEGIN
           egso_limb_efit2,im,thr,xc,yc,R1,R2,theta,/verbose,stdev,stdevGeo,/prom 
        ENDIF ELSE BEGIN
        ;########choix manuel par seuillage ou par pointage######
         FLAGM2 = 0
         rep = DIALOG_MESSAGE('Seuillage ? (sinon pointage)',/question,/cancel)
         IF rep EQ 'Yes' Then FLAGM2 = 1           
         IF rep EQ 'Cancel' THEN RETALL
         ;######################################################
         IF FLAGM2 EQ 0 THEN BEGIN
           pointage:
           res=wg_manual_ellipse_fit(im)
           xc = res[0]
           yc = res[1]
           R1 = res[2]
           R2 = res[3]
           theta = res[4]
           stdevGeo = res[5]
           stdev =res[6] 
         ENDIF ELSE BEGIN
           thr = wg_manual_threshold2(im)
           IF thr EQ -1 THEN BEGIN
              rep = DIALOG_MESSAGE('pointage ?',/question)
              IF rep EQ 'Yes' THEN GOTO, pointage ELSE RETALL
           ENDIF
           egso_limb_efit2,im,thr,xc,yc,R1,R2,theta,/verbose,stdev,stdevGeo,/prom 
         ENDELSE

        ENDELSE

        ; standardize the image to 1024 by 1024, making Sun disk circular of
        ; radiuse 420, centred at 511.5, 511.5 pixel coordinates
        imst = egso_standardize(im, xc, yc, R1, R2, theta, 1024, 1024, 420.+delta, cx, cy)


;#######display
loadct,0
WSET,wnum
imstm=imst
mask = EFR_ROUNDMASK(1024,1024,0,420)
imstm[mask]=0.
TVSCL,CONGRID(imstm,sizj,sizj),sizi,0
imstm=0

;####### write fits file
	H1= HEADFITS(filenames[i])
	H_old=H1
	len=strlen(filenames[i])
	kx=strpos( filenames[i] , '/', /reverse_search)
        kx2=STRPOS( filenames[i] , '.fits')
        IF kx2 EQ -1 THEN BEGIN
           kx2=STRPOS( filenames[i] , '.fts')
        ENDIF
;	kx=strpos( filenames[i] , '\', /reverse_search)
;	Xfname=strmid(filenames[i], kx+1, 28)
        Xfname=strmid(filenames[i], kx+1, kx2-(kx+1))

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

	cdelt1=cdelt1_old*solar_r_old/420.
	cdelt2=cdelt2_old*solar_r_old/420.

	xscale=xscale_old*solar_r_old/420.
	yscale=yscale_old*solar_r_old/420.

	SXADDPAR, H1, 'CLEANED', 'YES'
	SXADDPAR, H1, 'NAXIS1', image1x,'/Number of positions along axis 1'
	SXADDPAR, H1, 'NAXIS2', image1y,'/Number of positions along axis 2'
	date= SYSTIME()
	SXADDPAR, H1, 'DATE', date
	SXADDPAR, H1, 'SOLAR_R', R
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



	WRITEFITS, wpath+Xfname+'_processed.fits', imst, H1 ;, /APPEND]

endf:
endfor

end



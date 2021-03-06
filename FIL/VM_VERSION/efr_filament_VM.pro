
;+
; NAME:
;       efr_filament
;
; PURPOSE:
;
;       From standardized Ha solar images, (round and centered 
;       solar disk), this program automatically recognize filaments
;       (and eventually spots)
;
; AUTHOR:
;
;       Fuller Nicolas
;       LESIA / POLE SOLAIRE
;       Observatoire de MEUDON
;       5 place Jules Janssen
;       92190 MEUDON
;       E-mail: nicolas.fuller@obspm.fr
;
; PROJECT:
;
;       EGSO (European Grid of Solar Observations)
;
; CALLING SEQUENCE:
;
;        res = efr_filament(obskey,diam)
;
; INPUTS
;
;        obskey : string defining the image origin (meudon1,meudon2,bbso...)
;
;        diam : Sun diameter (pixels)
;
; OPTIONAL INPUT
; 
;        input : n x n array image
;
; OUTPUTS:
;
;       segmented image - n x n array (filaments pixels are set to 1
;                         and others to 0)  
;
; INPUT KEYWORDS:
;
;       Display :  display different stages of processing image
;
;       lineclean : dust line cleaning
; 
;       flatclean : flatening of the disk intensity
; 
;       dustclean : dust points removal
;
; OUTPUT KEYWORDS:
;
;       corrected : input corrected with line/flat/dustclean depending
;                   on the chosen keywords
;
; CALLING EXAMPLES
;
;       res = efr_filament('meudon1',840,/lin,/fla,/dus,/dis)
;       res = efr_filament('bbso',840,input=im,/fla,/dis)
;
; MODIFICATION HISTORY:
;
;  NF may 2004: add EFR_LIMBSYM (remove from efr_fil_seeds and
;               efr_fil_region_grow)
;     nov 2004: maind keyw
;-


;###########################################################################

FUNCTION EFR_FILAMENT_VM,obskey,diam,INPUT=input,CORRECTED=im_FLT,LINECLEAN=lineclean,FLATCLEAN=flatclean,DUSTCLEAN=dustclean,DISPLAY=display,MAIND=maind

;###########################################################################

  pathdata = ''
  pathprog = ''


  ;####FUNCTION PARAMETERS CHECK
   IF N_PARAMS() LT 2 THEN BEGIN
      PRINT,'EFR_FILAMENT calling example: res=EFR_FILAMENT(''bbso'',840,/display)'
      RETALL
   ENDIF

  ;####IDL RELEASE CHECK
  version = FLOAT(!VERSION.RELEASE)
  IF version LT 5.5 THEN BEGIN
    PRINT,'Use IDL5.5 or greater'
    RETALL
  ENDIF
 

  ;####GET THE ARRAY FROM THE FITS IF NO INPUT
  IF NOT KEYWORD_SET(INPUT) THEN BEGIN
    file = DIALOG_PICKFILE(PATH=pathdata,FILTER='*fits')
    IF file NE '' THEN BEGIN
      input = LONG(READFITS(file,head1))   
    ENDIF ELSE RETALL
  ENDIF


  ;#####IMAGE SIZE
  Xsiz = (SIZE(input))[1]
  Ysiz = (SIZE(input))[2]
  
  
  ;#####OPTIONAL DISPLAY
  IF KEYWORD_SET(display) THEN BEGIN
    dis_xs = display
    WINDOW,9,XSIZE=dis_xs,YSIZE=dis_xs
    TVSCL,REBIN(input,dis_xs,dis_xs)
  ENDIF


  ;#####GET SPECIFIC COEFFICIENTS FROM SAVE FILE
  ;RESTORE,pathprog + 'efr_obs_param.sav'
  ;wobs = WHERE(obs_param.obs EQ STRCOMPRESS(obskey,/REM),nmatch)
  ;IF nmatch EQ 0 THEN RETALL
  ;coefflapl   = obs_param[wobs].lapl
  ;coeffseeds  = obs_param[wobs].seeds
  ;coeffregion = obs_param[wobs].regiongrow

  ;DEFAULT  
   coefflapl   = 1.5
   coeffseeds  = 2.8
   coeffregion = 1.8
  
  ;## Meudon photographic plate Observations:
  IF obskey EQ 'meu2' THEN BEGIN
     coefflapl   = 1.0
     coeffseeds  = 2.4
     coeffregion = 1.8
  ENDIF
  
  ;## Meudon photographic plate Observations:
  IF obskey EQ 'meu1' THEN BEGIN
     coefflapl   = 1.0 
     coeffseeds  = 3.4
     coeffregion = 2.0  
  ENDIF
  
  ;## BBSO CCD Observations:
  IF obskey EQ 'bbso' THEN BEGIN
     coefflapl   = 2.0 
     coeffseeds  = 2.7
     coeffregion = 1.9  
  ENDIF
  
  ;## YNAO CCD Observations:
  IF obskey EQ 'ynao' THEN BEGIN
     coefflapl   = 2.0 
     coeffseeds  = 2.8
     coeffregion = 1.5  
  ENDIF
  ;## etc

;print,coefflapl
;print,coeffseeds
;print,coeffregion

 
  ;####OPTIONALY CLEAN THE IMAGE (INTENSITY/LINES/DUST)
   im_FLT = input
   IF KEYWORD_SET(lineclean) AND KEYWORD_SET(flatclean) THEN $
      im_FLT = EFR_LINE_REMOVE(input,diam,/dis,MAIND=maind) 
   IF KEYWORD_SET(flatclean) AND NOT KEYWORD_SET(lineclean) THEN $
      im_FLT = EFR_FLATTEN(input,diam)
   IF KEYWORD_SET(lineclean) AND NOT KEYWORD_SET(flatclean) THEN $
      im_FLT = EFR_LINE_REMOVE(input,diam,/noflatres,MAIND=maind)  
   IF KEYWORD_SET(dustclean) THEN im_FLT = EFR_DUST_CLEAN(im_FLT)


  ;####OPTIONAL DISPLAY
   IF KEYWORD_SET(display) THEN TVSCL,REBIN(im_FLT,dis_xs,dis_xs)


  ;####EXTEND THE DISK WITH LIMB SYMETRY TO AVOID BORDER EFFECTS
  im_FLT  = EFR_LIMBSYM(im_FLT,diam/2.-2,(Xsiz-diam)/2.,/inv)


  ;####SUBTRACT THE LAPLACIAN OF IMAGE TO SHARPEN THE EDGES
   IF coefflapl NE 0 THEN BEGIN

      im_LAPL = EFR_SHARPEN(LONG(im_FLT),coefflapl)
   
      ;####KEEP THE SAME INTENSITY RANGE AND DISCARD NEG. VALUES
      neg      = WHERE(im_LAPL LT 0.,nneg)
      IF nneg GT 0 THEN im_LAPL[neg] = 1./10E3
      im_LAPL = im_LAPL/coefflapl


      ;####MEDIAN FILTER TO REDUCE THE NUMBER OF SEEDS
      im_LAPL = MEDIAN(im_LAPL,3)  


      ;####OPTIONAL DISPLAY
      IF KEYWORD_SET(display) THEN TVSCL,REBIN(im_LAPL,dis_xs,dis_xs)

   ENDIF ELSE im_LAPL = im_FLT


  ;####FIND THE SEEDS
   im_SEED = EFR_FIL_SEEDS(im_LAPL,diam,coeffseeds)


  ;####OPTIONAL DISPLAY
   IF KEYWORD_SET(display) THEN TVSCL,REBIN(im_SEED,dis_xs,dis_xs)


  ;####REGION GROWING FUNCTION
   res = EFR_FIL_REGION_GROW(im_LAPL,im_SEED,diam,coeffregion)


  ;####ERASE DISK EXTENSION
   maskbck = EFR_ROUNDMASK(Xsiz,Ysiz,0.,diam/2.,COMP=mask_comp)
   im_FLT[mask_comp] = 0.


  ;####OPTIONAL DISPLAY
   IF KEYWORD_SET(display) THEN BEGIN
      tmpo = res*0b
      tmpo[maskbck]=1b
      tmpo[WHERE(res)]=2b
      TVSCL,REBIN(tmpo,dis_xs,dis_xs)
      tmpo=0
   ENDIF


  ;####OPTIONAL DISPLAY
   IF KEYWORD_SET(display) THEN BEGIN

     sub = WHERE(res)
     imi = im_FLT
     imi[sub] = 0.
     TVSCL,REBIN(imi,dis_xs,dis_xs)

   ENDIF

  ;####OPTIONAL DISPLAY
   IF KEYWORD_SET(display) THEN BEGIN

     ;WINDOW,/FREE,XS=1024,YS=512
     ;WINDOW,10,xsize=1024,ysize=512
     WDELETE,9
     hh = dis_xs/2.
     WINDOW,10,XS=dis_xs,YS=dis_xs
     imi = imi*0b
     imi[maskbck] = 1b
     imi[sub] = 2b
     TVSCL,REBIN(im_FLT,hh,hh)
     TV,BYTSCL(REBIN(imi,hh,hh),0,2),hh,0

   ENDIF


RETURN,res

END


;####################################################









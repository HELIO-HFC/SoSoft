;##########################################################
; MAIN PROGRAM FOR FILAMENT AUTOMATED RECOGNITION AND
; DESCRIPTION
;##########################################################

;+
; NAME:
;       efr_fil2ascii
;
; PURPOSE:
;
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
;       and HELIO (Heliophysics Integrated Observatory) HFC
;
; CALLING SEQUENCE:
;
;       .r efr_fil2ascii
;
; INPUTS:
;    
;         The standardized FITS observations to be computed
;         (DIALOG_PICKFILE)
;
; OUTPUTS:
;
;        Three ascii files for the contaning parameters for 
;        - the original observation ([obs]_fi_init.txt)
;        - the processed image ([obs]_fi_norm.txt)
;        - the detected filaments ([obs]_fi_feat.txt)
;
;        A  Jpeg file which summarize the processing steps and results
;
; MODIFICATION HISTORY:
;
;    NF 2004
;    NF 2010 small corrections for HELIO
;    NF 2010 big update of the structure parameters and output files
;    NF 2011/01 Display option, efr_remove_sunspot
;-
@efr_shape_lib
@Fit_Ellipse

;----------------------------------------------------------
;OPTIONAL DISPLAY 
;----------------------------------------------------------
;follow the different steps on screen

DISPLAY_res = 1

;----------------------------------------------------------
;JPEG OPTIONAL OUTPUT
;---------------------------------------------------------- 
;summarizes the steps in one jpeg for visual inspection

JPEG_output = 1

;----------------------------------------------------------
; CHOOSE THE FILES OR NOT (dialog_pickfile)
;----------------------------------------------------------
  
DIALOG = 1

;----------------------------------------------------------
; Set the year the observation(s) take place
;----------------------------------------------------------
;the year selection is optionnal. It's convenient
;for the directory tree we have in Meudon 

  oyear=''
  PRINT,'Enter the year of the observations you want to compute,'
  PRINT,'for example: 2001'
  READ,oyear
  IF SIZE(FIX(oyear),/TYPE) NE 2 OR oyear LT 1900 OR oyear GT 2100 THEN BEGIN
    PRINT,'year: wrong type'
    RETALL
  ENDIF
  oyear = STRTRIM(oyear,2)

;-----------------------------------------------------------
; ppath: where to look for fits files
; opath: path to the original file (before preprocessing, will be
; written in the ascii file)
; apath: path to the directory where the ascii files will be written
; jpath: path to the directory where jpeg files will be written
; lpath: local path to the processed file (with the filename, 
;used as an identifier between HFC tables)
;------------------------------------------------------------
  ppath = '/home/fuller/data2/FITS/Ha/'+oyear+'/PROCESSED/'
  opath = '/home/fuller/data2/FITS/'    
  apath = '/home/fuller/poub/SAV/FIL/DAILY_ASCII/'
  spath = '/home/fuller/poub/SAV/FIL/STRUCT/'
  cpath = '/home/fuller/poub/SAV/FIL/CDF/'
  jpath = '/home/fuller/poub/SAV/FIL/TMPJPG/'
  lpath = '/Ha/'+oyear+'/PROCESSED/'

;----------------------------------------------------------
; Not use DIALOG_PICKFILE below but 'ls' instead
; to compute all the files in the directory
;----------------------------------------------------------

IF DIALOG EQ 0 THEN BEGIN

  command = 'ls '+ppath+'*processed*'
  SPAWN,command,filenames
  IF filenames[0] EQ '' THEN RETALL
  nbj = N_ELEMENTS(filenames)
  PRINT, STRTRIM(nbj,2)+" files found in "+STRTRIM(ppath,2)

ENDIF ELSE BEGIN
;-----------------------------------------------------------
; Get the processed files names to compute and number of
; selected files
;-----------------------------------------------------------

  filenames = DIALOG_PICKFILE(PATH=ppath, /multiple_files) 
  IF filenames[0] EQ '' THEN RETALL
  nbj = N_ELEMENTS(filenames)

ENDELSE
;----------------------------------------------------------
; Other parameters
;----------------------------------------------------------

    ;-------------------------------------------------------
    ; Cleaning Code Information
    ;-------------------------------------------------------
    INSTITUT         = 'Observatoire de Paris Meudon' ;Institute responsible for running the cleaning code
    CODE              = 'ANA' ;Name of the cleaning code
    VERSION         = '1.0' ;Version of the cleaning code
    CONTACT       = 'NICOLAS FULLER' ;Person responsible for running cleaning code
    ;-------------------------------------------------------
    ; Feature Recognition Code Information
    ;-------------------------------------------------------
    FRC_INSTITUT              = 'Observatoire de Paris-Meudon' ;Institute responsible for running the FR code
    FRC_CODE                   = 'EFR_FIL2ASCII' ;Name of the code
    FRC_VERSION              = '1.0' ;Version of the code
    FRC_CONTACT             = 'NICOLAS FULLER' ;Person responsible for running the code
    FRC_FEATURE_NAME  = 'FILAMENT' ;

;----------------------------------------------------------
; display issues
;----------------------------------------------------------
 DEVICE,DECOMPOSED=0,RETAIN=2

;If display = 0 and jpeg_output = 1, use pixmap method
;(pixmap is used to create a jpeg output without displaying the window)
PIXMAP_method = 0
IF DISPLAY_res NE 1 AND JPEG_output EQ 1 THEN PIXMAP_method = 1 


;----------------------------------------------------------
; Define the structures to store parameters from
; header and computed ones.
;----------------------------------------------------------

  default = '\N'

  STRUCT_OBS = {OBSERVATIONALPARAMETERS, $
                IND:               default, $
                OBSERVAT:          default, $
                INSTRUME:          default, $
                TELESCOP:          default, $
                UNITS:             default, $
                WAVELNTH:          default, $
                WAVENAME:          default, $
                WAVEUNIT:          default, $
                OBS_TYPE:          default, $
                DATE_OBS:          default, $
                DATE_END:          default, $
                JDINT:             default, $
                JDFRAC:            default, $
                EXPTIME:           default, $
                CARROT:            default, $
                BSCALE:            default, $
                BZERO:             default, $
                BITPIX:            default, $
                NAXIS1:            default, $
                NAXIS2:            default, $
                R_SUN:             default, $
                CENTER_X:          default, $
                CENTER_Y:          default, $
                CDELT1:            default, $
                CDELT2:            default, $ 
                QUALITY:           default, $
                FILENAME:          default, $
                COMMENT:           default, $
                IMAGE_COVER:       default, $
                IMAGE_COMP:        default, $
                DATE_OBS_STRING:   default, $
                DATE_END_STRING:   default, $
                LOCAL_FILENAME:    default, $
                EOF:              '-999.999'}

		
  STRUCT_PRO = {PROCESSINGPARAMETERS, $
                IND:               default, $
                RUN_DATE:          default, $
                LOC_FILE:          default, $
                EL_CEN_X:          default, $
                EL_CEN_Y:          default, $
                EL_AXIS1:          default, $
                EL_AXIS2:          default, $
                EL_ANGLE:          default, $
                STDEV:             default, $
                STDEVGEO:          default, $
                ALGERR:            default, $                
                CDELT1:            default, $
                CDELT2:            default, $
                BITPIX:            default, $
                QSUNINT:           default, $
                LOCAL_FILENAME:    default, $
                PP_LOCAL_FILENAME: default, $
                INSTITUT:          default, $
                CODE:              default, $ 
                VERSION:           default, $
                CONTACT:           default, $
                EFIT:              default, $
                STANDARD:          default, $
                LIMBDARK:          default, $
                BACKGROUND:        default, $
                LINECLEAN:         default, $
                LINEC_MAIND:       default, $
                QSUN_INT:          default, $
                PERCENT:           default, $
                NAXIS1:            default, $
                NAXIS2:            default, $
                CENTER_X:          default, $
                CENTER_Y:          default, $
                R_SUN:             default, $
                DIVISION:          default, $
                INORM:             default, $
                EOF:              '-999.999'}

  STRUCT_FIL = {FEATUREPARAMETERS, $
                IND:               default, $
                RUN_DATE:          default, $
                GRAV_C_ARCX:       default, $
                GRAV_C_ARCY:       default, $
                GRAV_C_CAR_LAT:    default, $
                GRAV_C_CAR_LON:    default, $
                SAMPLECOUNT:       default, $
                AREA:              default, $ 
                MEAN_INT_RATIO:    default, $
                BRARC_X_LL:        default, $
                BRARC_Y_LL:        default, $
                BRARC_X_UR:        default, $
                BRARC_Y_UR:        default, $
                BRPIX_X_LL:        default, $
                BRPIX_Y_LL:        default, $
                BRPIX_X_UR:        default, $
                BRPIX_Y_UR:        default, $
                FEAT_MAX_INT:      default, $
                FEAT_MIN_INT:      default, $
                FEAT_MEAN_INT:     default, $
                ENC_MET:           default, $
                COD_PIX_X:         default, $
                COD_PIX_Y:         default, $
                COD_ARC_X:         default, $
                COD_ARC_Y:         default, $
                SKE_LEN_DEG:       default, $
                THICKNESS_PIX:     default, $
                CURVATURE:         default, $
                ELONG:             default, $
                ORIENTATION:       default, $
                COD_SKE_PIX_X:     default, $
                COD_SKE_PIX_Y:     default, $
                COD_SKE_ARC_X:     default, $
                COD_SKE_ARC_Y:     default, $
                CHAIN_CODE:        default, $
                CCODE_LNTH:        default, $
                CHAIN_CODE_SKE:    default, $
                CCODE_SKE_LNTH:    default, $
                ;RASTER_SCAN_LNTH:  default, $
                PP_LOCAL_FILENAME: default, $
		FRC_INSTITUT:      default, $
		FRC_CODE:          default, $
		FRC_VERSION:       default, $
		FRC_FEATURE_NAME:  default, $
		FRC_CONTACT:       default, $
                EOR:             '999.999', $
                EOF:              '-999.999'}


;-----------------------------------------------------------
; Main loop on every file
;-----------------------------------------------------------

  FOR ii = 0, nbj-1 DO BEGIN


    ;-------------------------------------------------------
    ; Create instances of the structures for this file
    ;-------------------------------------------------------

    strobs = STRUCT_OBS
    strpro = STRUCT_PRO
    strfil = STRUCT_FIL

    ;-------------------------------------------------------
    ; Cleaning Code Information
    ;-------------------------------------------------------

    strpro.INSTITUT = INSTITUT
    strpro.CODE = CODE
    strpro.VERSION = VERSION
    strpro.CONTACT = CONTACT
    
    ;-------------------------------------------------------
    ; Read the processed fits file (image and header)
    ;-------------------------------------------------------

     gfile = filenames[ii]
     PRINT,gfile
     arr = READFITS(gfile,headp)

    ;-------------------------------------------------------
    ; Get the name of original file from processed one
    ;-------------------------------------------------------

     splitf  = STRSPLIT(gfile,'/',/EXTRACT)
     pfile   = splitf[N_ELEMENTS(splitf)-1]
     splitf2 = STRSPLIT(pfile,'_subtract_processed',/EXTRACT,/REGEX)
     originalfname = opath + splitf2[0] + '.fits'


    ;-------------------------------------------------------
    ; Local filename including local path (-> link between
    ; tables in the database)
    ;-------------------------------------------------------

     locfile = lpath + pfile

     
    ;-------------------------------------------------------
    ; Get Solar parameters from the HISTORY of header
    ;-------------------------------------------------------
     ;(field name in history part = comment in first part of header)

     hist = FXPAR(headp,'HISTORY' ,COUNT=cch)
     histb= hist
     com  = STRARR(7)
     vals = STRARR(7)
     h01  = FXPAR(headp,'NAXIS1'  ,COUNT=cc01, COMM = com0)
     h02  = FXPAR(headp,'NAXIS2'  ,COUNT=cc02, COMM = com1)
     h03  = FXPAR(headp,'CDELT1'  ,COUNT=cc03, COMM = com2)
     h04  = FXPAR(headp,'CDELT2'  ,COUNT=cc04, COMM = com3)
     h05  = FXPAR(headp,'CENTER_X',COUNT=cc05, COMM = com4)
     h06  = FXPAR(headp,'CENTER_Y',COUNT=cc06, COMM = com5)
     h07  = FXPAR(headp,'SOLAR_R' ,COUNT=cc07, COMM = com6) 
     com[0] = com0
     com[1] = com1
     com[2] = com2
     com[3] = com3
     com[4] = com4
     com[5] = com5
     com[6] = com6
     FOR aa = 0,cch-1 DO hist[aa]  = STRJOIN(STRSPLIT(hist[aa],'/:',/EXTRACT))
     FOR bb = 0,6 DO BEGIN
           IF STRLEN(com[bb]) GT 4 THEN BEGIN
            comm  = '*'+STRTRIM(STRJOIN(STRSPLIT(com[bb],'/:',/EXTRACT)),2)+'*'   
            wwma  = (WHERE(STRMATCH(hist,comm,/FOLD_CASE) EQ 1))[0]
            splt  = STRSPLIT(histb[wwma],/EXTRACT,COUNT=nsplt)
            vals[bb] = splt[nsplt-1]
           ENDIF
     ENDFOR 


    ;-------------------------------------------------------
    ; Get Ellipse parameters from the HISTORY of header
    ;-------------------------------------------------------

      str = '*Ellipse Center*'
      wwma  = (WHERE(STRMATCH(histb,str,/FOLD_CASE) EQ 1))[0]
      splt  = STRSPLIT(histb[wwma],/EXTRACT,COUNT=nsplt)
      val109 = STRSPLIT(splt[nsplt-2],',',/EXTR)
      val110 = STRSPLIT(splt[nsplt-1],',',/EXTR)

      str = '*Ellipse Angle*'
      wwma  = (WHERE(STRMATCH(histb,str,/FOLD_CASE) EQ 1))[0]
      splt  = STRSPLIT(histb[wwma],/EXTRACT,COUNT=nsplt)
      val111 = STRSPLIT(splt[nsplt-1],',',/EXTR)

      str = '*Ellipse Axis*'
      wwma  = (WHERE(STRMATCH(histb,str,/FOLD_CASE) EQ 1))[0]
      splt  = STRSPLIT(histb[wwma],/EXTRACT,COUNT=nsplt)
      val112 = STRSPLIT(splt[nsplt-2],',',/EXTR)
      val113 = STRSPLIT(splt[nsplt-1],',',/EXTR)

      str = '*Ellipse Fit Deviation*'
      wwma  = (WHERE(STRMATCH(histb,str,/FOLD_CASE) EQ 1))[0]
      splt  = STRSPLIT(histb[wwma],/EXTRACT,COUNT=nsplt)
      val114 = STRSPLIT(splt[nsplt-1],',',/EXTR)


    ;-------------------------------------------------------
    ; Get parameters from the header of the processed file
    ;-------------------------------------------------------

     val101 = FXPAR(headp,'NAXIS1'      ,COUNT=count101)
     val102 = FXPAR(headp,'NAXIS2'      ,COUNT=count102)
     val103 = FXPAR(headp,'CDELT1'      ,COUNT=count103)
     val104 = FXPAR(headp,'CDELT2'      ,COUNT=count104)
     val105 = FXPAR(headp,'CENTER_X'    ,COUNT=count105)
     val106 = FXPAR(headp,'CENTER_Y'    ,COUNT=count106)
     val107 = FXPAR(headp,'SOLAR_R'     ,COUNT=count107)  
     val108 = FXPAR(headp,'DATE'        ,COUNT=count108)
     val08  = FXPAR(headp,'INSTITUT'     ,COUNT=count08)
     val09  = FXPAR(headp,'ORIGIN'       ,COUNT=count09)
     val10  = FXPAR(headp,'INSTRUME'     ,COUNT=count10)
     val11  = FXPAR(headp,'TELESCOP'     ,COUNT=count11)
     val12  = FXPAR(headp,'WAVELNTH'     ,COUNT=count12)
     val13  = FXPAR(headp,'WAVELNTH_NAME',COUNT=count13)
     val13b = FXPAR(headp,'WAVEUNIT'     ,COUNT=count13b)
     val14  = FXPAR(headp,'OBS_TYPE'     ,COUNT=count14)
     val15  = FXPAR(headp,'DATE_OBS'     ,COUNT=count15)
     val16  = FXPAR(headp,'DATE_END'     ,COUNT=count16)
     val17  = FXPAR(headp,'BSCALE'       ,COUNT=count17)
     val18  = FXPAR(headp,'BZERO'        ,COUNT=count18)
     val19  = FXPAR(headp,'EXPTIME'      ,COUNT=count19)
     val20  = FXPAR(headp,'SOLROT_N'     ,COUNT=count20)
     val21  = FXPAR(headp,'BITPIX'       ,COUNT=count21)
     val22  = FXPAR(headp,'FILENAME'     ,COUNT=count22)
     val23  = FXPAR(headp,'UNITS'        ,COUNT=count23)
     val24  = FXPAR(headp,'QUALITY'      ,COUNT=count24)
     val27  = FXPAR(headp,'COMMENT'      ,COUNT=count27)
     val28  = FXPAR(headp,'DATE-OBS'     ,COUNT=count28)
     val29  = FXPAR(headp,'TIME-OBS'     ,COUNT=count29)
     val30  = FXPAR(headp,'TIME_OBS'     ,COUNT=count30)


    ;-------------------------------------------------------
    ; Solve particular case of DATE_/-OBS and TIME_/-OBS
    ; If DATE-OBS='YYYY-MM-DD' and TIME-OBS='HH:MM:SS'
    ; Then DATE-OBS=DATE-OBS+T+TIME-OBS
    ;-------------------------------------------------------

     IF count15 EQ 0 THEN BEGIN
        IF count28 EQ 0 THEN BEGIN
          PRINT,'No observation date found, returning...'
          RETALL
        ENDIF ELSE BEGIN
          val15 = val28
          count15 = 1
        ENDELSE 
     ENDIF

     IF count30 NE 0 THEN BEGIN
        val30 = STRTRIM(val30,2)
        val15 = STRTRIM(val15,2)
        IF STRLEN(val30) EQ 8 AND STRLEN(val15) EQ 10 THEN $
        val15 = val15+'T'+val30
     ENDIF

     IF count29 NE 0 THEN BEGIN
        val29 = STRTRIM(val29,2)
        val15 = STRTRIM(val15,2)
        IF STRLEN(val29) EQ 8 AND STRLEN(val15) EQ 10 THEN $
        val15 = val15+'T'+val29
     ENDIF


    ;-------------------------------------------------------
    ; Fill strobs structure with header parameters
    ;-------------------------------------------------------

     IF vals[0] NE ' ' THEN strobs.NAXIS1        = FIX(vals[0])
     IF vals[1] NE ' ' THEN strobs.NAXIS2        = FIX(vals[1])
     IF vals[2] NE ' ' THEN strobs.CDELT1        = DOUBLE(vals[2])
     IF vals[3] NE ' ' THEN strobs.CDELT2        = DOUBLE(vals[3])
     IF vals[4] NE ' ' THEN strobs.CENTER_X      = DOUBLE(vals[4])
     IF vals[5] NE ' ' THEN strobs.CENTER_Y      = DOUBLE(vals[5])
     IF vals[6] NE ' ' THEN strobs.R_SUN         = DOUBLE(vals[6])  
     IF count08 GE 1   THEN strobs.OBSERVAT      = STRING(val08)
     IF count09 GE 1   THEN strobs.OBSERVAT      = STRING(val09)
     IF count10 GE 1   THEN strobs.INSTRUME      = STRING(val10) ELSE $
     			    strobs.INSTRUME      = 'Spectroheliograph'
     IF count11 GE 1   THEN strobs.TELESCOP      = STRING(val11)
     IF count12 GE 1   THEN strobs.WAVELNTH      = STRING(val12) ELSE $ 
     			    strobs.WAVELNTH      = '6562.8'
     IF count13 GE 1   THEN strobs.WAVENAME      = STRING(val13) ELSE $
                            strobs.WAVENAME      = 'HALPHA'
     IF count13b GE 1  THEN strobs.WAVEUNIT      = STRING(val13b)
     IF count14 GE 1   THEN strobs.OBS_TYPE      = STRING(val14) ELSE $
                            strobs.OBS_TYPE      = 'Optical'		    
     IF count15 GE 1   THEN strobs.DATE_OBS      = STRING(val15)
     IF count16 GE 1   THEN strobs.DATE_END      = STRING(val16)
     IF count17 GE 1   THEN strobs.BSCALE        = STRING(val17)
     IF count18 GE 1   THEN strobs.BZERO         = STRING(val18)
     IF count19 GE 1   THEN strobs.EXPTIME       = STRING(val19)
     IF count20 GE 1   THEN strobs.CARROT        = FIX(val20)
     IF count21 GE 1   THEN strobs.BITPIX        = FIX(val21)
     IF count22 GE 1   THEN strobs.FILENAME      = STRING(val22)
     IF count23 GE 1   THEN strobs.UNITS         = STRING(val23) ELSE $
                            strobs.UNITS         = 'COUNTS'
     IF count24 GE 1   THEN strobs.QUALITY       = STRING(val24)
     IF count27 EQ 1   THEN strobs.COMMENT       = STRING(val27)
     IF count27 GT 1   THEN strobs.COMMENT       = STRJOIN(val27,';')

    ;-------------------------------------------------------
    ; Fill strpro structure with header parameters
    ;-------------------------------------------------------

     IF count101 GE 1 THEN strpro.NAXIS1        = FIX(val101)
     IF count102 GE 1 THEN strpro.NAXIS2        = FIX(val102)
     IF count103 GE 1 THEN strpro.CDELT1        = DOUBLE(val103)
     IF count104 GE 1 THEN strpro.CDELT2        = DOUBLE(val104)
     IF count105 GE 1 THEN strpro.CENTER_X      = DOUBLE(val105)
     IF count106 GE 1 THEN strpro.CENTER_Y      = DOUBLE(val106)
     IF count107 GE 1 THEN strpro.R_SUN         = DOUBLE(val107)  
     IF val109 NE ' ' THEN strpro.EL_CEN_X      = FLOAT(val109)
     IF val110 NE ' ' THEN strpro.EL_CEN_Y      = FLOAT(val110)
     IF val111 NE ' ' THEN strpro.EL_ANGLE      = FLOAT(val111)
     IF val112 NE ' ' THEN strpro.EL_AXIS1      = FLOAT(val112)
     IF val113 NE ' ' THEN strpro.EL_AXIS2      = FLOAT(val113)
     IF val114 NE ' ' THEN strpro.STDEVGEO      = FLOAT(val114)
     IF count21 GE 1  THEN strpro.BITPIX        = FIX(val21) ; !! here we put the same value for the processed and original file
     strpro.STANDARD = 1 ; The default is to consider standardization has been applied
     strpro.LIMBDARK = 1 ; The default is to consider limb darkening has been removed
     strpro.EFIT  = 1 ; the default is to consider ellipse fitting has been used
     strpro.PERCENT = 0.5 ; default value (see feature parameters doc)
     strpro.DIVISION = 0 ; method used to normalise image (1: division, 0: subtraction)
     strpro.INORM = '\N' ; normalizing factor for division method
     
    ;-------------------------------------------------------
    ; Get observation time from date_obs -> julian day
    ;-------------------------------------------------------

     date    = STRTRIM(strobs.DATE_OBS,2) 
     year    = FIX(STRMID(date,0,4))
     month   = FIX(STRMID(date,5,2))                                    
     day     = FIX(STRMID(date,8,2))
     hour    = FIX(STRMID(date,11,2))
     min     = FIX(STRMID(date,14,2))
     sec     = FIX(STRMID(date,17,2))
     jdfloat = JULDAY(month,day,year,hour,min,sec)
     jdint   = LONG(jdfloat)
     jdfrac  = jdfloat - jdint   


    ;--------------------------------------------------------
    ; Other parameters for strobs
    ;--------------------------------------------------------

    strobs.DATE_OBS_STRING = strobs.DATE_OBS
    strobs.DATE_END_STRING = strobs.DATE_END
    strobs.LOCAL_FILENAME  = STRING(originalfname)
    strobs.JDINT           = jdint
    strobs.JDFRAC          = jdfrac


    ;--------------------------------------------------------
    ; Check cdelt and carrot values, if null then compute
    ; them with GET_SUN function
    ;-------------------------------------------------------- 

     IF FIX(strpro.CDELT1) EQ 0 OR FIX(strpro.CDELT2) EQ 0 OR $
             strobs.CARROT EQ default THEN BEGIN
        PRINT,'no cdelt or carrot info in processed fits header!!'
        PRINT,'-> using GET_SUN function'
        tmp = GET_SUN(STRTRIM(strobs.DATE_OBS,2),SD=sd,CARR=carr)
        IF FIX(strpro.CDELT1) EQ 0 OR FIX(strpro.CDELT2) EQ 0 THEN BEGIN
          strpro.CDELT1 = sd/FLOAT(strpro.R_SUN) ;420.
          strpro.CDELT2 = strpro.CDELT1 ;(std. Sun is round)
        ENDIF
        IF strobs.CARROT EQ default THEN BEGIN
          strobs.CARROT = FIX(carr)
        ENDIF
     ENDIF


    ;-------------------------------------------------------
    ; Get runtime info from systime
    ;-------------------------------------------------------

     CALDAT,SYSTIME(/JULIAN,/UTC),mm,dd,yy,hh,mi,ss
     ss = FIX(ss)
     IF mm LT 10 THEN mm='0'+STRTRIM(mm,2) ELSE mm=STRTRIM(mm,2)
     IF dd LT 10 THEN dd='0'+STRTRIM(dd,2) ELSE dd=STRTRIM(dd,2)
     IF hh LT 10 THEN hh='0'+STRTRIM(hh,2) ELSE hh=STRTRIM(hh,2)
     IF mi LT 10 THEN mi='0'+STRTRIM(mi,2) ELSE mi=STRTRIM(mi,2)
     IF ss LT 10 THEN ss='0'+STRTRIM(ss,2) ELSE ss=STRTRIM(ss,2)
     yy = STRTRIM(yy,2)    
     today_utc = yy+'-'+mm+'-'+dd+'T'+hh+':'+mi+':'+ss


    ;--------------------------------------------------------
    ; Get preprocess runtime with 'date' headp keyword
    ;--------------------------------------------------------

     IF count108 GE 1 THEN BEGIN
       PPRD = BIN_DATE(val108) 
       IF PPRD[1] LT 10 THEN mm='0'+STRTRIM(PPRD[1],2) ELSE mm=STRTRIM(PPRD[1],2)
       IF PPRD[2] LT 10 THEN dd='0'+STRTRIM(PPRD[2],2) ELSE dd=STRTRIM(PPRD[2],2)
       IF PPRD[3] LT 10 THEN hh='0'+STRTRIM(PPRD[3],2) ELSE hh=STRTRIM(PPRD[3],2)
       IF PPRD[4] LT 10 THEN mi='0'+STRTRIM(PPRD[4],2) ELSE mi=STRTRIM(PPRD[4],2)
       IF PPRD[5] LT 10 THEN ss='0'+STRTRIM(PPRD[5],2) ELSE ss=STRTRIM(PPRD[5],2)
       yy = STRTRIM(PPRD[0],2)    
       PPRD = yy+'-'+mm+'-'+dd+' '+hh+':'+mi+':'+ss
     ENDIF ELSE PPRD = default


    ;--------------------------------------------------------
    ; Other parameters for strpro
    ;-------------------------------------------------------- 

     strpro.RUN_DATE          = PPRD
     strpro.LOC_FILE          = locfile ;or gfile to have the whole path
     strpro.LOCAL_FILENAME    = STRING(originalfname)
     strpro.PP_LOCAL_FILENAME = gfile
     ;strpro.QSUN_INT : calculation after cleaning


    
     ;--------------------------------------------------------
     ; From the header param, try to determine the type/origin
     ; of image
     ;-------------------------------------------------------- 

     info1 = STRUPCASE(STRTRIM(strobs.OBSERVAT,2))
     info2 = STRTRIM(strobs.NAXIS1,2)

     obst = ' '
     IF STRPOS(info1,'BBSO') NE -1 THEN obst = 'bbso'
     IF STRPOS(info1,'MEUDON') NE -1 OR STRPOS(info1,'PARIS') NE -1 AND $
        FIX(info2) GE 1500 THEN obst = 'meu2'
     IF STRPOS(info1,'MEUDON') NE -1 OR STRPOS(info1,'PARIS') NE -1 AND $
        FIX(info2) LT 1500 THEN obst = 'meu1'
     IF STRPOS(info1,'YUNNAN') NE -1 THEN obst = 'ynao'     
     IF obst EQ ' ' THEN BEGIN
        PRINT,'Can not find from which Obs. the image comes from, Returning'
        RETALL
     ENDIF

    ;--------------------------------------------------------
    ; Flatten/correct lines/correct dust/Find the filaments
    ;--------------------------------------------------------
      IF DISPLAY_res EQ 1 THEN BEGIN
             arrf = EFR_FILAMENT(obst,DOUBLE(2.*strpro.R_SUN), $
             INPUT=arr,CORRECTED=corrected,/lin,/fla,/dus,/dis,MAIND=maind)
      ENDIF ELSE BEGIN
             arrf = EFR_FILAMENT(obst,DOUBLE(2.*strpro.R_SUN), $
             INPUT=arr,CORRECTED=corrected,/lin,/fla,/dus,MAIND=maind)
      ENDELSE
      
    ;---------------------------------------------------------
    ; Nothing detected ? -> goto next one
    ;---------------------------------------------------------
    IF (WHERE(arrf))[0] EQ -1 THEN GOTO,endloop

    ;---------------------------------------------------------
    ; Some options above are written in strpro 
    ;---------------------------------------------------------
      strpro.LINECLEAN = 1
      strpro.BACKGROUND = 1
      strpro.LINEC_MAIND = STRTRIM(maind,2) 
 
     ;-------------------------------------------------------
      ;OPTIONAL DISPLAY
      ;-------------------------------------------------------
      IF DISPLAY_res EQ 1 OR PIXMAP_method EQ 1 THEN BEGIN
          hh = 512
          IF PIXMAP_method EQ 1 THEN WINDOW,10,XS=hh*2,YS=hh*2,/PIXMAP ELSE WINDOW,10,XS=hh*2,YS=hh*2
          imi = arr*0b
          maskbck = EFR_ROUNDMASK((SIZE(arr))[1],(SIZE(arr))[2],0.,strpro.R_SUN*1.,COMP=mask_comp)
          imi[maskbck] = 1b
          imi[WHERE(arrf)] = 2b
          TVSCL,REBIN(arr,hh,hh)
          TV,BYTSCL(REBIN(imi,hh,hh),0,2),hh,0
          XYOUTS,10,10,pfile,/DEVICE,COLOR=100
      ENDIF
      arr = 0 ;free memory
      imi = 0

    ;--------------------------------------------------------
    ; Compute the quiet sun intensity and fill STRPRO
    ;--------------------------------------------------------

     hist = MEDIAN(HISTOGRAM(corrected[WHERE(corrected)],min=0.,BIN=1),10)
     maxh = MAX(hist)
     wmax = (WHERE(hist EQ maxh))[0]
     ;strpro.QSUNINT = 1
     strpro.QSUN_INT = FLOAT(wmax)


    ;--------------------------------------------------------
    ; Link close blobs and fill holes with a closing operator
    ;--------------------------------------------------------
     rad = FIX(3*(strpro.NAXIS1/1024.))
     StrEl= SHIFT(DIST(2*rad+1),rad,rad) le rad
     im = MORPH_CLOSE(arrf,StrEl)
     
    ;-------------------------------------------------------- 
    ; Remove small isolated faint regions (possible to add a display keyword here)
    ;--------------------------------------------------------
     im = EFR_REMOVE_SFIR2(im,corrected);/dis)  

    ;---------------------------------------------------------
    ; Nothing left ? -> goto next one
    ;---------------------------------------------------------
    IF (WHERE(im))[0] EQ -1 THEN GOTO,endloop

    ;--------------------------------------------------------
    ; Remove potential sunspots (possible to add a display keyword here)
    ;--------------------------------------------------------
     tmp = im ;for display purpose
     im = EFR_REMOVE_SUNSPOT(im,corrected,DOUBLE(strpro.CDELT1),DOUBLE(strpro.CDELT2), $
             DOUBLE(strpro.CENTER_X),DOUBLE(strpro.CENTER_Y), $
             DOUBLE(strpro.R_SUN),STRTRIM(strobs.DATE_OBS,2),/dis)
     tmp = tmp - im

   ;--------------------------------------------------------
    ;OPTIONAL DISPLAY
    ;--------------------------------------------------------
    IF DISPLAY_res EQ 1 OR PIXMAP_method EQ 1 THEN BEGIN
       imi = corrected-im*0.5*strpro.QSUN_INT
       imi[mask_comp]=MIN(imi)
       ww= WHERE(tmp,ntache)
       IF ntache GT 0 THEN imi[ww] = MAX(imi)
       TVSCL,CONGRID(imi,hh,hh),hh,hh
       imi=0
    ENDIF
    tmp = 0

    ;--------------------------------------------------------
    ; Check if there is something in resulting image !
    ; damned, one more goto
    ;--------------------------------------------------------
     chk = WHERE(im,nchk)
     IF nchk EQ 0 THEN GOTO,endloop


    ;--------------------------------------------------------
    ; Filaments description: location intensity, geometry...
    ; fill STRFIL
    ;--------------------------------------------------------

    strfil = EFR_FIL_DESCRIBE(WHERE(im),WHERE(arrf),strfil,LONG(strpro.NAXIS1), $
             LONG(strpro.NAXIS2),DOUBLE(strpro.CDELT1),DOUBLE(strpro.CDELT2), $
             DOUBLE(strpro.CENTER_X),DOUBLE(strpro.CENTER_Y), $
             DOUBLE(strpro.R_SUN),STRTRIM(strobs.DATE_OBS,2), $
             DOUBLE(strpro.QSUN_INT),corrected,maind)

    ;--------------------------------------------------------
    ; Number of filaments
    ;--------------------------------------------------------

    numfil = N_ELEMENTS(strfil)


    ;----------------------------------------------------------
    ; Other parameters for STRFIL
    ;----------------------------------------------------------

    ;strfil[*].NUM_FEAT         = numfil
    strfil[*].RUN_DATE          = today_utc
    strfil[*].ENC_MET           = 'CHAIN CODE'
    strfil[*].PP_LOCAL_FILENAME = gfile
    
    ;-------------------------------------------------------
    ; Feature Recognition Code Information
    ;-------------------------------------------------------
    strfil[*].FRC_INSTITUT = FRC_INSTITUT
    strfil[*].FRC_CODE = FRC_CODE
    strfil[*].FRC_VERSION = FRC_VERSION
    strfil[*].FRC_CONTACT = FRC_CONTACT
    strfil[*].FRC_FEATURE_NAME = FRC_FEATURE_NAME
    
    ;----------------------------------------------------------
    ; Observation ID
    ;----------------------------------------------------------

    strobs.IND = ii+1 ;RANDOMN(seed,/LONG)
    strpro.IND = ii+1
    strfil[*].IND = ii+1

    ;-------------------------------------------------------
    ; Define filenames where to store the results
    ;-------------------------------------------------------  

     datef = STRMID(splitf2[0],12,/REV)
     resfile1 = spath + datef[0] + obst +'_fil.sav'
     resfile2 = apath + datef[0] + obst +'_fi_init.txt'
     resfile3 = apath + datef[0] + obst +'_fi_norm.txt'
     resfile4 = apath + datef[0] + obst +'_fi_feat.txt'
     resfile5 = apath + datef[0] + obst +'_fi_ccode.txt'
     resfile6 = cpath + datef[0] + obst +'_fi_image.cdf'
     resfile7 = jpath + datef[0] + obst +'_fi.jpg'

    ;----------------------------------------------------------
    ; Write and save ascii files
    ;----------------------------------------------------------


    ;######## FILE *fi_init.txt ########

    OPENW,un,resfile2,/GET_LUN

    PRINTF,un,STRTRIM(strobs.IND,2)+';'+$
           STRTRIM(strobs.OBSERVAT,2)+';'+$
           STRTRIM(strobs.INSTRUME,2)+';'+$
           STRTRIM(strobs.TELESCOP,2)+';'+$
           STRTRIM(strobs.WAVELNTH,2)+';'+$
           STRTRIM(strobs.WAVENAME,2)+';'+$
	   STRTRIM(strobs.WAVEUNIT,2)+';'+$
           STRTRIM(strobs.OBS_TYPE,2)+';'+$
           STRTRIM(strobs.UNITS,2)+';'+$
           STRTRIM(strobs.DATE_OBS,2)+';'+$
           STRTRIM(strobs.DATE_END,2)+';'+$
           STRTRIM(strobs.JDINT,2)+';'+$
           STRTRIM(strobs.JDFRAC,2)+';'+$
           STRTRIM(strobs.EXPTIME,2)+';'+$
           STRTRIM(strobs.CARROT,2)+';'+$
           STRTRIM(strobs.BSCALE,2)+';'+$
           STRTRIM(strobs.BZERO,2)+';'+$
           STRTRIM(strobs.BITPIX,2)+';'+$
           STRTRIM(strobs.NAXIS1,2)+';'+$
           STRTRIM(strobs.NAXIS2,2)+';'+$
           STRTRIM(strobs.R_SUN,2)+';'+$
           STRTRIM(strobs.CENTER_X,2)+';'+$
           STRTRIM(strobs.CENTER_Y,2)+';'+$
           STRTRIM(strobs.CDELT1,2)+';'+$
           STRTRIM(strobs.CDELT2,2)+';'+$
           STRTRIM(strobs.QUALITY,2)+';'+$
           STRTRIM(strobs.FILENAME,2)+';'+$
           STRTRIM(strobs.LOCAL_FILENAME,2)+';'+$
           STRTRIM(strobs.DATE_OBS_STRING,2)+';'+$
           STRTRIM(strobs.DATE_END_STRING,2)+';'+$
           STRTRIM(strobs.COMMENT,2)+';';+$
           ;STRTRIM(strobs.EOF,2)+';'

     CLOSE,un
     FREE_LUN,un,/FORCE


    ;######## FILE *fi_norm.txt ########

     OPENW,un,resfile3,/GET_LUN
		
     PRINTF,un,STRTRIM(strpro.IND,2)+';'+$
           STRTRIM(strpro.RUN_DATE,2)+';'+$
           STRTRIM(strpro.LOC_FILE,2)+';'+$
	   STRTRIM(strpro.NAXIS1,2)+';'+$
           STRTRIM(strpro.NAXIS2,2)+';'+$
           STRTRIM(strpro.R_SUN,2)+';'+$
           STRTRIM(strpro.CENTER_X,2)+';'+$
           STRTRIM(strpro.CENTER_Y,2)+';'+$
           STRTRIM(strpro.CDELT1,2)+';'+$
           STRTRIM(strpro.CDELT2,2)+';'+$
           ;STRTRIM(strpro.QSUNINT,2)+';'+$
	   STRTRIM(strpro.EL_CEN_X,2)+';'+$;New
           STRTRIM(strpro.EL_CEN_Y,2)+';'+$;New
           STRTRIM(strpro.EL_AXIS1,2)+';'+$;New
           STRTRIM(strpro.EL_AXIS2,2)+';'+$;New
           STRTRIM(strpro.EL_ANGLE,2)+';'+$;New
           ;STRTRIM(strpro.STDEV,2)+';'+$;New
           STRTRIM(strpro.STDEVGEO,2)+';'+$;New
           ;STRTRIM(strpro.ALGERR,2)+';'+$;New
	   STRTRIM(strpro.BITPIX,2)+';'+$;New
	   STRTRIM(strpro.EFIT,2)+';'+$;New
           STRTRIM(strpro.STANDARD,2)+';'+$;New
           STRTRIM(strpro.LIMBDARK,2)+';'+$;New
           STRTRIM(strpro.BACKGROUND,2)+';'+$;New
           STRTRIM(strpro.LINECLEAN,2)+';'+$;New
           STRTRIM(strpro.LINEC_MAIND,2)+';'+$;New
	   STRTRIM(strpro.QSUN_INT,2)+';'+$;New
           STRTRIM(strpro.PERCENT,2)+';'+$;New
	   STRTRIM(strpro.DIVISION,2)+';'+$;New
           STRTRIM(strpro.INORM,2)+';'+$;New
	   STRTRIM(strpro.INSTITUT,2)+';'+$;New
           STRTRIM(strpro.CODE,2)+';'+$;New
           STRTRIM(strpro.VERSION,2)+';'+$;New
           STRTRIM(strpro.CONTACT,2)+';'+$;New
	   STRTRIM(strpro.LOCAL_FILENAME,2)+';'+$
           STRTRIM(strpro.PP_LOCAL_FILENAME,2)+';';+$

     CLOSE,un
     FREE_LUN,un,/FORCE


    ;######## FILE *fi_feat.txt ########

     OPENW,un,resfile4,/GET_LUN
    ;PRINTF,un,STRTRIM(numfil,2),';',$

     FOR nn = 0, numfil-1 DO BEGIN

     PRINTF,un,STRTRIM(strfil[nn].IND,2)+';'+$
           STRTRIM(strfil[nn].RUN_DATE,2)+';'+$
           STRTRIM(strfil[nn].GRAV_C_ARCX,2)+';'+$
           STRTRIM(strfil[nn].GRAV_C_ARCY,2)+';'+$
           STRTRIM(strfil[nn].GRAV_C_CAR_LAT,2)+';'+$
           STRTRIM(strfil[nn].GRAV_C_CAR_LON,2)+';'+$
           STRTRIM(strfil[nn].SAMPLECOUNT,2)+';'+$;or feat_npix
           STRTRIM(strfil[nn].AREA,2)+';'+$
           STRTRIM(strfil[nn].MEAN_INT_RATIO,2)+';'+$;or feat_mean2qsun
           STRTRIM(strfil[nn].BRARC_X_LL,2)+';'+$
           STRTRIM(strfil[nn].BRARC_Y_LL,2)+';'+$
           STRTRIM(strfil[nn].BRARC_X_UR,2)+';'+$
           STRTRIM(strfil[nn].BRARC_Y_UR,2)+';'+$
           STRTRIM(strfil[nn].BRPIX_X_LL,2)+';'+$
           STRTRIM(strfil[nn].BRPIX_Y_LL,2)+';'+$
           STRTRIM(strfil[nn].BRPIX_X_UR,2)+';'+$
           STRTRIM(strfil[nn].BRPIX_Y_UR,2)+';'+$
           STRTRIM(strfil[nn].FEAT_MAX_INT,2)+';'+$
           STRTRIM(strfil[nn].FEAT_MIN_INT,2)+';'+$
           STRTRIM(strfil[nn].FEAT_MEAN_INT,2)+';'+$
           STRTRIM(strfil[nn].ENC_MET,2)+';'+$
           STRTRIM(strfil[nn].COD_PIX_X,2)+';'+$
           STRTRIM(strfil[nn].COD_PIX_Y,2)+';'+$
           STRTRIM(strfil[nn].COD_ARC_X,2)+';'+$
           STRTRIM(strfil[nn].COD_ARC_Y,2)+';'+$
           STRTRIM(strfil[nn].SKE_LEN_DEG,2)+';'+$
           ;STRTRIM(strfil[nn].THICKNESS_PIX,2)+';'+$
           STRTRIM(strfil[nn].CURVATURE,2)+';'+$
           STRTRIM(strfil[nn].ELONG,2)+';'+$
           STRTRIM(strfil[nn].ORIENTATION,2)+';'+$
           STRTRIM(strfil[nn].COD_SKE_PIX_X,2)+';'+$
           STRTRIM(strfil[nn].COD_SKE_PIX_Y,2)+';'+$
           STRTRIM(strfil[nn].COD_SKE_ARC_X,2)+';'+$
           STRTRIM(strfil[nn].COD_SKE_ARC_Y,2)+';'+$
           STRTRIM(strfil[nn].CHAIN_CODE,2)+';'+$
           STRTRIM(strfil[nn].CCODE_LNTH,2)+';'+$
           STRTRIM(strfil[nn].CHAIN_CODE_SKE,2)+';'+$
           STRTRIM(strfil[nn].CCODE_SKE_LNTH,2)+';'+$
           ;STRTRIM(strfil[nn].RASTER_SCAN_LNTH,2)+';'+$           
           STRTRIM(strfil[nn].PP_LOCAL_FILENAME,2)+';'+$     
	   STRTRIM(strfil[nn].FRC_INSTITUT,2)+';'+$;New
	   STRTRIM(strfil[nn].FRC_CODE,2)+';'+$;New
	   STRTRIM(strfil[nn].FRC_VERSION,2)+';'+$;New
	   STRTRIM(strfil[nn].FRC_FEATURE_NAME,2)+';'+$;New
	   STRTRIM(strfil[nn].FRC_CONTACT,2)+';'+$
           STRTRIM(datef[0] + obst +'_fi_feat.txt',2)+';';+$
           ;STRTRIM(strfil[nn].EOR,2)+';'

       ENDFOR

           ;PRINTF,un,STRTRIM(strfil[0].EOF,2)+';'

       CLOSE,un
       FREE_LUN,un,/FORCE

    ;######## FILE *fi_ccode.txt ########

    ; OPENW,un,resfile5,/GET_LUN
    ;
    ;      ;PRINTF,un,strobs.IND
    ;      ;PRINTF,un,strfil[0].NUM_FEAT
    ;
    ;   FOR nn = 0, numfil-1 DO BEGIN
    ;      PRINTF,un,strobs.IND
    ;      PRINTF,un,strfil[0].NUM_FEAT
    ;      PRINTF,un,strfil[nn].IND_FEAT
    ;      PRINTF,un,strfil[nn].COD_PIX_X
    ;      PRINTF,un,strfil[nn].COD_PIX_Y
    ;      PRINTF,un,strfil[nn].COD_ARC_X
    ;      PRINTF,un,strfil[nn].COD_ARC_Y
    ;      PRINTF,un,strfil[nn].COD_SKE_PIX_X
    ;      PRINTF,un,strfil[nn].COD_SKE_PIX_Y
    ;      PRINTF,un,strfil[nn].COD_SKE_ARC_X
    ;      PRINTF,un,strfil[nn].COD_SKE_ARC_Y
    ;      PRINTF,un,strfil[nn].SKE_CHAIN
    ;      PRINTF,un,strfil[nn].BND_CHAIN     
    ;      PRINTF,un,strfil[nn].EOR
    ;   ENDFOR
    ;
    ;      PRINTF,un,strfil[0].EOF
    ;
    ; CLOSE,un


    ;--------------------------------------------------------
    ; display the skeletons and WRITE a jpeg file of the res
    ;--------------------------------------------------------

      IF DISPLAY_res EQ 1 OR PIXMAP_method EQ 1 THEN BEGIN
            IF strpro.NAXIS1 EQ 2048 THEN res = ascii2fil(FILE=resfile4,/ske,/IM_2K,/NEW_NORM) ELSE res = ascii2fil(FILE=resfile4,/ske,/NEW_NORM)
            res = DILATE(res,REPLICATE(1,3,3))
            ww = WHERE(res)
            imi = im*0b
            imi[maskbck]=2b
            imi[ww]=0b
            imi[mask_comp]=0b
            imi[0,0]=3b
            TVSCL,CONGRID(imi,hh,hh),0,hh
            imi=0
      ENDIF
      IF JPEG_output EQ 1 THEN WRITE_JPEG,resfile7,TVRD()
      

  ;###### End of main loop ##### 
  endloop:
  ENDFOR


;###### End of Program #####
END

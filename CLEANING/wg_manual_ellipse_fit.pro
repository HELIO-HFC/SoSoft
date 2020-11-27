PRO MAIN13_Event, Event

  COMMON ALL,tabx,taby,pt,numpt,xsim,ysim,flagel,imptr,ww1,ww2
  COMMON ELL,xc1,yc1,R1,R2,theta,stdev,stdevGeo


  WIDGET_CONTROL,Event.Top,GET_UVALUE=drawId
  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev


  CASE Ev OF 

  'BUTTON2': BEGIN
      TV,BYTSCL(*imptr,ww1,ww2)
      IF pt NE 0 THEN BEGIN
         PLOTS,tabx,taby,/dev,color=0,PSYM=1
      ENDIF   
      END
  'BUTTON3': BEGIN     
      IF flagel EQ 1 THEN BEGIN
        PTR_FREE,imptr
        widget_control,event.top,/destroy
      ENDIF ELSE BEGIN
        res=dialog_message('Not enough points!')
      ENDELSE
      END
  'BUTTON5': BEGIN
       IF pt GE numpt THEN BEGIN
        nele = N_ELEMENTS(tabx)
        tabxe=LONG(tabx[1:nele-1])
        tabye=LONG(taby[1:nele-1])
        binary2 = bytarr(xsim,ysim)
        binary2[tabye*xsim+tabxe]=1b
        xct = TOTAL(tabxe)/(nele-1)
        yct = TOTAL(tabye)/(nele-1)

        egso_ellipsefitsvd, binary2, xct, yct, xc1, yc1, R1, R2, theta, stdev, stdevGeo

       ; Divide a circle into Npoints.
 
        npoints = 120
        phi = 2 * !PI * (Findgen(npoints) / (npoints-1))

       ; Position angle in radians.

        ang = ((theta*!radeg + 360) MOD 360) / !RADEG

       ; Sin and cos of angle.

        cosang = Cos(ang)
        sinang = Sin(ang)

       ; Parameterized equation of ellipse.

        x =  R1 * Cos(phi)
        y =  R2 * Sin(phi)

       ; Rotate to desired position angle.

        xprime = xc1 + (x * cosang) - (y * sinang)
        yprime = yc1 + (x * sinang) + (y * cosang)

       ; Extract the points to return.
 
        pts = FltArr(2, N_Elements(xprime))
        pts[0,*] = xprime
        pts[1,*] = yprime

        PLOTS,pts,/dev,color=0

        flagel = 1
       ENDIF ELSE BEGIN
        res=dialog_message('Not enough points!')
       ENDELSE   
      END
  'BUTTON4': BEGIN
      Print, 'Event for cancel'
      PTR_FREE,imptr
      widget_control,event.top,/destroy
      RETALL
      END  
  'BUTTON6': BEGIN
      Print, 'Points Reset'
      tabx = 0  
      taby = 0
      pt = 0
      R1 = 0
      R2 = 0
      xc1 = 0
      yc1 = 0
      theta = 0
      END  
  'BUTTON7': BEGIN
      XLOADCT
      END  
  'DRAW11': BEGIN
      IF Event.press EQ 1 THEN BEGIN
        PRINT,pt+1,' -> ',STRTRIM(Event.X,2),',',STRTRIM(Event.Y,2)
        tabx=[tabx,Event.X]
        taby=[taby,Event.Y]
        pt = pt + 1 
        PLOTS,Event.X,Event.Y,/dev,color=0,PSYM=1
      ENDIF

      END
  ENDCASE
END


; DO NOT REMOVE THIS COMMENT: END MAIN13
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.



FUNCTION WG_MANUAL_ELLIPSE_FIT,im

  COMMON ALL,tabx,taby,pt,numpt,xsim,ysim,flagel,imptr,ww1,ww2
  COMMON ELL,xc1,yc1,R1,R2,theta,stdev,stdevGeo


  DEVICE,DECOMPOSED=0;,retain=2
  LOADCT,3

  siz = SIZE(im)
  xsim = siz[1]
  ysim = siz[2]
  tabx = 0
  taby = 0
  pt = 0
  numpt = 10
  flagel = 0
  imptr = PTR_NEW(im)
  xdisp = 1500
  ydisp = xdisp

  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }

  MAIN13 = Widget_Base(GROUP_LEADER=Group, RESOURCE_NAME='pre_clean', $
      SCR_XSIZE=xdisp ,SCR_YSIZE=ydisp ,TITLE='PRE CLEAN' ,SPACE=3  $
      ,XPAD=3 ,YPAD=3)

  BUTTON2 = Widget_Button(MAIN13,UVALUE='BUTTON2'  $
     ,XOFFSET=10 ,YOFFSET=10 ,SCR_XSIZE=40 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='REDRAW', RESOURCE_NAME='button2')

  BUTTON3 = Widget_Button(MAIN13,UVALUE='BUTTON3'  $
     ,XOFFSET=60 ,YOFFSET=10 ,SCR_XSIZE=40 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='END', RESOURCE_NAME='button3')

  BUTTON4 = Widget_Button(MAIN13,UVALUE='BUTTON4'  $
     ,XOFFSET=290 ,YOFFSET=10 ,SCR_XSIZE=50 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='CANCEL', RESOURCE_NAME='button4')

  BUTTON5 = Widget_Button(MAIN13,UVALUE='BUTTON5'  $
     ,XOFFSET=110 ,YOFFSET=10 ,SCR_XSIZE=80 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='SHOW ELLIPSE', RESOURCE_NAME='button5')

  BUTTON6 = Widget_Button(MAIN13,UVALUE='BUTTON6'  $
     ,XOFFSET=200 ,YOFFSET=10 ,SCR_XSIZE=80 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='RESET POINTS', RESOURCE_NAME='button6')

  BUTTON7 = Widget_Button(MAIN13,UVALUE='BUTTON7'  $
     ,XOFFSET=350 ,YOFFSET=10 ,SCR_XSIZE=50 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='XLOADCT', RESOURCE_NAME='button7')

  DRAW11 = WIDGET_DRAW(MAIN13, $
      UVALUE='DRAW11', $
      XSIZE=xsim, $
      YSIZE=ysim, $
      ;/SCROLL, $
      ;X_SCROLL_SIZE=xdisp-20, $
      ;Y_SCROLL_SIZE=ydisp-20, $
      XOFFSET=10, $
      YOFFSET=50, $
      /BUTTON)


  WIDGET_CONTROL, MAIN13, /REALIZE

  hst = SMOOTH(HISTOGRAM(im[where(im)],bin=1,min=0),10)
  ww = WHERE(hst GT 100)
  ww1 = ww[0]
  ww2 = ww[N_ELEMENTS(ww)-1]
  TV,BYTSCL(im,ww1,ww2)
  ; Set drawable window index as Main13 uservalue

  WIDGET_CONTROL, MAIN13, SET_UVALUE=DRAW11,yoffset=100

  XMANAGER, 'MAIN13', MAIN13
  
  RETURN,[xc1,yc1,R1,R2,theta,stdevGeo,stdev]
END







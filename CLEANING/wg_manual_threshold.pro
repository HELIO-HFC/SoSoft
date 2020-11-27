PRO MAIN14_Event, Event

  COMMON ALL2,thresh,ww1,ww2,imaptr


  WIDGET_CONTROL,Event.Top,GET_UVALUE=drawId
  WIDGET_CONTROL,Event.Id,GET_UVALUE=Ev


  CASE Ev OF 

  'BUTTON2': BEGIN
      TV,BYTSCL(*imaptr,ww1,ww2)
      END
  'BUTTON3': BEGIN     
        PTR_FREE,imaptr
        widget_control,event.top,/destroy
      END
  'BUTTON4': BEGIN
      Print, 'Event for cancel'
      PTR_FREE,imaptr
      widget_control,event.top,/destroy
      RETALL
      END  
  'BUTTON7': BEGIN
      XLOADCT
      END  
  'DRAW11': BEGIN
      IF Event.press EQ 1 THEN BEGIN
         tempo = *imaptr
         thresh = tempo[Event.X,Event.Y]
         TV,BYTSCL(tempo > thresh,ww1,ww2)
         tempo = 0
      ENDIF

      END
  ENDCASE
END


; DO NOT REMOVE THIS COMMENT: END MAIN13
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.



FUNCTION WG_MANUAL_THRESHOLD,ima

   COMMON ALL2,thresh,ww1,ww2,imaptr


  DEVICE,DECOMPOSED=0,retain=2
  LOADCT,38

  thresh = 0
  siz = SIZE(ima)
  xsim = siz[1]
  ysim = siz[2]
  imaptr = PTR_NEW(ima)


  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }

  MAIN14 = Widget_Base(GROUP_LEADER=Group, RESOURCE_NAME='pre_clean', $
      SCR_XSIZE=950 ,SCR_YSIZE=920 ,TITLE='PRE CLEAN' ,SPACE=3  $
      ,XPAD=3 ,YPAD=3)

  BUTTON2 = Widget_Button(MAIN14,UVALUE='BUTTON2'  $
     ,XOFFSET=10 ,YOFFSET=10 ,SCR_XSIZE=40 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='REDRAW', RESOURCE_NAME='button2')

  BUTTON3 = Widget_Button(MAIN14,UVALUE='BUTTON3'  $
     ,XOFFSET=60 ,YOFFSET=10 ,SCR_XSIZE=40 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='END', RESOURCE_NAME='button3')

  BUTTON4 = Widget_Button(MAIN14,UVALUE='BUTTON4'  $
     ,XOFFSET=110 ,YOFFSET=10 ,SCR_XSIZE=50 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='CANCEL', RESOURCE_NAME='button4')

  BUTTON7 = Widget_Button(MAIN14,UVALUE='BUTTON7'  $
     ,XOFFSET=170 ,YOFFSET=10 ,SCR_XSIZE=50 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='XLOADCT', RESOURCE_NAME='button7')

  DRAW11 = WIDGET_DRAW(MAIN14, $
      UVALUE='DRAW11', $
      XSIZE=xsim, $
      YSIZE=ysim, $
      /SCROLL, $
      X_SCROLL_SIZE=910, $
      Y_SCROLL_SIZE=560, $
      XOFFSET=10, $
      YOFFSET=50, $
      /BUTTON)


  WIDGET_CONTROL, MAIN14, /REALIZE

  hst = SMOOTH(HISTOGRAM(ima[where(ima)],bin=1,min=0),10)
  ww = WHERE(hst GT 100)
  ww1 = ww[0]
  ww2 = ww[N_ELEMENTS(ww)-1]
  TV,BYTSCL(ima,ww1,ww2)
  ; Set drawable window index as Main13 uservalue

  WIDGET_CONTROL, MAIN14, SET_UVALUE=DRAW11;,yoffset=100

  XMANAGER, 'MAIN14', MAIN14
  
  RETURN,thresh
END







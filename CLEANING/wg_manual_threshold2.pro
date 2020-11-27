PRO MAIN14_Event, Event

  COMMON ALL2,thresh,ww1,ww2,imaptr


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
      thresh = -1
      widget_control,event.top,/destroy
      ;RETALL
      END  
  'BUTTON7': BEGIN
      XLOADCT
      END  
  'DRAW11': BEGIN
      END
  'SLIDER1':BEGIN
      WIDGET_CONTROL,Event.Id,GET_VALUE=thresh
      TV,BYTSCL(*imaptr GT thresh)
  END

  ENDCASE
END


; DO NOT REMOVE THIS COMMENT: END MAIN13
; CODE MODIFICATIONS MADE BELOW THIS COMMENT WILL BE LOST.



FUNCTION WG_MANUAL_THRESHOLD2,ima

   COMMON ALL2,thresh,ww1,ww2,imaptr


  DEVICE,DECOMPOSED=0;,retain=2


  thresh = 0
  siz = SIZE(ima)
  xsim = siz[1]
  ysim = siz[2]
  newsizx = 1200
  newsizy = FIX((FLOAT(newsizx)/FLOAT(xsim))*ysim)
  smallima = CONGRID(ima,newsizx,newsizy)
  imaptr = PTR_NEW(smallima)

  hst = SMOOTH(HISTOGRAM(ima[where(ima)],bin=1,min=0),10)
  ww = WHERE(hst GT 100)
  ww1 = ww[0]
  ww2 = ww[N_ELEMENTS(ww)-1]

  IF N_ELEMENTS(Group) EQ 0 THEN GROUP=0

  junk   = { CW_PDMENU_S, flags:0, name:'' }

  MAIN14 = Widget_Base(GROUP_LEADER=Group, RESOURCE_NAME='pre_clean', $
      SCR_XSIZE=newsizx+40 ,SCR_YSIZE=newsizy+60 ,TITLE='PRE CLEAN' ,SPACE=3  $
      ,XPAD=3 ,YPAD=3)

  BUTTON2 = Widget_Button(MAIN14,UVALUE='BUTTON2'  $
     ,XOFFSET=60 ,YOFFSET=10 ,SCR_XSIZE=40 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='REDRAW', RESOURCE_NAME='button2')

  BUTTON3 = Widget_Button(MAIN14,UVALUE='BUTTON3'  $
     ,XOFFSET=10 ,YOFFSET=10 ,SCR_XSIZE=40 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='END', RESOURCE_NAME='button3')

  BUTTON4 = Widget_Button(MAIN14,UVALUE='BUTTON4'  $
     ,XOFFSET=170 ,YOFFSET=10 ,SCR_XSIZE=50 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='CANCEL', RESOURCE_NAME='button4')

  BUTTON7 = Widget_Button(MAIN14,UVALUE='BUTTON7'  $
     ,XOFFSET=110 ,YOFFSET=10 ,SCR_XSIZE=50 ,SCR_YSIZE=30  $
     ,/ALIGN_CENTER ,VALUE='XLOADCT', RESOURCE_NAME='button7')

  DRAW11 = WIDGET_DRAW(MAIN14, $
      UVALUE='DRAW11', $
      XSIZE=newsizx, $
      YSIZE=newsizy, $
      XOFFSET=30, $
      YOFFSET=50, $
      /BUTTON)

  SLIDER1 = Widget_Slider(MAIN14,UVALUE='SLIDER1'  $
     ,XOFFSET=10 ,YOFFSET=50, MAXIMUM=ww2, MINIMUM = ww1  $
     ,/ALIGN_CENTER ,VALUE=ww1, RESOURCE_NAME='slider1',/VERTICAL $
     ,XSIZE = 20, YSIZE=newsizy, /DRAG)


  WIDGET_CONTROL, MAIN14, /REALIZE

  ; Set drawable window index as Main13 uservalue
  TV,BYTSCL(smallima,ww1,ww2)
  WIDGET_CONTROL, MAIN14, SET_UVALUE=DRAW11,yoffset=100

  XMANAGER, 'MAIN14', MAIN14
  
  RETURN,thresh
END







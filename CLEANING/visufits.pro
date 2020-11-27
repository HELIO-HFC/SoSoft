PRO VISUFITS

path = '/obs/cnudde/data4/FITS/Ha/'
display = 768
im = DIALOG_PICKFILE(PATH=path,GET_PATH=gpath)
command = 'ls '+gpath+'*.fits '+gpath+'*.fits.gz '+gpath+'*.fts.gz '+gpath+'*.fts '+gpath+'*.fits.Z 2>/dev/null'
SPAWN, command,tabf
zero=BYTARR(display,display)
badrep=gpath+'BAD'

IF N_ELEMENTS(tabf) GT 0 THEN BEGIN
   rep= ""
   command1 = "ls -d "+badrep+" 2>/dev/null"
   SPAWN,command1,res1
   IF STRTRIM(res1,2) NE badrep THEN BEGIN
        nomove = 1
        READ,"Le répertoire BAD n'existe pas, voulez-vous le créér ? [o] ou [n] ",rep  
        IF STRTRIM(rep,2) EQ "o" THEN BEGIN
            command2 = 'mkdir '+badrep
            SPAWN,command2
            PRINT,"Répertoire créer !"
            nomove = 0
         ENDIF
     ENDIF Else nomove = 1
   WINDOW,0,xs=display,ys=display
   FOR ii = 0,N_ELEMENTS(tabf)-1 DO BEGIN
     imi = READFITS(tabf[ii])
     info=SIZE(imi)
     IF info[0] GT 2 THEN BEGIN
           dim  = info[3]
           dimi = dim - FIX(dim/2.) - 1 
           imi   = imi[*,*,dimi]
     ENDIF
     xx = 1.*info[1]
     yy = 1.*info[2]
     IF xx GT yy THEN TVSCL,CONGRID(imi,display,display*(yy/xx))
     IF xx LE yy THEN TVSCL,CONGRID(imi,display*(xx/yy),display)
     var=""
     READ,"Garder l'image [o] ? ou non [n] ? ",var
     IF STRTRIM(var,2) EQ "n" THEN BEGIN
        IF nomove EQ 0 THEN BEGIN
            PRINT,"L'image est déplacée dans le répertoire "+badrep
            command3 = 'mv '+tabf[ii]+" "+badrep+"/"+STRMID(tabf[ii],STRLEN(gpath))
            SPAWN,command3
         ENDIF ELSE BEGIN
            PRINT,"Le répertoire BAD n'existe pas, vous ne pouvez pas déplacer le fichier"
         ENDELSE
     ENDIF
     IF STRTRIM(var,2) NE "n" AND STRTRIM(var,2) NE "o" THEN BEGIN
        PRINT,"Réponse non reconnue: < "+var+" >, l'image n'est pas deplacée. "
     ENDIF
     TVSCL,zero
   ENDFOR
ENDIF

END

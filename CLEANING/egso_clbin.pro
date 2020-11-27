;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_clbin
;
; PURPOSE           : Cleaning the input binary image
;
; EXPLANATION       : Cleaning the input binary image by setting all pixels outside r1 and r2 to 0
;
;
; CATEGORY          : EGSO_WP5, Fitting an Ellipse
;
; CALLING SEQUENCE  : egso_clbin, binary, xc, yc, r1, r2
;
;
; INPUT             : im       binary image
;                     r1, r2   cleaning annuli radiuses
;                     xc, yc   centre (must be float)
;
; OUTPUT            : im       binary image
;
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : None
;
; EXAMPLE           : binary=egso_clbin(binary, xc, yc, R1, R2 )
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================



function egso_clbin, binary, xc, yc, r1, r2


xc=float(xc)
yc=float(yc)

rmax=float(r1>r2)
rmin=float(r1<r2)

info=size(binary)
nx=info[1]
ny=info[2]
im=binary
locs=where(binary)

n=n_elements(locs)
if n lt 2 then return, binary
count=0
for k=0l, n-1, 1 do begin
    j=fix(locs[k]/nx)
    i=locs[k] mod nx
    dist=sqrt((xc-i)*(xc-i)+(yc-j)*(yc-j))
    if dist gt rmax or dist lt rmin then begin
        im[locs[k]]=0
        count=count+1
    endif
endfor

;print, 'Number of Points Removed:', count
return, im


end



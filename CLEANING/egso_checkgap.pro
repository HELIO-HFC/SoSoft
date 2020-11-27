;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_checkgap
;
; PURPOSE           : Checking the angular gap between the non zero points on a binary image
;
; EXPLANATION       : The candidate edge points are checked for the presence of contiguous
;                     angular gaps (greater than 30 degree, but not critical) in the data and,
;                     if necessary, Canny edge detection with a lower threshold is applied
;                     again and the whole process is repeated.
;
;
; CATEGORY          : EGSO_WP5, Fitting an Ellipse
;
; CALLING SEQUENCE  : egso_checkgap, binary, xc, yc
;
;
; INPUT             : binary   input binary image
;                     xc, yc   center in pixel coordinates
;
; OUTPUT            : gap
;
; KEYWORDS          : None
;
; PROCEDURE         : gap=egso_checkgap(binary, xc, yc)
;
; CALLS             : cv_coord
;
; EXAMPLE           : gap=egso_checkgap(binary, xc, yc)
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================

function egso_checkgap, binary, xc, yc


info=size(binary)
nx=info[1]
locs=where(binary)
n=n_elements(locs)

theta_array=dblarr(n)
dist_array=dblarr(n)
df_theta=dblarr(n)

;   Generate Angle Array

for k=0, n-1, 1 do begin
    j=fix(locs[k]/nx)
    i=locs[k] mod nx
    polar=cv_coord(FROM_RECT=[i-xc, j-yc], /TO_POLAR, /DEGREES, /DOUBLE)
    dist_array[k]=polar[1]
    if polar[0] ge 0 then theta_array[k]=polar[0] else theta_array[k]=360+polar[0]
endfor
ind=sort(theta_array)


;   Calculate Difference Array

df_theta[0]=theta_array[ind[0]]+(360-theta_array[ind[n-1]])
for i=1, n-1, 1 do df_theta[i]=theta_array[ind[i]]-theta_array[ind[i-1]]

gap=max(df_theta)

return, gap
end


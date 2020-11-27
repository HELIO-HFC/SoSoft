;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_getcontrastimage
;
; PURPOSE           : Producing cleaned image by dividing/subtracting original by quiet sun
;
; EXPLANATION       : Using the generated Quiet Sun (background) image to renormalize the original
;                     image and remove the radial component of the solar illumination.
;
; CATEGORY          : EGSO_WP5 image cleanning
;
; CALLING SEQUENCE  : egso_getcontrastimage(image, QSImage, R, xc, yc [Inorm=Inorm, /subtract])
;
;
; INPUT             : image      Input image
;                     QSImage    Quiet Sun Image
;                     R          Disk Radiuse
;                     xc, yc     Disk centre coordinate
;                     Inorm      (optional) normalizing parameter for division method
;
; OUTPUT            : cleaned image
;
;
; KEYWORDS          : subtract     cleaned image is taken as difference between the original and quiet sun
;
; PROCEDURE         :
;
; CALLS             : None
;
; EXAMPLE           : result = egso_getcontrastimage(imst, qsim, 420., 511.5, 511.5, Inorm=1000) ;(i.e. using division method)
;                     result=getcontrastimage(imst, qsim, 420., 511.5, 511.5, /subtract) ;(i.e. using differencing method)
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================

function egso_getcontrastimage, image, QSImage, R, xc, yc, Inorm=Inorm, subtract=subtract


info=size(image)
nx=info[1]
ny=info[2]
CImage=QSImage
if not keyword_set(Inorm) then Inorm=max(QSImage)

if not keyword_set(subtract) then begin
       for i=0, nx-1 do $
         for j=0, ny-1 do begin
          IF (CImage(i,j)  GT 0) THEN CImage(i,j) $
           = FIX(DOUBLE(image(i,j)) / DOUBLE(CImage(i,j))   * Inorm +0.5)
         endfor
         endif else begin
          locs=where(QSImage eq 0)
;window,xs=1024,ys=1024,/free
;tvscl,CONGRID(QSImage,1024,914)

          CImage=image-QSImage
;window,xs=1024,ys=1024,/free
;tvscl,CONGRID(CImage,1024,914)
;stop
          mci=min(CImage)
          xarr=replicate(mci, nx, ny)

          BLAS_AXPY, CImage, -1, xarr
          CImage[locs]=0
         endelse

return, CImage
end



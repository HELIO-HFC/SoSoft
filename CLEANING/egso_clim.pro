;============================================================================================================
;+
; PROJECT           : EGSO, WP5
;
; NAME              : egso_clim
;
; PURPOSE           : Cleanning Image via Label_Region pro
;
; EXPLANATION       : Create an image that includes one object which the solar disk
;
;
; CATEGORY          : EGSO_WP5, Fitting an Ellipse
;
; CALLING SEQUENCE  :  egso_clim, image, thr_value, imageB, count
;
;
; INPUT             : image       image to be cleaned
;                     thr_value   threshold value
;
; OUTPUT            : imageB       output image with outside structures removed
;                     count        number of non-zero pixels in the cleaned image
;
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : label_region
;
; EXAMPLE           : egso_clim, image, thr_value, imageB, count
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003

;===================================================================================================


pro egso_clim, image, thr_value, imageB, count


info=size(image)
nx=info[1]
ny=info[2]

locs_thr=where(image gt thr_value, complement=locs_com)

imageBin=bytarr(nx, ny)
imageBin[locs_thr]=1b
imageBin[locs_com]=0b

;window,6,xs=nx/2,ys=ny/2
;tvscl,congrid(imageBin,nx/2,ny/2)

image_label=label_region(imageBin, /all_neighbors)

h=histogram(image_label, reverse_indices=r)
n_regions=n_elements(h)

maRegion=max(h[1:n_regions-1])
region0=where(h eq maRegion)

if n_elements(region0) ne 1 then region_label=region0[0] else region_label=region0


;Find subscripts of members of region i.

p = r(r[region_label]:r[region_label+1]-1)



imageB=image
imageB[*,*]=0
imageB[p]=image[p]

count=n_elements(p)


end

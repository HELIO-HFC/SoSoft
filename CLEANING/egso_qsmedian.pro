;+
; PROJECT          : EGSO, WP5
;
; NAME              : egso_qsmedian
;
; PURPOSE           : Constructing Quiet Sun (background image) from the full disk image using median
;
; EXPLANATION       : Estimated background images, including radial limb darkening but with smaller features removed,
;                     were computed using the median transform. In this case the median value of each row was used to
;                     replace all the intensities in each row.
;
; CALLING SEQUENCE  : qsun_im = egso_qsmedian (image, R, xc, yc)
;
;
; INPUT             : image         input image
;                     R             disk Radius
;                     xc, yc        disk centre coordinate
;
; OUTPUT            : MedianImage   image cleaned via Median
;
; KEYWORDS          : None
;
; PROCEDURE         :
;
; CALLS             : egso_pix2polarray, egso_pol2pixarray
;
; EXAMPLE           : qsun_im = egso_qsmedian (image, 420, 511.5, 511.5)
;
; SIDE EFFECTS      : None.
;
; WRITTEN           : EGSO, WP5, Bradford
;
; MODIFICATION HISTORY:  14-10-2003
;                        05/2005 NF discard values too high from the median calculation
;===================================================================================================

function egso_qsmedian, image, R, xc, yc



p_arr_median2 = egso_pix2polarray(image, R, xc,yc)

info=size(image)
nx=info[1]
ny=info[2]
imin=size(p_arr_median2)


;recontructed_original=recontruct_from_pixel( image, p_arr_median2, R, xc,yc)

minx=imin[1]
miny=imin[2]

;nf l'exemple du 01 Mai 2005 en K3 montre que si une region active
;brillante se situe au centre du disque, la correction du limb
;darkening sera trop importante, conduisant a introduire de fausse
;taches sombres au centre. L'ideal serait de supprimer les regions
;trop  brillantes avant le calcul de la mediane:

med = MEDIAN(p_arr_median2[*,miny/3:miny/2])
toohigh = WHERE(p_arr_median2 GT med*1.5,ntoo)
IF ntoo GT 0 THEN p_arr_median2[toohigh]=med;0.

;dans le cas ou on remplace par 0 au lieu de med a la ligne precedente:
;for i=miny-1,0,-1 do begin
;    vals = p_arr_median2[*, i]
;    nnul = WHERE(vals,nnnul)
;    IF nnnul GT minx/3 THEN value=median(vals[nnul], /even)
;    p_arr_median2[*,i]=value
;endfor


for i=0,miny-1 do begin
    value = median(p_arr_median2[*,i], /even)
    p_arr_median2[*,i]=value
endfor


reconstructed_median2 = egso_pol2pixarray(image, p_arr_median2, R, xc,yc)

return, reconstructed_median2

end


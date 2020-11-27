pro sosoft_pp_procedure

;=============================================================
dll='/obs/romagnan/C_LIB/gauss.so'
dll2='/obs/romagnan/C_LIB/canny.so'
linkimage, 'gauss_smoothing', dll, 1, 'GaussSmoothing'
linkimage, 'canny', dll2, 1, 'CannyHT'
;=========================================================

print,'preprocessing ...'

fits_filename='*.fits'
pp_in_path='/poubelle/romagnan/FITS/'

im_size=2
fits_list=file_search(pp_in_path+fits_filename)

pp_out_path='/poubelle/romagnan/FITS_PROCESSED/'
quicklook_path='/poubelle/romagnan/quicklook/'

restore,filename='/obs/romagnan/CLEANING/preprocess_filament.sav',/verbose

for i=0,n_elements(fits_list)-1 do begin
	preprocess_filament,fits_list[i],im_size,pp_out_path,out_filename=out_filename
endfor

end

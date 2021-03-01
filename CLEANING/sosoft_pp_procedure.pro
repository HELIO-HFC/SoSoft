pro sosoft_pp_procedure

path_to_sosoft    = getenv('path_to_sosoft')
fits_tycho_dir    = getenv('fits_tycho_dir')
prepros_tycho_dir = getenv('prepros_tycho_dir')
xml_sosoft_dir    = getenv('xml_sosoft_dir')
quicklook_tycho_dir = getenv('quicklook_tycho_dir')

;=============================================================
dll=path_to_sosoft+'/C_LIB/gauss.so'
dll2=path_to_sosoft+'/C_LIB/canny.so'
linkimage, 'gauss_smoothing', dll, 1, 'GaussSmoothing'
linkimage, 'canny', dll2, 1, 'CannyHT'
;=========================================================

print,'preprocessing ...'

objxml = obj_new('configfile')

xml_file=xml_sosoft_dir+'/'+'sosoft_parameters.xml'

objxml->parsefile,xml_file

parameters = objxml->get_struct()

fits_list=file_search(fits_tycho_dir+parameters.fits_filename)

restore,filename=path_to_sosoft+'/CLEANING/preprocess_filament.sav',/verbose

for i=0,n_elements(fits_list)-1 do begin
	preprocess_filament,fits_list[i],parameters.im_size,prepros_tycho_dir,out_filename=out_filename
  ;fitstopng,prepros_tycho_dir+'/'+out_filename,quicklook_tycho_dir
endfor

end

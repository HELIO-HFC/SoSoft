pro sosoft_pp_procedure

path_to_sosoft = getenv('path_to_sosoft')

;=============================================================
dll=path_to_sosoft+'/C_LIB/gauss.so'
dll2=path_to_sosoft+'/C_LIB/canny.so'
linkimage, 'gauss_smoothing', dll, 1, 'GaussSmoothing'
linkimage, 'canny', dll2, 1, 'CannyHT'
;=========================================================

print,'preprocessing ...'

objxml = obj_new('ConfigFile')

xml_file='sosoft_parameters.xml'

objxml->parsefile,xml_file

parameters = objxml->get_struct()

fits_list=file_search(parameters.pp_in_path+parameters.fits_filename)

restore,filename=path_to_sosoft+'/CLEANING/preprocess_filament.sav',/verbose

for i=0,n_elements(fits_list)-1 do begin
	preprocess_filament,fits_list[i],parameters.im_size,parameters.pp_in_path,out_filename=out_filename
endfor

end

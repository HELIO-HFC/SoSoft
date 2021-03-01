#! /bin/tcsh -f

set year=${2}
set month=${1}

set askdate="20${year}${month}01"

set hha_preprocessed_filename="mh${year}${month}\?\?.\?\?\?\?\?\?_subtract_processed.fits"
set spc_preprocessed_filename="spectro_obspm_ha_20${year}${month}\?\?_\?\?\?\?\?\?_subtract_processed.fits"

printf "\n"
printf $askdate
printf "\n"

if ($askdate > $last_ha_day) then
  printf "Spectrocam data"
  set fits_name="spectro_obspm_ha_20${year}${month}\?\?_\?\?\?\?\?\?\*fits\*"
  set fits_directory=${bass2000_spectrocam_directory}
else
  printf "Halpha data"
  set fits_name="mh${year}${month}\?\?.\?\?\?\?\?\?\*fits\*"
  set fits_directory=${bass2000_halpha_directory}
endif

printf "\n"
printf "$fits_name"
printf "\n"
printf "$fits_directory"
printf "\n"

if ($askdate > $last_ha_day) then
scp ${prepros_tycho_dir}/* ${hfc_user_and_data_server}:${lesia08_root}/${bass2000_test_directory_image}/20${year}/
scp ${quicklook_tycho_dir}/* ${hfc_user_and_data_server}:${lesia08_root}/${bass2000_test_directory_image}/20${year}/
else
scp -v ${prepros_tycho_dir}/* ${hfc_user_and_data_server}:${lesia08_root}/${bass2000_test_directory_image}/20${year}/
scp -v ${quicklook_tycho_dir}/* ${hfc_user_and_data_server}:${lesia08_root}/${bass2000_test_directory_image}/20${year}/
endif

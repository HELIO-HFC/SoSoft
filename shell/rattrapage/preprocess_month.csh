#! /bin/tcsh -f


# retreive observation files
#alias module 'eval `/usr/bin/modulecmd tcsh \!*`'
#module load idl
#runssw

set year=${2}
set month=${1}


set askdate="20${year}${month}01"
#set name="helio-bass2000"
#set tusaisquoi="ke3afjoha7"
#set serveur="ftpbass2000.obspm.fr"

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

printf "${hfc_user_and_data_server}:${lesia08_root}${fits_directory}/${year}${month}/${fits_name}"

if ($askdate > $last_ha_day) then
	scp -v ${hfc_user_and_data_server}:${lesia08_root}${fits_directory}/${year}${month}/spectro_obspm_ha_20${year}${month}\?\?_\?\?\?\?\?\?\*fits\* $fits_tycho_dir
	#gunzip ${fits_tycho_dir}/spectro_obspm_ha_20${year}${month}\?\?_\?\?\?\?\?\?\*fits\*
	gunzip ${fits_tycho_dir}/spectro_obspm_ha_20${year}${month}*fits*
	#ls ${fits_tycho_dir}/spectro_obspm_ha_20${year}${month}\?\?_\?\?\?\?\?\?\*fits\*
	#ls ${fits_tycho_dir}/spectro_obspm_ha_20${year}${month}*fits*
else
	scp -v ${hfc_user_and_data_server}:${lesia08_root}${fits_directory}/${year}${month}/mh${year}${month}\?\?.\?\?\?\?\?\?\*fits\* $fits_tycho_dir
endif

#ftp -niv <<%
#open ${serveur}
#user ${name} ${tusaisquoi}
#passive
#binary
#cd ${fits_directory}/${year}${month}/
#mget ${fits_name}
#close
#%

#printf ${fits_tycho_dir}/${fits_name}
#gunzip ${fits_tycho_dir}/${fits_name}
#cd ${fits_tycho_dir}

#idl -rt='${path_to_sosoft}/CLEANING/sosoft_pp_procedure.sav'

#cd ${prepros_tycho_dir}

#ftp -niv <<%
#open ${serveur}
#user ${name} ${tusaisquoi}
#passive
#binary
#cd ${bass2000_test_directory_image}/20${year}/
#mput *
#close
#%

#cd ${quicklook_tycho_dir}

#ftp -niv <<%
#open ${serveur}
#user ${name} ${tusaisquoi}
#passive
#binary
#cd ${bass2000_test_directory_image}/20${year}/
#mput *.png
#close
#%

#rm ${fits_tycho_dir}/*
#rm ${prepros_tycho_dir}/*
#rm ${quicklook_tycho_dir}/*

#! /bin/tcsh -f

# retreive observation files
#source /obs/helio/env_python3/bin/activate.csh
#python3 /obs/helio/hfc_git/sosopro/python/getMeudonFITS.py -w P -d /data/helio/hfc/frc/sosopro/data/ori/
#deactivate
alias module 'eval `/usr/bin/modulecmd tcsh \!*`'
module load idl
runssw

set fits_tycho_dir="/poubelle/romagnan/FITS/"
set prepros_tycho_dir="/poubelle/romagnan/FITS_PROCESSED/"
set quicklook_tycho_dir="/poubelle/romagnan/quicklook/"
set spectrocam_filename="spectro_obspm_ha*fits*"
set halpha_filename="mh??????.??????.fits.?"
set hha_preprocessed_filename="spectro_obspm"
set year=${2}
set month=${1}
set spectrocam_directory="ftp/pub/meudon/spc/Ha/"
set halpha_directory="ftp/pub/meudon/Halpha/"
set bass2000_test_directory_image="ftp/pub/helio/hfc/test/frc/sosoft/images/full/meudon/Halpha/"
set bass2000_test_directory_result="ftp/pub/helio/hfc/test/frc/sosoft/result"
set first_spectrocam_day="20170615"
set last_ha_day="20170619"
set askdate="20${year}${month}01"

set name="helio-bass2000"
set tusaisquoi="ke3afjoha7"
set serveur="ftpbass2000.obspm.fr"

printf "\n"
printf $askdate
printf "\n"

if ($askdate > $last_ha_day) then
	printf "Spectrocam data"
	set fits_name="$spectrocam_filename"
	set fits_directory="$spectrocam_directory"
else
	printf "Halpha data"
	set fits_name="$halpha_filename"
	set fits_directory="$halpha_directory"
endif

cd ${prepros_tycho_dir}

ftp -niv <<%
open ftpbass2000.obspm.fr
user helio-bass2000 ke3afjoha7
passive
binary
cd ${bass2000_test_directory_image}/20${year}/
mput *
close
%

cd ${quicklook_tycho_dir}

ftp -niv <<%
open ftpbass2000.obspm.fr
user helio-bass2000 ke3afjoha7
passive
binary
cd ${bass2000_test_directory_image}/20${year}/
mput *.png
close
%

#rm ${fits_tycho_dir}/*
#rm ${prepros_tycho_dir}/*
#rm ${quicklook_tycho_dir}/*
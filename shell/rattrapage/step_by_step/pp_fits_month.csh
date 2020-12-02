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
#set year=${2}
#set month=${1}
set spectrocam_directory="ftp/pub/meudon/spc/Ha/"
set halpha_directory="ftp/pub/meudon/Halpha/"
set bass2000_test_directory_image="ftp/pub/helio/hfc/test/frc/sosoft/images/full/meudon/Halpha/"
set bass2000_test_directory_result="ftp/pub/helio/hfc/test/frc/sosoft/result"
set first_spectrocam_day="20170615"
#set last_ha_day="20170619"
#set askdate="20${year}${month}01"

idl -rt='/obs/romagnan/CLEANING/sosoft_pp_procedure.sav'

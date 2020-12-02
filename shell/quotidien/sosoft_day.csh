#! /bin/tcsh -f

# retreive observation files
#source /obs/helio/env_python3/bin/activate.csh
#python3 /obs/helio/hfc_git/sosopro/python/getMeudonFITS.py -w P -d /data/helio/hfc/frc/sosopro/data/ori/
#deactivate
alias module 'eval `/usr/bin/modulecmd tcsh \!*`'
module load idl
runssw

set year=${3}
set month=${2}
set day=${1}

set fits_tycho_dir="/poubelle/romagnan/FITS/"
set prepros_tycho_dir="/poubelle/romagnan/FITS_preprocessed/"
set quicklook_tycho_dir="/poubelle/romagnan/quicklook/"
set hha_filename="spectro_obspm_ha_20${year}${month}${day}_??????*fits*"
set hha_preprocessed_filename="spectro_obspm_ha_20${year}${month}${day}_??????_subtract_processed.fits"
set csv_tycho_dir="/poubelle/romagnan/CSV/"

rm ${fits_tycho_dir}*
rm ${prepros_tycho_dir}/*
rm ${quicklook_tycho_dir}/*
rm ${csv_tycho_dir}/*

printf "Get Preprocessed file"
printf "${hha_preprocessed_filename}"

ftp -niv <<%
open ftpbass2000.obspm.fr
user helio-bass2000 ke3afjoha7
passive
binary
cd ftp/pub/helio/hfc/test/frc/sosoft/images/full/meudon/Halpha/20${year}/
mget ${hha_preprocessed_filename}
close
%

mv ${hha_preprocessed_filename} ${prepros_tycho_dir}
gunzip ${prepros_tycho_dir}${hha_preprocessed_filename}
cd ${prepros_tycho_dir}

printf "Filament detection"

#idl -rt='/obs/romagnan/CLEANING/sosoft_pp_procedure.sav'

cd ${prepros_tycho_dir}


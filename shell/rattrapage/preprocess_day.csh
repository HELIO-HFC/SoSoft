#! /bin/tcsh -f

# retreive observation files
#source /obs/helio/env_python3/bin/activate.csh
#python3 /obs/helio/hfc_git/sosopro/python/getMeudonFITS.py -w P -d /data/helio/hfc/frc/sosopro/data/ori/
#deactivate
alias module 'eval `/usr/bin/modulecmd tcsh \!*`'
module load idl
runssw

set fits_tycho_dir='/poubelle/romagnan/FITS/'
set prepros_tycho_dir='/poubelle/romagnan/FITS_PROCESSED/'
set year=${3}
set month=${2}
set day=${1}
set hha_filename='spectro_obspm_ha_20190701_??????*.*'

ftp -niv <<%
open ftpbass2000.obspm.fr
user ftp
passive
binary
cd pub/meudon/spc/Ha/${year}${month}/
mget ${hha_filename}
close
%

mv ${hha_filename} ${fits_tycho_dir}

gunzip ${fits_tycho_dir}${hha_filename}

cd ${fits_tycho_dir}

idl -rt='/obs/romagnan/CLEANING/sosoft_pp_procedure.sav'

ftp -niv <<%
open ftpbass2000.obspm.fr
user helio-bass2000 ke3afjoha7
passive
binary
cd ftp/pub/helio/hfc/test/frc/sosoft/images/full/meudon/Halpha/
mput ${hha_filename}
close
%


#! /bin/tcsh -f


# retreive observation files
alias module 'eval `/usr/bin/modulecmd tcsh \!*`'
module load idl
runssw

set year=${2}
set month=${1}

setenv askdate="20${year}${month}01"
set name="helio-bass2000"
set tusaisquoi="ke3afjoha7"
set serveur="ftpbass2000.obspm.fr"

printf "\n"
printf $askdate
printf "\n"

if ($askdate > $last_ha_day) then
	printf "Spectrocam data"
	set fits_name="$spectrocam_filename"
	set fits_directory="$bass2000_spectrocam_directory"
else
	printf "Halpha data"
	set fits_name="$halpha_filename"
	set fits_directory="$bass2000_halpha_directory"
endif

printf "\n"
printf "$fits_name"
printf "\n"
printf "$fits_directory"
printf "\n"

ftp -niv <<%
open ${serveur}
user ${name} ${tusaisquoi}
passive
binary
cd ${fits_directory}/${year}${month}/
mget ${fits_name}
close
%

mv ${fits_name} ${fits_tycho_dir}
gunzip ${fits_tycho_dir}${fits_name}
cd ${fits_tycho_dir}

idl -rt='/obs/romagnan/CLEANING/sosoft_pp_procedure.sav'

cd ${prepros_tycho_dir}

ftp -niv <<%
open ${serveur}
user ${name} ${tusaisquoi}
passive
binary
cd ${bass2000_test_directory_image}/20${year}/
mput *
close
%

cd ${quicklook_tycho_dir}

ftp -niv <<%
open ${serveur}
user ${name} ${tusaisquoi}
passive
binary
cd ${bass2000_test_directory_image}/20${year}/
mput *.png
close
%

rm ${fits_tycho_dir}/*
rm ${prepros_tycho_dir}/*
rm ${quicklook_tycho_dir}/*

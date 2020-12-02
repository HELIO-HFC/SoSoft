#!/bin/tcsh -f

# retreive observation files
#source /obs/helio/env_python3/bin/activate.csh
#python3 /obs/helio/hfc_git/sosopro/python/getMeudonFITS.py -w P -d /data/helio/hfc/frc/sosopro/data/ori/
#deactivate
alias module 'eval `/usr/bin/modulecmd tcsh \!*`'
module load idl
runssw
# launch preprocessing
sswidl -rt='/obs/romagnan/CLEANING/sosoft_pp_procedure.sav'
# launch filament detection
#sswidl -rt='/obs/helio/hfc_git/sosopro/PRO/efr_pro2ascii.sav'

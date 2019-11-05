# to make the new R version the default, type vim ~/.bashrc and paste 
#the folowing lines
Rpath=/mnt/work/software/R/R-3.6.1/bin/
if [ "${Rpath}" != "" ] ; then export PATH=${Rpath}:$PATH ; fi
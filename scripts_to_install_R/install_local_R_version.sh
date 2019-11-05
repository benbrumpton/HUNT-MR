# path where you download and compile R
PathToDownlad=/home/ojbekkev

# path where R will be install
PathToInstallR=/mnt/work/software/R/R-3.6.1

cd $PathToDownlad

#download lastest R:
wget https://cran.r-project.org/src/base/R-3/R-3.6.1.tar.gz

# extract
tar xvzf R-3.6.1.tar.gz
cd R-3.6.1

# install tcl and tk
sudo apt update
sudo apt install tcl-dev tk-dev

# could be that more packages have to be installed to compile properly

# configure R
./configure --with-x=no --prefix=${PathToInstallR} --enable-memory-profiling --enable-R-shlib --with-blas --with-lapack --enable-shared --with-tcltk --with-tcl-config=/usr/lib/tclConfig.sh --with-tk-config=/usr/lib/tkConfig.sh --with-libtiff --with-libpng --with-jpeglib

# compile
make

# install R in path specified by PathToInstallR variable
sudo make install
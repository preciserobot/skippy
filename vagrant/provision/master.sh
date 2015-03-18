INSTALL_TARGET=${1}  # /usr/local/pipeline
PATH_FILE=${2}  # /home/vagrant/.bashrc

if [ -f '/home/vagrant/.provisioned_master' ]; then
  echo '[PROVISIONING] Already provisioned molpipe...'
  exit 0
fi

# INSTALL PATH SETUP
sudo mkdir -p $INSTALL_TARGET
sudo chmod 777 $INSTALL_TARGET
sed -i '$aINSTALL_TARGET=${INSTALL_TARGET}' $PATH_FILE
sed -i '$aPATH_FILE=${PATH_FILE}' $PATH_FILE


echo '[PROVISIONING] Installing GraphViz...'
sudo apt-get -y install graphviz

echo '[PROVISIONING] Installing python modules...'
sudo pip install pytabix
sudo pip install XlsxWriter
sudo pip install pysam
sudo pip install Cython
sudo pip install ruffus
sudo pip install python-dateutil
sudo pip install drmaa
sudo pip install numpy


echo '[PROVISIONING] Installing R/r/Bioconductor...'
sudo apt-get -y install r-base r-base-dev
sudo apt-get -y install littler
### insert bioconductor install scripts here

echo '[PROVISIONING] Installing other software...'
## bamUtil
wget --no-verbose -O /tmp/BamUtilLibStatGen.1.0.12.tar.gz http://genome.sph.umich.edu/w/images/5/5e/BamUtilLibStatGen.1.0.12.tar.gz \
  && tar xvfz /tmp/BamUtilLibStatGen.1.0.12.tar.gz -C $INSTALL_TARGET \
  && cd $INSTALL_TARGET/bamUtil_1.0.12 && make all && cd \
  && sed  -i '$aPATH=$PATH:'$INSTALL_TARGET'/bamUtil_1.0.12/bamUtil/bin/' $PATH_FILE

## bwa
wget --no-verbose -O /tmp/bwa-0.7.10.tar.bz2 http://sourceforge.net/projects/bio-bwa/files/bwa-0.7.10.tar.bz2 \
  && tar xjvf /tmp/bwa-0.7.10.tar.bz2 -C $INSTALL_TARGET/ \
  && cd $INSTALL_TARGET/bwa-0.7.10 && make && cd \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/bwa-0.7.10' $PATH_FILE

## stampy (registration required, get compressed file and put in context dir for the build)
wget --no-verbose -O /tmp/stampy-latest.tgz  http://www.well.ox.ac.uk/~gerton/software/Stampy/stampy-latest.tgz \
  && tar xvf /tmp/stampy-latest.tgz -C $INSTALL_TARGET/ \
  && sed -i 's/-Wl//' $INSTALL_TARGET/stampy-1.0.23/makefile \
  && chmod -R 755 $INSTALL_TARGET/stampy-1.0.23 \
  && cd $INSTALL_TARGET/stampy-1.0.23 && make && cd \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/stampy-1.0.23' $PATH_FILE

## VCFtools: http://vcftools.sourceforge.net/index.html
wget --no-verbose -O /tmp/vcftools_0.1.12a.tar.gz http://sourceforge.net/projects/vcftools/files/vcftools_0.1.12a.tar.gz/download \
  && tar xzvf /tmp/vcftools_0.1.12a.tar.gz -C $INSTALL_TARGET/  \
  && cd $INSTALL_TARGET/vcftools_0.1.12a/ && make && cd \
  && sed  -i '$aPATH=$PATH:'$INSTALL_TARGET'/vcftools_0.1.12a/bin' $PATH_FILE

## Picard
wget --no-verbose -O /tmp/picard-tools-1.115.zip http://sourceforge.net/projects/picard/files/picard-tools/1.115/picard-tools-1.115.zip \
  && mkdir $INSTALL_TARGET/picardtools \
  && unzip /tmp/picard-tools-1.115.zip -d $INSTALL_TARGET/picardtools/ \
  && sed -i '$aCLASSPATH=.:$CLASSPATH:'$INSTALL_TARGET'/picardtools/picard-tools-1.115/snappy-java-1.0.3-rc3.jar' $PATH_FILE \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/picardtools/picard-tools-1.115' $PATH_FILE

## htslib
cd $INSTALL_TARGET \
  && git clone --branch=develop git://github.com/samtools/htslib.git \
  && cd $INSTALL_TARGET/htslib && git checkout f3e1602196bbf03f426dfb363a4841932a042194 \
  && make && sudo make install && cd \
  && sed  -i '$aPATH=$PATH:'$INSTALL_TARGET'/htslib' $PATH_FILE

## bcftools
cd $INSTALL_TARGET \
  && git clone --branch=develop git://github.com/samtools/bcftools.git \
  && cd $INSTALL_TARGET/bcftools && git checkout 8e008d84d66e076d7827480af2afa85aaa467d32 \
  && make && cd $INSTALL_TARGET \
  && chmod 755 $INSTALL_TARGET/bcftools/bcftools \
  && sed  -i '$aPATH=$PATH:'$INSTALL_TARGET'/bcftools' $PATH_FILE

## samtools1 (needs ncurses header files)
cd $INSTALL_TARGET \
  && git clone --branch=develop git://github.com/samtools/samtools.git \
  && cd $INSTALL_TARGET/samtools && git checkout c06f698c1b98d10e8619f967fc94e07077a40644 \
  && make && cd \
  && sed  -i '$aPATH=$PATH:'$INSTALL_TARGET'/samtools' $PATH_FILE

# bamtools
cd $INSTALL_TARGET \
  && git clone https://github.com/pezmaster31/bamtools.git \
  && cd $INSTALL_TARGET/bamtools && git checkout 2d7685d2aeedd11c46ad3bd67886d9ed65c30f3e \
  && mkdir build && cd build && cmake .. && make && cd \
  && sed  -i '$aPATH=$PATH:'$INSTALL_TARGET'/bamtools/bin' $PATH_FILE

## BEDtools2 2.22.0 (2.22.1 has a problem with haplotypes)
cd $INSTALL_TARGET \
  && git clone https://github.com/arq5x/bedtools2.git \
  && cd $INSTALL_TARGET/bedtools2 && git checkout 85f5a100a99a1527374f5a8702c0917093000f21 \
  && make clean && make all && cd \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/bedtools2/bin' $PATH_FILE

## KentSrc utilities (they are BIG)
cd $INSTALL_TARGET \
  && git clone https://github.com/ENCODE-DCC/kentUtils.git \
  && cd $INSTALL_TARGET/kentUtils && git checkout d8376c5d52a161f2267346ed3dc94b5dce74c2f9 \
  && make && cd \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/kentUtils/bin' $PATH_FILE

## freebayes
cd $INSTALL_TARGET \
  && git clone --recursive https://github.com/ekg/freebayes.git \
  && cd $INSTALL_TARGET/freebayes && git checkout fef284a1af7afd293752aaf4ef4b7c3ccbd858e4 \
  && make && cd \
  && chmod -R 755 $INSTALL_TARGET/freebayes \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/freebayes/bin' $PATH_FILE

## Platypus (0.7.9.5)
cd $INSTALL_TARGET \
  && git clone --recursive https://github.com/andyrimmer/Platypus.git \
  && cd $INSTALL_TARGET/Platypus && git checkout a5472b35ddc4d325e7001ef30f47dcc0c5b98314 \
  && make && cd \
  && chmod -R 755 $INSTALL_TARGET/Platypus/bin \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/Platypus/bin' $PATH_FILE

## VCFlib
cd $INSTALL_TARGET \
  && git clone --recursive https://github.com/ekg/vcflib.git
  && cd $INSTALL_TARGET/vcflib && git checkout b1dfd7a73140f9b12cb8fd2a554d70188ff05cca \
  && make && cd \
  && chmod -R 755 $INSTALL_TARGET/vcflib/bin \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/vcflib/bin' $PATH_FILE

## metagenomics (kraken)
cd /tmp \
  && git clone --recursive https://github.com/DerrickWood/kraken.git \
  && cd /tmp/kraken && git checkout 11a205fdff0f30bb5fdfd006be3211571b89ff22 \
  && sh install_kraken.sh $INSTALL_TARGET/kraken \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/kraken' $PATH_FILE

# delly (clone takes ages, tons of submodule dependencies)
cd $INSTALL_TARGET \
  && git clone --recursive https://github.com/tobiasrausch/delly.git
  && cd $INSTALL_TARGET/delly && git checkout a0f560d9610b9fae93e334f1d28b567968b6b9f2 \
  && make all && cd \
  && chmod -R 755 $INSTALL_TARGET/delly/src/delly \
  && sed -i '$aPATH=$PATH:'$INSTALL_TARGET'/delly/src' $PATH_FILE


# set provisioning checkpoint
touch /home/vagrant/.provisioned_master

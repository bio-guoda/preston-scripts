#!/bin/bash
#
#  package-preston.sh : Generates Zenodo-friendly publication for Preston observatory. 
#
#  Assumes that "preston" cli is available in path and that a data/ folder
#  is present in the current working directory.
#
#  Please replace variables to match network publication, or provide
#  a package-preston.config with default overrides. See package-preston.config.template 
#  for ... a template.
set -xe

## replace start ##
NETWORK_NAME=DataONE
PRESTON_NETWORK_SEED="https://dataone.org"
NETWORK_CITATION="${NETWORK_NAME}, https://www.dataone.org"
NETWORK_LONGNAME="Data Observation Network for Earth (${NETWORK_NAME}, [1])"
PRESTON_REMOTE_URL=https://zenodo.org/record/3277312/files
## replace end ##


if [ -f package-preston.config ]; then 
  source package-preston.config 
fi

DATE_RANGE_START=$(preston ls -l tsv | grep "prov#generatedAtTime" | cut -f3 | head -n1 | xargs -I {} date --iso-8601 -d {})
DATE_RANGE_END=$(preston ls -l tsv | grep "prov#generatedAtTime" | cut -f3 | tail -n1 | xargs -I {} date --iso-8601 -d {})

PRESTON_HISTORY=$(preston history) 

PRESTON_VERIFY_HEAD=$(preston verify | head -n4) 

PRESTON_VERSION=$(preston version)

mkdir -p $PWD/tmp/provindex
mkdir -p $PWD/tmp/prov
TMPDIR=$(mktemp -d -p $PWD/tmp)
cp $(which preston) $TMPDIR/preston.jar
preston cp --type provindex $TMPDIR/provindex

PRESTON_PROV_INDEX=$(ls -1 $TMPDIR/provindex)

preston cp --type prov $TMPDIR/prov

PRESTON_PROV=$(ls -1 $TMPDIR/prov)

envsubst >$TMPDIR/README <<EOF
A biodiversity dataset graph: ${NETWORK_NAME}

The intended use of this archive is to facilitate meta-analysis of the ${NETWORK_LONGNAME}. ${NETWORK_NAME} is a distributed infrastructure that provides information about earth observation data. 

This dataset provides versioned snapshots of the DataONE network as tracked by Preston [2] between ${DATE_RANGE_START} and ${DATE_RANGE_END}.  

The archive consists of 256 individual parts (e.g., preston-00.tar.gz, preston-01.tar.gz, ...) to allow for parallel file downloads. The archive contains three types of files: index files, provenance files and data files. Only two index and provenance files are included and have been individually included in this dataset publication. Index files provide a way to links provenance files in time to eestablish a versioning mechanism. Provenance files describe how, when and where the ${NETWORK_NAME} meta-data files were retrieved. For more information, please visit https://preston.guoda.bio or https://doi.org/10.5281/zenodo.1410543).  

To retrieve and verify the downloaded ${NETWORK_NAME} biodiversity dataset graph, first concatenate all the downloaded preston-*.tar.gz files (e.g., cat preston-*.tar.gz > preston.tar.gz). Then, extract the archives into a "data" folder. Alternatively, you can use the preston[2] command-line tool to "clone" this dataset using:

$ java -jar preston.jar clone --remote ${PRESTON_REMOTE_URL}

After that, verify the index of the archive by reproducing the following result:

$ java -jar preston.jar history
${PRESTON_HISTORY}

To check the integrity of the extracted archive, confirm that each line produce by the command "preston verify" produces lines as shown below, with each line including "CONTENT_PRESENT_VALID_HASH". Depending on hardware capacity, this may take a while.

$ java -jar preston.jar verify
${PRESTON_VERIFY_HEAD}

Note that a copy of the java program "preston", preston.jar, is included in this publication. The program runs on java 8+ virtual machine using "java -jar preston.jar", or in short "preston". 

Files in this data publication:


-- this file --
README 

-- executable java jar containing preston[2] v${PRESTON_VERSION}. --
preston.jar

-- preston archives containing DataONE meta-data files, their provenance and a provenance index --
preston-[00-ff].tar.gz 

-- individual provenance index files --
${PRESTON_PROV_INDEX}

-- individual provenance logs --
${PRESTON_PROV}

--- end of files ---

[1] ${NETWORK_CITATION}
[2] https://preston.guoda.bio, https://doi.org/10.5281/zenodo.1410543 . DataONE was crawled via Preston with "preston update -u ${PRESTON_NETWORK_SEED}".

This work is funded in part by grant NSF OAC 1839201 from the National Science Foundation
EOF

mv $TMPDIR/provindex/* $TMPDIR
mv $TMPDIR/prov/* $TMPDIR

mkdir -p $TMPDIR/old-tars
mv data/*.tar.gz $TMPDIR/old-tars

echo packaging tar.gz files...
ls -1 data/ | grep -P "^[0-9a-f]{2}$" | xargs -I {} sh -c "cd data && tar cvz {} > preston-{}.tar.gz"

mv data/preston*.tar.gz $TMPDIR
mv $TMPDIR/old-tars/* data/
rm -rf $TMPDIR/old-tars 
rm -rf $TMPDIR/prov
rm -rf $TMPDIR/provindex

ls -1 $TMPDIR

echo Zenodo-friendly Preston pub available in [$TMPDIR]

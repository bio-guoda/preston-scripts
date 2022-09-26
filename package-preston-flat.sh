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
NETWORK_LONGNAME="Data Observation Network for Earth"
NETWORK_DESCRIPTION="${NETWORK_NAME} is a distributed infrastructure that provides information about earth observation data."
PRESTON_REMOTE_URL=https://zenodo.org/record/3277312/files
## replace end ##


if [ -f package-preston.config ]; then 
  source package-preston.config 
fi

DATE_RANGE_START=$(preston history -l tsv | tr '\t' '\n' | grep hash | head -n1  | xargs preston cat | grep "prov#generatedAtTime" | tail -n1 | cut -d ' ' -f3 | cut -d '^' -f1 | xargs -I {} date --iso-8601 -d {})
DATE_RANGE_END=$(preston history -l tsv | tr '\t' '\n' | grep hash | xargs preston cat | grep "prov#generatedAtTime" | tail -n1 | cut -d ' ' -f3 | cut -d '^' -f1 | xargs -I {} date --iso-8601 -d {})
LAST_PROVENANCE_VERSION=$(preston history -l tsv | tr '\t' '\n' | grep "hash:" | tail -n2 | head -n1)
PRESTON_HISTORY=$(preston history --log tsv) 

PRESTON_VERIFY_HEAD="replace wwith preston verify | head -n4"

PRESTON_VERSION=$(preston version)

mkdir -p $PWD/tmp/provindex
TMPDIR=$(mktemp -d -p $PWD/tmp)
cp $(which preston) $TMPDIR/preston.jar
preston cp -p directoryDepth0 $TMPDIR/data

PRESTON_FILE_LIST=$(ls -1 $TMPDIR/data)

mv $TMPDIR/data/* $TMPDIR

envsubst >$TMPDIR/README <<EOF
A biodiversity dataset graph: ${NETWORK_NAME}

The intended use of this archive is to facilitate (meta-)analysis of the ${NETWORK_LONGNAME} (${NETWORK_NAME}). ${NETWORK_DESCRIPTION} 

This dataset provides versioned snapshots of the ${NETWORK_NAME} network as tracked by Preston [2,3] between ${DATE_RANGE_START} and ${DATE_RANGE_END} using "preston update -u ${PRESTON_NETWORK_SEED}". 

The archive consists of individual files with hexadecimal filenames (e.g., $(echo ${PRESTON_FILE_LIST} | tr ' ' '\n' | head -n1)) to allow for parallel file downloads. The archive contains three types of files: index files, provenance logs and data files. Index files provide a way to links provenance files in time to establish a versioning mechanism. Provenance files describe how, when, what and where the ${NETWORK_NAME} content was retrieved. For more information, please visit https://preston.guoda.bio or https://doi.org/10.5281/zenodo.1410543 .  

To retrieve and verify the downloaded ${NETWORK_NAME} biodiversity dataset graph, download all files. Then, extract the archives into a "data" folder. Alternatively, you can use the preston[2] command-line tool to "clone" this dataset using:

$ java -jar preston.jar clone --remote ${PRESTON_REMOTE_URL}

After that, verify the index of the archive by reproducing the following provenance log history:

$ java -jar preston.jar history --log tsv
${PRESTON_HISTORY}

To check the integrity of the extracted archive, confirm that each line produce by the command "preston verify" produces lines as shown below, with each line including "CONTENT_PRESENT_VALID_HASH". Depending on hardware capacity, this may take a while.

$ java -jar preston.jar verify
${PRESTON_VERIFY_HEAD}

Note that a copy of the java program "preston", preston.jar, is included in this publication. The program runs on java 8+ virtual machine using "java -jar preston.jar", or in short "preston". 

Files in this data publication:

--- start of file descriptions ---

-- description of archive and its contents (this file) --
README 

-- executable java jar containing preston [2,3] v${PRESTON_VERSION}. --
preston.jar

-- preston archives containing ${NETWORK_NAME} data files, associated provenance logs and a provenance index --
${PRESTON_FILE_LIST} 

--- end of file descriptions ---


References 

[1] ${NETWORK_LONGNAME} (${NETWORK_NAME}, ${PRESTON_NETWORK_SEED}) accessed from ${DATE_RANGE_START} to ${DATE_RANGE_END} with provenance ${LAST_PROVENANCE_VERSION}.
[2] https://preston.guoda.bio, https://doi.org/10.5281/zenodo.1410543 . 
[3] MJ Elliott, JH Poelen, JAB Fortes (2020). Toward Reliable Biodiversity Dataset References. Ecological Informatics. https://doi.org/10.1016/j.ecoinf.2020.101132


This work is funded in part by grant NSF OAC 1839201 and NSF DBI 2102006 from the National Science Foundation.
EOF

echo Zenodo-friendly Preston pub available in [$TMPDIR]

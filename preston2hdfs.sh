#!/bin/bash
#
# Imports a preston observatory (i.e., history, data and provenance) 
# using preston remotes (e.g., https://deeplinker.bio/) 
# into HDFS targets data and provenance targets 
# (e.g., hdfs://guoda/data/source=preston/data (for data) 
# and hdfs://guoda/data/source=preston/prov (for data provenance)).
#
# For more information see https://preston.guoda.bio/
#

set -xe

PRESTON_VERSION=0.0.15
#PRESTON_REMOTE=https://deeplinker.bio
PRESTON_REMOTE=https://raw.githubusercontent.com/bio-guoda/preston-amazon/master/data

#HDFS_TARGET=/user/$USER/guoda/data/source=preston-bhl
HDFS_TARGET=/user/$USER/guoda/data/source=preston-amazon

# A Preston history remote keeps a version history of a Preston data observatory
# The version history can be retrieved using method described at 
# https://github.com/bio-guoda/preston/blob/master/architecture.md#simplified-hexastore
# The initial version can always be found at [remote url]/2a5de79372318317a382ea9a2cef069780b852b01210ef59e06b640a3539cb5a (e.g., https://deeplinker.bio/2a5de79372318317a382ea9a2cef069780b852b01210ef59e06b640a3539cb5a)
HISTORY_QUERY_HASH=2a5de79372318317a382ea9a2cef069780b852b01210ef59e06b640a3539cb5a
#HISTORY_REMOTE=https://deeplinker.bio
#HISTORY_REMOTE=https://raw.githubusercontent.com/jhpoelen/preston-remotes/master/bhl
HISTORY_REMOTE=https://raw.githubusercontent.com/bio-guoda/preston-amazon/master/data/2a/5d
HISTORY_ROOT=$HISTORY_REMOTE/$HISTORY_QUERY_HASH
HISTORY_PATH=$(echo $HISTORY_QUERY_HASH | awk '{ print "data/" substr($1,1,2) "/" substr($1,3,2) }')

echo preston data remote [$DATA_REMOTE]
echo preston history remote [$HISTORY_REMOTE]
echo hdfs target [$HDFS_TARGET]

WORK_DIR=$(mktemp -u -d -p preston2hdfs.tmp)
mkdir -p $WORK_DIR/$HISTORY_PATH
cd $WORK_DIR

curl $HISTORY_ROOT > $HISTORY_PATH/$HISTORY_QUERY_HASH
wget https://github.com/bio-guoda/preston/releases/download/${PRESTON_VERSION}/preston.jar -O preston.jar

# list available dataset provenance graph, using remote if needed.
java -jar preston.jar history --remote $PRESTON_REMOTE/ --log tsv --no-cache | tr '\t' '\n' | grep "hash:\/\/sha256" | sort | uniq > prov_hashes.tsv

java -jar preston.jar ls --remote $PRESTON_REMOTE/ --log tsv --no-cache | tr '\t' '\n' | grep "hash:\/\/sha256" | sort | uniq > data_hashes.tsv

hdfs dfs -mkdir -p $HDFS_TARGET/prov
hdfs dfs -mkdir -p $HDFS_TARGET/data

# generate scripts to push preston tracked content into hdfs without local caching 
append_upload_script() {
  cat $1 | awk -v DIR_NAME=$2 -v PRESTON_REMOTE=$PRESTON_REMOTE/ -v HDFS_TARGET=$HDFS_TARGET '{ print "echo " $1 " | java -jar preston.jar get --remote " PRESTON_REMOTE " --no-cache | hdfs dfs -put -p - " HDFS_TARGET "/" DIR_NAME "/" substr($1, 15, 2) "/" substr($1, 17, 2) "/" substr($1, 15, 65) }' >> upload.sh
}

echo "# upload script generated by $0" > upload.sh
append_upload_script data_hashes.tsv data 
append_upload_script prov_hashes.tsv prov

split upload.sh -nl/3 --additional-suffix=.sh -d upload
nohup bash upload00.sh &> upload00.log &
nohup bash upload01.sh &> upload01.log &
nohup bash upload02.sh &> upload02.log &


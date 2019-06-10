#!/bin/bash
#
# Imports Preston data from https://deeplinker.bio into HDFS at hdfs://guoda/data/source=preston/data (for data) and hdfs://guoda/data/source=preston/prov (for data provenance).
#
# 
#

set -x

PRESTON_VERSION=0.0.14
#PRESTON_REMOTE=https://deeplinker.bio
PRESTON_REMOTE=https://raw.githubusercontent.com/bio-guoda/preston-amazon/master/data/
HDFS_TARGET=/guoda/data/source=preston-amazon
HDFS_TARGET_ESCAPED=$(echo $HDFS_TARGET | sed -e 's/\//\\\//g')
WORK_DIR=preston2hdfs.tmp

mkdir -p $WORK_DIR
cd $WORK_DIR

wget https://github.com/bio-guoda/preston/releases/download/${PRESTON_VERSION}/preston.jar -O preston.jar

# list available dataset provenance graph, using remote if needed.
java -jar preston.jar ls --remote $PRESTON_REMOTE > /dev/null

# verify existence and integrity of tracked content of biodiversity data graphs hosted by remote
# expected outcome is a list of all tracked content with status "missing", because the content is not expected two be local.
java -jar preston.jar verify --remote $PRESTON_REMOTE > verify.tsv

hdfs dfs -mkdir -p $HDFS_TARGET/prov
hdfs dfs -mkdir -p $HDFS_TARGET/data

# copy preston provenance to prov directory
hdfs dfs -copyFromLocal -f data/ $HDFS_TARGET/prov

# gather all preston tracked content
cat verify.tsv | sort | uniq > verify_sorted.tsv
cat verify_sorted.tsv | grep "http[s]*:\/\/" > verify_sort_remote.tsv
cat verify_sorted.tsv | grep "file:\/" > verify_sort_local.tsv
join verify_sort_remote.tsv verify_sort_local.tsv > verify_sort_remote_local.tsv 


# generate scripts to push preston tracked content into hdfs
cat verify_sort_remote_local.tsv | cut -d ' ' -f2,6 | sed -e "s/file:\/.*\/data\//| hdfs dfs -put -p - $HDFS_TARGET_ESCAPED\/data\//g" | sed -e "s/https/curl --fail -L https/g" > upload.sh
split upload.sh -n3 --additional-suffix=.sh -d upload
nohup bash upload00.sh &> upload00.log &
nohup bash upload01.sh &> upload01.log &
nohup bash upload02.sh &> upload02.log &

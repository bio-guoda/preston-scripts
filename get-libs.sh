#!/bin/bash
#
# gets dependencies if none exist yet
#

PRESTON_VERSION=0.1.2
PRESTON_JAR=lib/preston.jar

IDIGBIO_SPARK_JAR=lib/idigbio-spark.jar

mkdir -p lib

[ -f $IDIGBIO_SPARK_JAR ] || wget https://github.com/bio-guoda/idigbio-spark/releases/download/0.0.1/iDigBio-LD-assembly-1.5.9.jar -O $IDIGBIO_SPARK_JAR
[ -f $PRESTON_JAR ] || wget https://github.com/bio-guoda/preston/releases/download/${PRESTON_VERSION}/preston.jar -O $PRESTON_JAR
 

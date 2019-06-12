# preston-scripts
import and conversion scripts related to Preston data. The scripts are intended to provide examples on how to use [Preston](https://github.com/bio-guoda/preston) in combination with GUODA's cluster (e.g., HDFS, Apache Spark, Mesos).


## HDFS Import

Hadoop File System (HDFS) is a well-used distributed filesystem designed for parllel processing. Initially designed for hadoop map-reduce, it is now also used with processing engines like [Apache Spark](https://spark.apache.org). 

[preston2hdfs.sh](./preston2hdfs.sh) is a script to help migrate a Preston instance into HDFS. This is work in progress, so please be read the script before you use it.

to use:

0. start a terminal via https://jupyter.idigbio.org 
1. clone this repository ```git clone https://github.com/bio-guoda/preston-scripts```
2. ```cd preston-scripts```
3. inspect ```./preston2hdfs.sh``` and change settings when needed.
4. by default, the preston2hdfs.sh script uses an example Preston instance, https://github.com/bio-guoda/preston-amazon , as a Preston remote and HDFS target ```/guoda/data/source=preston-amazon/```. 
5. run ```./preston2hdfs.sh``` to migrate the Preston remote to the specified HDFS target. 
6. inspect the target HDFS target and the work directory ```preston2hdfs.tmp``` for results.  

## Preston to DwC-A using Spark Job Dispatcher

Now that Preston data has been moved into HDFS, we can use [idigbio-spark](https://github.com/bio-guoda/idigbio-spark) to convert DwC-A files in the Preston data to formats like Parquet and Sequence file. This can be done using an interactive spark shell, or by using the Spark Job Dispatcher.

### Spark Job Dispatcher

0. repeat step 0-2 of previous recipe
1. type ```hdfs dfs -ls /user/[your username]/guoda/data/source=preston-amazon/```
2. confirm that the ```data``` and ```prov``` folder exists and have sub-directories.
3. inspect [./spark-job-submit.sh](./spark-job-submit.sh) and notice how the script helps to send a http post request to some cluster endpoint.
4. inspect [./spark-job-dwca2parquet.json](./spark-job-dwca2parquet.json) and notice the two path arguments near the top file ```"appArgs" : [ "/guoda/data/source=preston-amazon/data", "/guoda/data/source=preston-amazon/dwca"]``` .
5. before submitting a job to the cluster, inspect the current cluster status using the mesos dashboard at http://mesos02.acis.ufl.edu:5050/#/ where mesos02 is the current main node. If you don't have access to the acis mesos servers, tunnel into acis infrastructure using ssh ```ssh -D8080 someuser@ssh.acis.ufl.edu``` and configure your browser to use a manual proxy configuration with a SOCKS host running on localhost on port 8080 . 
6. after editing the spark-job-dwca2parquet.json to point to your hdfs paths, submit the job using ```./spark-job-submit.sh spark-job-dwca2parquet.json```. 

### Spark Shell

Similar to previous, only instead of using the spark-job-submit.sh script, do the following:

0. start a jupyter terminal https://jupyter.idigbio.org 
1. download the https://s3-us-west-2.amazonaws.com/guoda/idigbio-spark/iDigBio-LD-assembly-1.5.9.jar  
2. start a spark-shell using ```spark-shell --conf spark.sql.caseSensitive=true --jars iDigBio-LD-assembly-1.5.9```
3. now, run the following in the spark-shell
```scala
import bio.guoda.preston.spark.PrestonUtil
implicit val sparky = spark
PrestonUtil.main(Array("hdfs:///guoda/data/source=preston/data", "hdfs:///guoda/data/source=preston/dwca"))
```
replacing the hdfs paths with your desired input and output paths.

Note that your can run the spark-shell locally on your machine also and point the paths at a local file system using file:/// urls. 

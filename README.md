# preston-scripts
Import and conversion scripts related to Preston data. The scripts are intended to provide examples on how to use [Preston](https://github.com/bio-guoda/preston) in combination with GUODA's cluster (e.g., HDFS, Apache Spark, Mesos).


## HDFS Import

Hadoop File System (HDFS) is a well-used distributed filesystem designed for parallel processing. Initially designed for hadoop map-reduce, it is now also used with processing engines like [Apache Spark](https://spark.apache.org). 

[preston2hdfs.sh](./preston2hdfs.sh) is a script to help migrate a Preston instance into HDFS. This is work in progress, so please be read the script before you use it.

To use:

0. Start a terminal via https://jupyter.idigbio.org 
1. Clone this repository ```git clone https://github.com/bio-guoda/preston-scripts```
2. ```cd preston-scripts```
3. Inspect ```./preston2hdfs.sh``` and change settings when needed.
4. By default, the preston2hdfs.sh script uses an example Preston instance, https://github.com/bio-guoda/preston-amazon , as a Preston remote and HDFS target ```/user/[your username]/guoda/data/source=preston-amazon/```. 
5. Run ```./preston2hdfs.sh``` to migrate the Preston remote to the specified HDFS target. 
6. Inspect the target HDFS target and the work directory ```preston2hdfs.tmp``` for results.  

## Preston to DwC-A 

Now that Preston data has been moved into HDFS, we can use [idigbio-spark](https://github.com/bio-guoda/idigbio-spark) to convert DwC-A files in the Preston data to formats like Parquet and Sequence file. This can be done using an interactive spark shell, or by using the Spark Job Dispatcher.

### Preston to DwC-A using Spark Job Dispatcher

0. Repeat step 0-2 of previous recipe
1. Type ```hdfs dfs -ls /user/[your username]/guoda/data/source=preston-amazon/```
2. Confirm that the ```data``` and ```prov``` folder exists and have sub-directories.
3. Inspect [./spark-job-submit.sh](./spark-job-submit.sh) and notice how the script helps to send a http post request to some cluster endpoint running the spark cluster dispatcher at mesos07.acis.ufl.edu on port 7077. This dispatcher is kept alive by Marathon, a mesos framework that manages long running processes. You can access the Marathon dashboard at http://mesos02.acis.ufl.edu:8080/ui/#/apps and inspect the spark dispatcher configuration at http://mesos02.acis.ufl.edu:8080/ui/#/apps/%2Fspark-mesos-cluster-dispatcher/configuration .  Note that Marathon is also responsible for keeping the [effechecka](https://github.com/bio-guoda/effechecka) api up and running.  For more information about submitting spark jobs, see https://spark.apache.org/docs/latest/submitting-applications . For specific examples of Marathon configuration, see https://github.com/bio-guoda/effechecka/blob/master/marathon/guoda-marathon-config.json .  
4. Edit [./spark-job-dwca2parquet.json](./spark-job-dwca2parquet.json). Notice the two path arguments near the top file ```"appArgs" : [ "/guoda/data/source=preston-amazon/data", "/guoda/data/source=preston-amazon/dwca"]``` . They are the source and the target location, respectively. Editing these arguments to point to your hdfs paths.
5. Before submitting a job to the cluster, inspect the current cluster status using the Mesos dashboard at http://mesos02.acis.ufl.edu:5050/#/ where mesos02 is the current main node. If you don't have access to the acis mesos servers, tunnel into acis infrastructure using ssh ```ssh -D8080 someuser@ssh.acis.ufl.edu``` and configure your browser to use a manual proxy configuration with a SOCKS host running on localhost on port 8080 . 
6. Submit the job using ```./spark-job-submit.sh spark-job-dwca2parquet.json```. The job is dispatched, but it has not finished yet.
7. Monitor the progress of the job in the Mesos dashboard.
8. Once the job is done, verify that files have appeared at the target location.

### Preston to DwC-A using Spark Shell

Similar to previous, only instead of using the spark-job-submit.sh script, do the following:

0. start a jupyter terminal https://jupyter.idigbio.org 
1. download the https://s3-us-west-2.amazonaws.com/guoda/idigbio-spark/iDigBio-LD-assembly-1.5.9.jar  
2. start a spark-shell using ```spark-shell --conf spark.sql.caseSensitive=true --jars iDigBio-LD-assembly-1.5.9.jar```
3. now, run the following in the spark-shell
```scala
import bio.guoda.preston.spark.PrestonUtil
implicit val sparky = spark
PrestonUtil.main(Array("hdfs:///guoda/data/source=preston-amazon/data", "hdfs:///guoda/data/source=preston-amazon/dwca"))
```
4. after the job is done, confirm that 
```scala
val data = spark.read.parquet("/guoda/data/source=preston-amazon/dwca/core.parquet") // replace with suitable target directory
data.count
```
results in a non-zero result after replacing the hdfs paths with your desired input and output paths.

Note that your can run the spark-shell locally on your machine also and point the paths at a local file system using file:/// urls.

Also note that similar approach can be taken using pyspark (python) and a spark-shell that runs the executors in the cluster. See [Apache Spark](https://spark.apache.org) documentation for more information.

### Preston to DwC-A / Parquet using dwca2parquet.sh

1. complete steps to import preston-amazon dataset into HDFS to location hdfs:///user/[your username]/guoda/data/source=preston-amazon/ . 
2. unpack dwc archives and translate into parquets by running ```dwca2parquet.sh hdfs:///user/$USER/guoda/data/source=preston-amazon/data hdfs:///user/$USER/guoda/data/source=preston-amazon/dwca``` . Please note that if the dwca directory already exist, the process will fail.
3. after completion, verify that results exists by running ```hdfs dfs -ls hdfs:///user/$USER/guoda/data/source=preston-amazon/dwca/core.parquet``` 
4. alternatively, you can run ```echo "spark.read.parquet(\"\"\"hdfs:///user/$USER/guoda/data/source=preston-amazon/dwca/core.parquet\"\"\").show(2)" | spark-shell```


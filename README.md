# preston-scripts
Import and conversion scripts related to Preston data. 
The scripts are intended to provide examples on how to use [Preston](https://github.com/bio-guoda/preston) 
in combination with GUODA's cluster (e.g., HDFS, Apache Spark, Mesos).

Includes scripts to:

 1. [`HDFS Import`](#hdfs-import) - import Preston archive into HDFS
 2. [`Preston to DwC-A`)(#preston-to-dwca-a) - convert Preston DwC-A archives into sequence files, and parquet files.
 3. [`Create Taxonomic Checklist`](#create-taxonomic-checklist) - use converted Preston DwC-A archives to generate taxonomic checklists given specified taxon and geospatial constraints.

Please submit any issues you may have using https://github.com/bio-guoda/guoda-services/issues/  . 

## HDFS Import

Hadoop File System (HDFS) is a well-used distributed filesystem designed for parallel processing. Initially designed for hadoop map-reduce, it is now also used with processing engines like [Apache Spark](https://spark.apache.org). 

[preston2hdfs.sh](./preston2hdfs.sh) is a script to help migrate a Preston instance into HDFS. This is work in progress, so please be read the script before you use it.

To use:

0. Start a terminal via https://jupyter.idigbio.org 
1. Clone this repository ```git clone https://github.com/bio-guoda/preston-scripts```
2. ```cd preston-scripts```
3. Inspect [./preston2hdfs.sh](./preston2hdfs.sh) and change settings when needed.
4. By default, the preston2hdfs.sh script uses an example Preston instance, https://github.com/bio-guoda/preston-amazon , as a Preston remote and HDFS target ```/user/[your username]/guoda/data/source=preston-amazon/```. 
5. Run ```./preston2hdfs.sh``` to migrate the Preston remote to the specified HDFS target. 
6. Inspect the target HDFS target and the work directory ```preston2hdfs.tmp``` for results.  

## Preston to DwC-A 

Now that Preston data has been moved into HDFS, we can use [idigbio-spark](https://github.com/bio-guoda/idigbio-spark) to convert DwC-A files in the Preston data to formats like Parquet and Sequence file. This can be done using an interactive spark shell (```spark-shell``` or ```pyspark```), or by using by using spark-submit.

### Preston to DwC-A using dwca2parquet.sh

0. Repeat step 0-2 of previous recipe
1. Type ```hdfs dfs -ls /user/[your username]/guoda/data/source=preston-amazon/```
2. Confirm that the ```data``` and ```prov``` folder exists and have sub-directories.
3. Inspect [./dwca2parquet.sh](./dwca2parquet.sh) 
4. Run ```./dwca2parquet.sh``` with appropriate settings. By default it uses ```/user/[your username]/guoda/data/source=preston-amazon/data``` as your input and ```/user/[your username]/guoda/data/source=preston-amazon/dwca``` as your output
5. Once the job is done, inspect HDFS output dir at ```/user/[your username]/guoda/data/source=preston-amazon/dwca``` for results

### Preston to DwC-A using Spark Shell

Similar to previous, only instead of using the spark-job-submit.sh script, do the following:

0. start a jupyter terminal https://jupyter.idigbio.org 
1. download the https://github.com/bio-guoda/idigbio-spark/releases/download/0.0.1/iDigBio-LD-assembly-1.5.9.jar  
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

## Create Taxonomic Checklist 

Taxonomic checklists can be generated after converting Preston DwC-A to Parquet files. 

To generate a taxonomic checklist:

1. inspect [./create-checklist.sh](./create-checklist.sh) 
2. run ```./create-checklist.sh``` in jupyter.idigbio.org terminal using appropriate parameters. By default, a checklist for birds and frogs in an area covering the Amazon rainforest is created. 
3. inspect the results in ```hdfs:///user/[your user name]/guoda/checklist``` and ```hdfs:///user/[your user name]/guoda/checklist-summary``` or the non-default location that you used to calculate the checklist using:

```shell
$ hdfs dfs -ls /user/[your user name]/guoda/checklist
$ hdfs dfs -ls /user/[your user name]/guoda/checklist-summary
```

4. to use checklists in spark, start a spark-shell (or pyspark) and run commands like:

```shell
$ spark-shell
...
scala> val checklists = spark.read.parquet("/user/[your user]/guoda/checklist")
...
scala> checklists.show(10) // to show first 10 items in checklist
...
```
Use path ```/user/[your user]/guoda/checklist-summary``` to discover summaries of generated checklists.

5. to export checklists to csv files, use:

```shell
$ spark-shell
scala> val checklists = spark.read.parquet("/user/[your user]/guoda/checklist")
...
scala> checklists.write.csv("/user/[your user]/my-checklist.csv")
```

# Funding 

This work is funded in part by grant [NSF OAC 1839201](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1839201&HistoricalAwards=false) from the National Science Foundation.

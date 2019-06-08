# preston-scripts
import and conversion scripts related to Preston data 


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
 

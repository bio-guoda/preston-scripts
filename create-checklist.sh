#!/bin/bash                                                                                                                        
#
# Generates taxonomic checklist in guoda cluster using default Preston dwca corpus.
#
# usage:
#   ./create-checklist [taxon selector] [wkt string] [trait selector]
#
#
#                                                                                                                                  
                                                                                                                                   
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

trait_dir="hdfs:///guoda/data/traits"
input_dir="hdfs:///guoda/data/source=preston.acis.ufl.edu/dwca/core.parquet"
output_dir="hdfs:///user/$USER/guoda"

while getopts "h?cto:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  verbose=1
        ;;
    t)  output_file=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# see http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
trait_selector=${1-""}
wkt_string=${2-"POLYGON ((-72.77293810620904 -33.196074154826235, -72.77293810620904 6.59516197881252, -28.12450060620904 6.59516197881252, -28.12450060620904 -33.196074154826235, -72.77293810620904 -33.196074154826235))"} 
taxon_selector=${3-"Anas|Anura"}

# install prerequisites
source get-libs.sh

spark-submit \                                                                                                                     
  --master mesos://zk://mesos01:2181,mesos02:2181,mesos03:2181/mesos \ 
  --driver-memory 4G \ 
  --executor-memory 20G \                                                                                               
  --conf spark.sql.caseSensitive=true \ 
  --class ChecklistGenerator \                                                                                                     
  libs/idigbio-spark.jar \ 
  -c $input_dir \
  -t $trait_dir \
  -o $output_dir \                                                                                             
  "$taxon_selector" \ 
  "$wkt_string" \                                                                                                                  
  "$trait_selector"

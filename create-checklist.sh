#!/bin/bash
#
# Generate taxonomic checklist in guoda cluster using Preston DwC-A corpus by default.
#
# usage:
#   ./create-checklist [taxon selector] [wkt string] [trait selector]
#
#
#
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

function show_help {
    echo -e Generate taxonomic checklist in guoda cluster using default Preston dwca corpus.\\n\
    usage: ./create-checklist.sh [taxon selector] [wkt string] [trait selector]
}

trait_dir="hdfs:///guoda/data/traits"
input_dir="hdfs:///guoda/data/source=preston.acis.ufl.edu/dwca/core.parquet"
output_dir="hdfs:///user/$USER/guoda"

while getopts "h?cto:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  input_dir=$OPTARG
        ;;
    t)  trait_dir=$OPTARG
        ;;
    o)  output_dir=$OPTARG
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# see http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
taxon_selector=${1-"Anas|Anura"}
wkt_string=${2-"POLYGON ((-72.77293810620904 -33.196074154826235, -72.77293810620904 6.59516197881252, -28.12450060620904 6.59516197881252, -28.12450060620904 -33.196074154826235, -72.77293810620904 -33.196074154826235))"} 
trait_selector=${3-""}

# install prerequisites
source get-libs.sh

spark-submit \
  --master mesos://zk://mesos01:2181,mesos02:2181,mesos03:2181/mesos \
  --driver-memory 4G \
  --executor-memory 20G \
  --conf spark.sql.caseSensitive=true \
  --class ChecklistGenerator \
  $IDIGBIO_SPARK_JAR \
  -c $input_dir \
  -t $trait_dir \
  -o $output_dir \
  "$taxon_selector" \
  "$wkt_string" \
  "$trait_selector"

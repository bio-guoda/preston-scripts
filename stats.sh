#!/bin/bash
#
# Some scripts to calculate stats for Preston dataset observatories.
#
# More of a scratch pad than a supported tool.

last_versions=6

uniq_urls=$(preston history -l tsv | tr '\t' '\n' | grep hash | tail -n$last_versions | cut -f1 | parallel  preston get {1} | grep "hasVersion" | sort | uniq | cut -d ' ' -f1 | sort | uniq -c | sort -nr | wc -l)
rotten_urls=$(preston history -l tsv | tr '\t' '\n' | grep hash | tail -n$last_versions | cut -f1 | parallel  preston get {1} | grep "hasVersion" | grep  "well-known" | sort | uniq | cut -d ' ' -f1 | sort | uniq -c | sort -nr | wc -l)
drifing_urls=$(preston history -l tsv | tr '\t' '\n' | grep hash | tail -n$last_versions | cut -f1 | parallel  preston get {1} | grep "hasVersion" | grep -v "well-known" | sort | uniq | cut -d ' ' -f1 | sort | uniq -c | sort -nr | wc -l)

start_period=$(preston history -l tsv | tr '\t' '\n' | grep hash | tail -n$last_versions | head -n1 | cut -f1 | parallel preston get {1} | head -n10 | grep startedAt)
end_period=$(preston history -l tsv | tail -n1 | cut -f1 | parallel preston get {1} | head -n10 | grep startedAt)

echo $start_period
echo $end_period

echo [$uniq_urls] uniq urls
echo [$rotten_urls] rotten urls
echo [$drifing_urls] drifting urls

echo calculating hash sizes
find data -type f | parallel ls -s --block-size=1 {1} | pv -l | awk -F ' ' '{ print "hash://sha256/" substr($2,12) "\t" $1 }' | sort > hash_sizes.tsv

echo total hash size 
cat hash_sizes.tsv | cut -f2 | awk '{ sum+=$1 } END {print sum / (1024 * 1024 * 1024 ) " GB" }'

echo prov log start times, hashes and activity uuids
preston history -l tsv | tr '\t' '\n' | grep hash | sort | uniq | parallel "preston get {1} | grep startedAtTime | head -n1 | sed s+\.$+\<{1}\>.+" > prov-startedAt.nq

cat prov-startedAt.nq | awk -F ' ' '{ print substr($4, 2, 78) "\t" substr($3,2,24) }' | sort > prov-hash-time.tsv

echo create list of data hashes appearing in prov logs 
preston history -l tsv | tr '\t' '\n' | grep hash | sort | uniq | parallel "preston get {1} | tr ' ' '\n' | grep "hash://sha256" | sed s+^+{1}+ | tr '<' '\t' | tr -d '>'" | sort | uniq > prov-hash-data-hash.tsv

echo join timed prov hashes with data hashes
join prov-hash-time.tsv prov-hash-data-hash.tsv > prov-hash-time-data-hash.tsv

cat prov-hash-time-data-hash.tsv | awk -F ' ' '{ print $3 "\t" $2 "\t" $1 }' | sort > data-hash-time-prov-hash.tsv

join <(sort hash_sizes.tsv) <(cat data-hash-time-prov-hash.tsv) | tr ' ' '\t' > data-hash-size-time-prov-hash.tsv

echo collect creation time of individual data hashes
preston log -l tsv | grep generatedAtTime | grep hash | cut -f1,3 | sort | uniq > data-hash-data-time.tsv

echo -e "data_hash\tdata_size_bytes\tprov_start_time\tprov_hash\tdata_retrieved_time" > data-hash-size-prov-time-prov-hash-data-time.tsv
join data-hash-size-time-prov-hash.tsv data-hash-data-time.tsv | tr ' ' '\t' >> data-hash-size-prov-time-prov-hash-data-time.tsv

echo create a list of urls used in provenance logs
preston history -l tsv | tr '\t' '\n' | grep hash | sort | uniq | parallel "preston get {1} | grep -v \"ns#seeAlso\" | tr ' ' '\n' | grep -P \"http([s])*://\" | grep -v 'deeplinker' | grep -v 'purl\.org' | grep -v 'w3\.org' | grep -v '\"@' | sed s+^+{1}+ | sort | uniq" | tr '<' '\t' | tr -d '>' | sort | uniq > prov-hash-url.tsv

join <(sort prov-hash-time.tsv) <(sort prov-hash-url.tsv) | tr ' ' '\t' > prov-hash-time-url.tsv

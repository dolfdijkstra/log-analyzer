#/bin/bash

filename=futuretense.txt.gz

zcat $filename | egrep '\[CS\.TIME\]' | grep Executed | cut -b 43- > execute_all.txt

zcat $filename | egrep '\[CS\.TIME\]' | grep 'Execute time' | cut -b 64- | awk 'BEGIN {FS="[ :]"};{print $1*3600 + $4*60 +$7 "." $8}'> execute_time.txt

zcat $filename | egrep '\[CS\.TIME\]' | grep 'Executed element' | awk '{print $5,$7}' | sed 's/ms\.$//' > execute_elements.txt 

zcat $filename | egrep '\[CS\.TIME\]' | egrep '[[:digit:]]{3,}ms'| cut -b 43-  > execute_long.txt 

cat execute_long.txt   | awk '$1 ~ /Executed/ {print $2}' | sort | uniq -c > type_count.txt

cat execute_elements.txt | awk '{print $1}'  | sort -u > unique_elements.txt

cat execute_all.txt | grep 'Executed inline' | sed 's/ms$//' | awk '{print $5}'| sort -n | uniq -c > execute_time_inline_distribution.txt

cat execute_all.txt |awk '$1 ~ /Executed/ {print $2}' | sort | uniq -c  | sort -g > execute_distribution.txt

cat execute_all.txt |awk '$2 ~ /query/ {print $0}' | cut -b 16- | sed 's/ in \([0-9][0-9]*\)ms\.$/\t\1/' > execute_query_timings.txt 

cat execute_all.txt | awk '$2 ~ /prepared/ {print $0}' | cut -b 29- | sed 's/ in \([0-9][0-9]*\)ms$/\t\1/' >> execute_query_timings.txt 

cat execute_query_timings.txt | awk 'BEGIN {FS = "\t" } ; {print $1 }' | sort | uniq -c | sort -gr > execute_query_unique.txt

gzip execute_all.txt
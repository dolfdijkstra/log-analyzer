#/bin/bash

#expects that the log file is compressed, use gzcat for gzipped files
filename=futuretense.txt.Z

#use egrep with extented regex
egrep=/usr/xpg4/bin/egrep

zcat $filename | grep '\[CS\.TIME\]' | grep Executed | cut -b 43- > execute_all.txt

zcat $filename | grep '\[CS\.TIME\]' | grep 'Execute page' | cut -b 56- | gawk 'BEGIN {FS="[ :]"};{print $1,$4*3600+$7*60+$10 "." $11 }'>execute_time.txt

zcat $filename | grep '\[CS\.TIME\]' | grep 'Executed element' | gawk '{print $5,$7}' | sed 's/ms\.$//' > execute_elements.txt

zcat $filename | grep '\[CS\.TIME\]' | $egrep '[[:digit:]]{3,}ms'| cut -b 43-  > execute_long.txt

cat execute_long.txt   | gawk '$1 ~ /Executed/ {print $2}' | sort | uniq -c > execute_long_type_count.txt

cat execute_elements.txt | gawk '{print $1}'  | sort -u > unique_elements.txt

cat execute_all.txt | grep 'Executed inline' | sed 's/ms$//' | gawk '{print $5}'| sort -n | uniq -c > execute_time_inline_distribution.txt

cat execute_all.txt | gawk '$1 ~ /Executed/ {print $2}' | sort | uniq -c  | sort -n > execute_distribution.txt

cat execute_all.txt | gawk '$2 ~ /query/ {print $0}' | cut -b 16- | sed 's/ in \([0-9][0-9]*\)ms\.*$/|\1/' > execute_query_timings.txt

cat execute_all.txt | gawk '$2 ~ /prepared/ {print $0}' | cut -b 29- | sed 's/ in \([0-9][0-9]*\)ms\.*$/|\1/' >> execute_query_timings.txt

cat execute_query_timings.txt | gawk 'BEGIN {FS = "|" } ; {print $1 }' | sort | uniq -c | sort -nr > execute_query_unique.txt

gzip -f execute_all.txt

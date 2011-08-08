#/bin/bash

# The script expects that log files are in the futuretense commons-logging format. This means that the log message starts at the 74rd byte per line.
# If you have other logger implementations (like log4j) you may want to change the log file before using it as input for this tool.
# In most cases this means that you will need to use sed to change the log file.

# This tool expects that the log file is compressed, use gzcat for gzipped files
# to create this big gzipped log file, execute (for instance) on the command line: 
# >cat futuretense.txt* | gzip > futuretense.txt.gz 

# filename to use
filename=futuretense.txt.gz
loggername='\[fatwire\.logging\.cs\.time\]'


# use egrep with extented regex
egrep=egrep


# All the time debug log info into one big file.
# grep for the logger name and then cut line before loggername follozd by a space, as indicator for when the message starts.
zcat $filename | grep "$loggername" | sed "s/^.*$loggername //" | gzip > time-log.gz
zcat time-log.gz | grep Executed > execute_all.txt

# Calculate the execution time of pages
zcat time-log.gz | grep 'Execute page' | cut -b 14- | awk 'BEGIN {FS="[ :]"};{print $1,$4*3600000+$7*60000+$10*1000+$11 }' > execute_page.txt

# Calculate the execution time of elements
zcat time-log.gz | grep 'Executed element'| awk '{print $3,$5}' | sed 's/ms\.$//' > execute_elements.txt

# Split the timings into seperate files with different brackets
zcat time-log.gz | $egrep ' [[:digit:]]{1,2}ms' > execute_10ms.txt
zcat time-log.gz | $egrep ' [[:digit:]]{3}ms'   > execute_100ms.txt
zcat time-log.gz | $egrep ' [[:digit:]]{4}ms'   > execute_1s.txt
zcat time-log.gz | $egrep ' [[:digit:]]{5,}ms'  > execute_10s.txt

# Report the number of types (query, element, inline) for the bracket 100ms to 999ms.
cat execute_100ms.txt | awk '$1 ~ /Executed/ {print $2}' | sort | uniq -c > execute_100ms_type_count.txt

# Report the unique elements
cat execute_elements.txt | awk '{print $1}' | sort -u > unique_elements.txt

# Report execution of inline calls
cat execute_all.txt | grep 'Executed inline' | sed 's/ms$//' | awk '{print $5}'| sort -n | uniq -c > execute_inline_distribution.txt

cat execute_all.txt | awk '$1 ~ /Executed/ {print $2}' | sort | uniq -c | sort -n > execute_distribution.txt

# Report execution times for sql statements
cat execute_all.txt | awk '$2 ~ /query/ {print $0}' | cut -b 16- | sed 's/ in \([0-9][0-9]*\)ms\.*$/|\1/' > execute_query_timings.txt
cat execute_all.txt | awk '$2 ~ /prepared/ {print $0}' | cut -b 29- | sed 's/ in \([0-9][0-9]*\)ms\.*$/|\1/' >> execute_query_timings.txt

# Report how often a query was executed
cat execute_query_timings.txt | awk 'BEGIN {FS = "|" } ; {print $1 }' | sort | uniq -c | sort -nr > execute_query_unique.txt


# List pages that take longer than 10 seconds to execute
egrep ' [[:digit:]]{5,}$' execute_page.txt | grep -v BatchPublish | sort -k 2 -g > execute_page_sorted_10s.txt

# Report how many pages took between 1 and 99 ms to execute
egrep ' [[:digit:]]{1,2}$' execute_page.txt | grep -v BatchPublish | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_page_10ms_dist.txt 
# Report how many pages took between 100 and 999 ms to execute
egrep ' [[:digit:]]{3}$'   execute_page.txt | grep -v BatchPublish | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_page_100ms_dist.txt
# Report how many pages took between 1 and 9 s to execute
egrep ' [[:digit:]]{4}$'   execute_page.txt | grep -v BatchPublish | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_page_1s_dist.txt
# Report how many pages took more than  10 s to execute
egrep ' [[:digit:]]{5,}$'  execute_page.txt | grep -v BatchPublish | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_page_10s_dist.txt

# Report how often an element is executed
cat execute_elements.txt | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > elements_distribution.txt

# Report how many elements took between 1 and 99 ms to execute, repeat this for other brackets
cat execute_elements.txt | egrep ' [[:digit:]]{1,2}$' | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_elements_10ms_dist.txt 
cat execute_elements.txt | egrep ' [[:digit:]]{3}$'   | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_elements_100ms_dist.txt
cat execute_elements.txt | egrep ' [[:digit:]]{4}$'   | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_elements_1s_dist.txt
cat execute_elements.txt | egrep ' [[:digit:]]{5,}$'  | awk '{print $1}' | sort | uniq -c | sort -n -k 1 > execute_elements_10s_dist.txt

#rm -f execute_all.txt


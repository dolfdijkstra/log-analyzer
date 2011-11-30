grep "^\[" futuretense.txt | awk 'BEGIN {FS=" - "} {gsub(/ /, "", $2);close(f);f=$2}{print > "thread/"f".txt"}' 


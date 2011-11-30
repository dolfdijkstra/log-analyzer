#!/bin/bash
dir=request"/"`date +"%Y-%m-%d-%H%M"`
mkdir -p $dir
rm -f $dir/*
egrep '[0-9]{11,}' time.log | awk '{close(f);f="req-"$4}{print > "'"$dir"'/"f}' 
echo "split log file into several files"
for f in $dir/req-*
do
  if [ -f $f ]
  then
    FILESIZE=$(stat -c%s "$f")
    if [ $FILESIZE -gt 2048 ] 
    then
      echo "$f is $FILESIZE"
      awk '/Executed element/ {print $7,$3,$9}' $f | sed -e 's/ms.//' | awk '{print "element", $1,$2-$3,$2,$3}' | sort -k3 -n > $f-e.txt
      grep 'Execute page' $f | cut -b 25- | awk 'BEGIN {FS="[ :]"};{e=$8*3600000+$11*60000+$14*1000+$15; print "page",$5,$1-e,$1,e }' | sort -k3 -n > $f-p.txt
      cat $f-p.txt $f-e.txt | sort -k3n -k1r > $f-c.txt
      Rscript --vanilla cs-time.R $f-c.txt 
    else
     #remove small files
     rm $f
    fi
  fi
done

#!/bin/bash

#-p 1024 breaks files into 1GB of data, -c is core for reading -w core for writing, -q poll duration do not know functionality, 
#-s is for packet size capture..since ours is 8192..check using wireshark if whole packet gets captured...
#-b buffer size based on RAM..
#.-C when to write to disk (eg. 3072 means write as soon as buffer is filled with 300MB data).. 
#rm -rf temp/* temp1/* temp/.n2disk temp1/.n2disk        #delete any old files
sudo $HOME/gulp/free_mem.sh       #free memory
pwd
sudo n2disk10g -i eth1 -o temp/ -b 15360 -C 3072 -p 64 -q 1 -S 0 -c 0 -w 1 -s 8300 >temp_file & pid=$!       #15GB buffer size according to RAM3 GB file size of pcap

sleep 7

while true
do
  [[ `find temp/2.pcap 2> /dev/null   ` ]] && break
#  echo "1.pcap finished"
  sleep 2
done

sudo kill -SIGINT $pid
wait $pid
echo "Killed n2disk with $pid and exits" #n2disk is used for capture 10gb


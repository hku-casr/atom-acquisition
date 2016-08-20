#!/bin/bash

remDir="~/Desktop"
hdDir="/media/varma/ganymede1/"
dirPrefix="hcng"*;

comp1="147.8.183.178" 
comp2="147.8.183.236"
comp3="147.8.182.235"
comp4="147.8.183.120"

ssh $comp1 "cd $remDir; cp -v -r $dirPrefix $hdDir" &
ssh $comp2 "cd $remDir; cp -v -r $dirPrefix $hdDir" &
ssh $comp3 "cd $remDir; cp -v -r $dirPrefix $hdDir" &
ssh $comp4 "cd $remDir; cp -v -r $dirPrefix $hdDir" &

echo "**Copying, do not terminate the script!**";

wait

echo "**Deleting**";

ssh $comp1 "cd $remDir; rm -rf -v $dirPrefix" &
ssh $comp2 "cd $remDir; rm -rf -v $dirPrefix" &
ssh $comp3 "cd $remDir; rm -rf -v $dirPrefix" &
ssh $comp4 "cd $remDir; rm -rf -v $dirPrefix" &

wait

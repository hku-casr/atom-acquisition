#!/bin/bash
remCleanDir="~/Desktop/hcng_2000Sam_MCF7_m30" # This is the remote directory on 4 machines
cleanDir="/media/varma/ganymede1/scripts/hcng_2000Sam_MCF7_m30" # The folder machine from where you run this script

comp1="147.8.183.178" 
comp2="147.8.183.236"
comp3="147.8.182.235"
comp4="147.8.183.120"

if [ -d "$cleanDir" ]; then
  # Control will enter here if $DIRECTORY exists.
  echo "Removing Directory $runDir"  
  rm -rf $cleanDir
else
  echo "Clean Directory $cleanDir doesn't exist. Please change"
  exit 0
fi

#checks if remote directory exists
if (ssh $comp1 [ -d $remCleanDir ]) || (ssh $comp2 [ -d $remCleanDir ]) || (ssh $comp3 [ -d $remCleanDir ]) || (ssh $comp4 [ -d $remCleanDir ]) 
then
{
  echo "Removing Remote Directory" 
  ssh $comp1 "rm -rf $remCleanDir" &
  ssh $comp2 "rm -rf $remCleanDir" &
  ssh $comp3 "rm -rf $remCleanDir" &
  ssh $comp4 "rm -rf $remCleanDir" &
}
else
{
  echo "Remote Run Directory $remCleanDir doesn't exist. Please change"
}
fi


#!/bin/bash

DirName="hcng_2000Sam_MB231_m4"

remRunDir="/media/varma/ganymede1/" # This is the remote directory on 4 machines
runDir="/media/varma/ganymede1/scripts/" # The folder machine from where you run this script

remRunDir=$remRunDir$DirName
runDir=$runDir$DirName

comp1="147.8.183.178" 
comp2="147.8.183.236"
comp3="147.8.182.235"
comp4="147.8.183.120"

cd $runDir

if [ -d "$runDir" ]; then
    # Control will enter here if $DIRECTORY exists.
    echo "Run Directory $runDir exists. OK"
else
    echo "Run Directory $runDir doesn't exist. Please change"
    exit 0
fi


if (ssh $comp1 [ -d $remRunDir ]) && (ssh $comp2 [ -d $remRunDir ]) && (ssh $comp3 [ -d $remRunDir ]) && (ssh $comp4 [ -d $remRunDir ]) 
then
{
    echo "Remote Run Directory $remRunDir exists. OK"
#exit 0   #Uncomment when not Testing
}
else
{
    echo "Remote Run Directory $remRunDir doesn't exist."
    exit 0
}
fi

cd $runDir
mkdir comp1
mkdir comp2
mkdir comp3
mkdir comp4


cd $runDir/comp1
#go to remote server, obtain the file list
contents1=( $(ssh $comp1 "cd $remRunDir/temp; for i in \`ls\`; do echo \$i; done;") )
#copy the data from server to localhost
echo "Download from comp1"
for (( i=0; i<${#contents1[@]}; i++ )); 
    do scp $comp1:$remRunDir/temp/${contents1[i]} ./; 
done

cd $runDir/comp2
#go to remote server, obtain the file list
contents2=( $(ssh $comp2 "cd $remRunDir/temp; for i in \`ls\`; do echo \$i; done;") )
#copy the data from server to localhost
echo "Download from comp2"
for (( i=0; i<${#contents2[@]}; i++ )); 
    do scp $comp2:$remRunDir/temp/${contents2[i]} ./; 
done

cd $runDir/comp3
#go to remote server, obtain the file list
contents3=( $(ssh $comp3 "cd $remRunDir/temp; for i in \`ls\`; do echo \$i; done;") )
#copy the data from server to localhost
echo "Download from comp3"
for (( i=0; i<${#contents3[@]}; i++ )); 
    do scp $comp3:$remRunDir/temp/${contents3[i]} ./; 
done

cd $runDir/comp4
#go to remote server, obtain the file list
contents4=( $(ssh $comp4 "cd $remRunDir/temp; for i in \`ls\`; do echo \$i; done;") )
#copy the data from server to localhost
echo "Download from comp4"
for (( i=0; i<${#contents4[@]}; i++ )); 
    do scp $comp4:$remRunDir/temp/${contents4[i]} ./; 
done



  
cd $runDir/comp1
cp ../../common/tsharkTo8bitLine ./
echo "Convert pcap to data in comp1"
for (( i=0; i<${#contents1[@]}; i++ ));do
   value1=( $(echo ${contents1[i]}  |  awk -F'.' '{print $1}';) );
   output1=$value1'.out';
   echo "Generating $output1 in comp1 and convert it to 8 16-bit values a line";
   tshark -r ${contents1[i]} -T fields -e data | tr -d '\n' > $output1;
   ./tsharkTo8bitLine $output1 $value1.tmp &
done


cd $runDir/comp2
cp ../../common/tsharkTo8bitLine ./
echo "Convert pcap to data in comp2"
for (( i=0; i<${#contents2[@]}; i++ ));do
   value2=( $(echo ${contents2[i]}  |  awk -F'.' '{print $1}';) );
   output2=$value2'.out';
   echo "Generating $output2 in comp2 and convert it to 8 16-bit values a line";
   tshark -r ${contents2[i]} -T fields -e data | tr -d '\n' > $output2;
   ./tsharkTo8bitLine $output2 $value2.tmp &
done


cd $runDir/comp3
cp ../../common/tsharkTo8bitLine ./
echo "Convert pcap to data in comp3"
for (( i=0; i<${#contents3[@]}; i++ ));do
   value3=( $(echo ${contents3[i]}  |  awk -F'.' '{print $1}';) );
   output3=$value3'.out';
   echo "Generating $output3 in comp3 and convert it to 8 16-bit values a line";
   tshark -r ${contents3[i]} -T fields -e data | tr -d '\n' > $output3;
   ./tsharkTo8bitLine $output3 $value3.tmp &
done

cd $runDir/comp4
cp ../../common/tsharkTo8bitLine ./
echo "Convert pcap to data in comp4"
for (( i=0; i<${#contents4[@]}; i++ ));do
   value4=( $(echo ${contents4[i]}  |  awk -F'.' '{print $1}';) );
   output4=$value4'.out';
   echo "Generating $output4 in comp4 and convert it to 8 16-bit values a line";
   tshark -r ${contents4[i]} -T fields -e data | tr -d '\n' > $output4;
   ./tsharkTo8bitLine $output4 $value4.tmp &
done
    
wait


cd $runDir/
cp ../common/8bitLineToBig ./
./8bitLineToBig ./comp1 ./comp2 ./comp3 ./comp4 bigPlot



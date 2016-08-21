#!/bin/bash
remRunDir="~/Desktop/hcng_2000Sam_MCF7_m30" # This is the remote directory on 4 machines
runDir="/media/varma/ganymede1/scripts/hcng_2000Sam_MCF7_m30" # The folder machine from where you run this script
comp1="147.8.183.178" 
comp2="147.8.183.236"
comp3="147.8.182.235"
comp4="147.8.183.120"
casr2="147.8.183.220"  #Roach2 Host
roach="192.168.100.182" #2 or 182  #for setting up roach number

#rm -rf $runDir #Test
if [ -d "$runDir" ]; then
  # Control will enter here if $DIRECTORY exists.
  echo "Run Directory $runDir exixts. Please change"
  exit 0
else
  echo "Creating Directory $runDir"
  mkdir $runDir  
fi

#checks if remote directory exists
if (ssh $comp1 [ -d $remRunDir ]) || (ssh $comp2 [ -d $remRunDir ]) || (ssh $comp3 [ -d $remRunDir ]) || (ssh $comp4 [ -d $remRunDir ]) 
then
{
echo "Remote Run Directory $remRunDir exixts. Please change"
#exit 0   #Uncomment when not Testing
}
else
{
echo "Creating Remote Directory"
 ssh $comp1 "mkdir $remRunDir $remRunDir/temp $remRunDir/temp1 | sudo chmod 777 $remRunDir/temp $remRunDir/temp1" &
 ssh $comp2 "mkdir $remRunDir $remRunDir/temp $remRunDir/temp1 | sudo chmod 777 $remRunDir/temp $remRunDir/temp1" &
 ssh $comp3 "mkdir $remRunDir $remRunDir/temp $remRunDir/temp1 | sudo chmod 777 $remRunDir/temp $remRunDir/temp1" &
 ssh $comp4 "mkdir $remRunDir $remRunDir/temp $remRunDir/temp1 | sudo chmod 777 $remRunDir/temp $remRunDir/temp1" &
}
fi

wait
scp remote_run.sh $comp1:$remRunDir/. &
scp remote_run.sh $comp2:$remRunDir/. &
scp remote_run.sh $comp3:$remRunDir/. &
scp remote_run.sh $comp4:$remRunDir/. &
wait

###set the values
ssh $comp1 'sudo ifconfig eth1 mtu 9600 | sudo ifconfig eth2 mtu 9600' &
ssh $comp2 'sudo ifconfig eth1 mtu 9600 | sudo ifconfig eth2 mtu 9600' &
ssh $comp3 'sudo ifconfig eth1 mtu 9600 | sudo ifconfig eth2 mtu 9600' &
ssh $comp4 'sudo ifconfig eth1 mtu 9600 | sudo ifconfig eth2 mtu 9600' &

ssh $comp1 'sudo sysctl -p /etc/sysctl.conf' &
ssh $comp2 'sudo sysctl -p /etc/sysctl.conf' &
ssh $comp3 'sudo sysctl -p /etc/sysctl.conf' &
ssh $comp4 'sudo sysctl -p /etc/sysctl.conf' &


ssh $comp1 'sudo ifconfig eth1 192.168.0.15 netmask 255.255.255.0 up' &
ssh $comp2 'sudo ifconfig eth1 192.168.0.115 netmask 255.255.255.0 up' &
ssh $comp3 'sudo ifconfig eth1 192.168.0.16 netmask 255.255.255.0 up' &
ssh $comp4 'sudo ifconfig eth1 192.168.0.116 netmask 255.255.255.0 up' &
#########
ssh $comp1 "sudo $HOME/gulp/free_mem.sh" &
ssh $comp2 "sudo $HOME/gulp/free_mem.sh" &
ssh $comp3 "sudo $HOME/gulp/free_mem.sh" &
ssh $comp4 "sudo $HOME/gulp/free_mem.sh" &
wait

ssh $casr2 'cd boffiles && python dumy.py' ##dummy files to stop sending data over ethernet. This makes it simpler to synchronise eth data

echo "Start Ethernet capture"

ssh $comp1 "cd $remRunDir && sudo $remRunDir/remote_run.sh"  &
ssh $comp2 "cd $remRunDir && sudo $remRunDir/remote_run.sh"  &
ssh $comp3 "cd $remRunDir && sudo $remRunDir/remote_run.sh"  &
ssh $comp4 "cd $remRunDir && sudo $remRunDir/remote_run.sh"  &

echo "Program BofFiles"

sleep 9  #4 if using test_delays from Jack

ssh $casr2 "cd boffiles &&  python fullethdev.py -r $roach -b adcethvfullv64_2015_Dec_01_0023.bof"

echo "Waiting for 1.pcap to finish on each of the systems"
wait
ssh $casr2 'cd boffiles/ && python dumy.py' ##dummy files to stop sending data over ethernet.
echo "All jobs on remote machine finished"

# Tasks to be done in runDir
###copy required files
cp common/* $runDir/.
cd  $runDir
#chmod +x 2bit1.sh &
#chmod +x 2bit2.sh &
###########  data copy 
echo "Data Manipulation and Analysis\n"
scp $comp1:$remRunDir/temp/1.pcap comp1_temp.pcap &
scp $comp2:$remRunDir/temp/1.pcap comp1_temp1.pcap &
scp $comp3:$remRunDir/temp/1.pcap comp2_temp.pcap &
scp $comp4:$remRunDir/temp/1.pcap comp2_temp1.pcap &
#scp varma@dhcp-3156.eee.hku.hk:~/Desktop/data4/temp1/1.pcap /home/varma/Desktop/data/sinewave2/comp3_temp.pcap &
#scp varma@dhcp-3156.eee.hku.hk:~/Desktop/data4/temp1/1.pcap /home/varma/Desktop/data/sinewave2/comp3_temp1.pcap &
#scp varma@dhcp-3156.eee.hku.hk:~/Desktop/data4/temp/1.pcap /home/varma/Desktop/data/sinewave2/comp4_temp.pcap &
#scp varma@dhcp-3156.eee.hku.hk:~/Desktop/data4/temp1/1.pcap /home/varma/Desktop/data/sinewave2/comp4_temp1.pcap &
##################
wait
############# get only data ########
tshark -r comp1_temp.pcap -T fields -e data | tr -d '\n' > data1.out &
tshark -r comp1_temp1.pcap -T fields -e data | tr -d '\n' > data2.out &
tshark -r comp2_temp.pcap -T fields -e data | tr -d '\n' > data3.out &
tshark -r comp2_temp1.pcap -T fields -e data | tr -d '\n' > data4.out &
#tshark -r comp3_temp.pcap -T fields -e data | tr -d '\n' > data5.out &
#tshark -r comp3_temp1.pcap -T fields -e data | tr -d '\n' > data6.out &
#tshark -r comp4_temp.pcap -T fields -e data | tr -d '\n' > data7.out &
#tshark -r comp4_temp1.pcap -T fields -e data | tr -d '\n' > data8.out &
###########################
wait
###################
mkdir d1 d2 d3 d4 d5 d6 d7 d8
cp convert d1/. | cp convert d2/. | cp convert d3/. | cp convert d4/.
#cp convert d5/. | cp convert d6/. | cp convert d7/. | cp convert d8/.
####################### converter script
wait
cd d1
echo -e "../data1.out" | ./convert &
cd ../d2
echo -e "../data2.out" | ./convert &
cd ../d3
echo -e "../data3.out" | ./convert &
cd ../d4
echo -e "../data4.out" | ./convert &
#cd ../d5
#echo -e "../data5.out" | ./convert &
#cd ../d6
#echo -e "../data6.out" | ./convert &
#cd ../d7
#echo -e "../data7.out" | ./convert &
#cd ../d8
#echo -e "../data8.out" | ./convert &
cd ..
########################################## paste commands after deleting last line
wait
dd if=/dev/null of=d1/temp bs=1 seek=$(echo $(stat --format=%s d1/temp ) - $( tail -n1 d1/temp | wc -c) | bc )
dd if=/dev/null of=d2/temp bs=1 seek=$(echo $(stat --format=%s d2/temp ) - $( tail -n1 d2/temp | wc -c) | bc )
dd if=/dev/null of=d3/temp bs=1 seek=$(echo $(stat --format=%s d3/temp ) - $( tail -n1 d3/temp | wc -c) | bc )
dd if=/dev/null of=d4/temp bs=1 seek=$(echo $(stat --format=%s d4/temp ) - $( tail -n1 d4/temp | wc -c) | bc )
#dd if=/dev/null of=d5/temp bs=1 seek=$(echo $(stat --format=%s d5/temp ) - $( tail -n1 d5/temp | wc -c) | bc )
#dd if=/dev/null of=d6/temp bs=1 seek=$(echo $(stat --format=%s d6/temp ) - $( tail -n1 d6/temp | wc -c) | bc ) 
#dd if=/dev/null of=d7/temp bs=1 seek=$(echo $(stat --format=%s d7/temp ) - $( tail -n1 d7/temp | wc -c) | bc )
#dd if=/dev/null of=d8/temp bs=1 seek=$(echo $(stat --format=%s d8/temp ) - $( tail -n1 d8/temp | wc -c) | bc )

paste -d "" d1/temp d2/temp > op1 &
paste -d "" d3/temp d4/temp > op2 #&
#paste -d "" d5/temp d6/temp > op3 &
#paste -d "" d7/temp d8/temp > op4 &
########################################cobine
wait


./writedata >plot1
wait
#./2bit1.sh >plot1 # &
#./2bit2.sh >plot2 &
#########################################remove spaces
#wait
#sed -i '/^$/d' plot1 #&
#sed -i '/^$/d' plot2 &
#########
echo done
#rm -rf *.pcap *.out d* op1 op2 
rm -rf *.out d* op1 op2 

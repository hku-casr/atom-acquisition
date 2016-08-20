# Atom-acquisition

There are multiple machines in the entire system:

1. One Roach-2 Revision-2
2. One NFS connected to Roach-2
3. Four Storage Nodes
4. One Computer (Main) to launch the entire execution.

To perform data acquisition from the ATOM frontend, the following software has to be installed apart from the required tools from CASPER.

1. Storage Nodes:
  1. Ubuntu 14.04 LTS
  2. n2disk10g
2. Main
  1. Ubuntu 14.04 LTS 
2. Tshark
  
The following steps outline the entire data acquisition process. Every execution is done on Main unless otherwise specified.

1.  Navigate to `fpga`, compile and generate the required bof file with the `adcethvfullv64.mdl` using Matlab, Xilinx Simulink and CASPER library. Or you can use the provided bof file.
2.  Then copy the bof file to `../sw/nfs`.
3.  Navigate to `sw/main`, open `main.sh` according to your own platforms.
```Shell
# This is the remote directory on 4 machines that you want to store data
remRunDir="xxx/xxx" 
# The directory machine, i.e. Main, from where you run this script
runDir=" xxx/xxx " 

# The IP address for the Storage Nodes
comp1="xxx.xxx.xxx.xxx" 
comp2="xxx.xxx.xxx.xxx"
comp3="xxx.xxx.xxx.xxx"
comp4="xxx.xxx.xxx.xxx"

# The IP address for the NFS
casr2="xxx.xxx.xxx.xxx"
roach="192.168.100.182"
```


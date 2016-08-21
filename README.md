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
2. Main:
  1. Ubuntu 14.04 LTS 
2. Tshark

## Data Acquisition  
The following steps outline the entire data acquisition process. Every execution is done on Main unless otherwise specified.

1. Navigate to `fpga`, compile and generate the required bof file with the `adcethvfullv64.mdl` using Matlab, Xilinx Simulink and CASPER library. Or you can use the provided bof file.

2. Then copy the bof file to `../sw/nfs`.

3. Copy `sw/nfs` to the NFS machine where the target directory is `$HOME/boffiles`.

4. Copy `sw/node` to each of the storage nodes where the target directory is `$HOME/`.

5. Go to `sw/main/common`, execute `make`.

6. Navigate to `sw/main`, open `main.sh`and change the following lines according to your own platforms.
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
  # Local IP for Roach-2
  roach="192.168.100.xxx"
```
7. Also in the same file, modify the following lines according to the bof file name.
  ```Shell
  ssh $casr2 "cd boffiles &&  python fullethdev.py -r $roach -b xxx.bof"
  ```

8. Launch `main.sh` to start the data acquisition process.

9. After the execution of `main.sh`, portion of data will be availabe at `$runDir` where the filename is `plot1`.

## Data Multiplexing
The following steps outline the process to combine and multiplex the data from the storage nodes.

1. Go to `sw/main/post_unify`, execute `make` to compile the program `8bitLineToBig` and `tsharkTo8bitLine`.

2. Open `postDataAnalysis.sh` and change the following lines according to your system settings.
  ```Shell
  DirName="xxx"
  
  # This is the remote directory on 4 machines
  remRunDir="xxx/xxx"
  # The folder machine, i.e. Main,  from where you run this script  
  runDir="xxx/xxx" 

  remRunDir=$remRunDir$DirName
  runDir=$runDir$DirName

  comp1="xxx.xxx.xxx.xxx" 
  comp2="xxx.xxx.xxx.xxx"
  comp3="xxx.xxx.xxx.xxx"
  comp4="xxx.xxx.xxx.xxx"
   ```
3. Launch `postDataAnalysis.sh` to obtain the whole timing diagram for the data, note this can take 10-15 mins.

# checkpoint_object_explorer

This program is a shell script written in Bash, a Unix shell that runs in a command-line interface (CLI). The bash program aims to automate multiple task in Checkpoint management server. This script can create bulk IP objects, Network objects, and Service objects (TCP/UDP) at once. Also, it can add bulk IP objects, Network objects, and Service objects (TCP/UDP) into a group or multiple groups at once using Checkpoint API.

With creation this script can also export IP objects, Network objects, and Service objects (TCP/UDP) from a group or multiple group at once using Checkpoint API which is not possible from Checkpoint Smart Console. Detailed Explanation is below.

This script is tested on R80+ and R81+ series GAIA OS.

This program is divided into multiple functions to better understand the working.

![image](https://user-images.githubusercontent.com/75925433/229117211-f8ba932a-d35c-41ee-b1db-8fad9ecc4d30.png)

After pressing enter it provides you with 3 options as below,

```
1) Create or Add Objects
2) Export Objects
3) Quit Program
```
On selecting 1st option, it first asks for credentials of "Smartconsole" to create a session and once the session is created it gives you a sub options to proceed further accordingly.

![image](https://user-images.githubusercontent.com/75925433/229118374-c40659d5-6b31-4748-aad4-8490cf6642c1.png)

```
Note:                                                             
                                                                   
If creating .csv file manually, make sure to use below parameters as column title:

1. Host Object: name,ip-address                                   
2. Network Subnet: name,subnet,mask-length                        
3. Service UDP Object: name,port (eg.,2 or 2-10)                  
4. Service TCP Object: name,port (eg.,2 or 2-10)                  
5. Add Objects to group or groups : name,members.add      
```

> *Most important part in this script is to provide proper input files with correct data. For more information on correct file input please refer below link from Checkpoint for management API reference.*

https://sc1.checkpoint.com/documents/latest/APIs/#introduction~v1.9%20

Once required task is done it then provide below options:

```
1) Publish              3) Sub Menu 2  5) Quit Program
2) Discard              4) Main Menu
```
If you need to do any more task before publishing then you can do the same selecting 3rd option and then perform the task. 

```
Note: 

1. Do not select 4th Option until you "Publish" or "Discard" the changes you have already done. 
This is because if you select 4th option without publishing or discarding the session then you 
won't be able to "Publish" or "Discard" the changes as the session on which you were working will 
get discontinued. 

2. In such cases, go to smartconsole and then go to "Manage & Settings > Sessions" and select 
the relevent session, right click on it and take necessary action.

3. I have given that option in case if you have done all the changes and now want to go and do 
some tasks on exporting objects.
```

Other than Importing, this script can export objects from groups which is not possible via smartconsole.

If you select 2nd option, it will give you below options 

```
1) Export objects from network group
2) Export objects from multiple network groups at once
3) Export objects from service group
4) Export objects from multiple service groups at once
5) Main Menu
6) Quit program
```
Depending on you selecion script will take action.

Here's a brief explanation of the steps that the function performs:
```
1. It prompts the user to enter the name of a group if objects from signle group is to be extracted.
2. In case of multiple groups, it prompts the user to enter the name of a file containing a list of group names.
3. It reads the names from the file and extracts data depending on the selection.
4. It prompts the user to select an option for exporting 
      1. IPv4 
      2. IPv6
      3. Both IPv4 and IPv6 addresses
5. It exports the selected addresses using the "mgmt_cli" command and saves the output to a CSV file.
6. It will then create a folder with name "exported_files" in the current directory.
7. All the files that are created will be saved in the above mentioned folder.
```
The script uses the "jq" command-line tool to parse the JSON output of the **"mgmt_cli"** command and extract the relevant information.

To execute this program, follow these steps:

    1. Open a terminal of Checkpoint Management Server.
    
    2. Save the program to a file with a ".sh" extension.
    
    3. Set the file's permissions to allow execution by running the command "chmod +x checkpoint_object_explorer.sh".
    
    4. Run the program by entering "./checkpoint_object_explorer.sh" in the terminal
    
    5. Follow the prompts and enter any required inputs.
    
    7. The program will execute the selected function and provide the results.

















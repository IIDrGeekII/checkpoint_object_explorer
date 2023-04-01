#!/bin/bash

###############################################################################################
###############################################################################################

#Color Codes:

export PS3=$'\e[38;5;172m\nExplorer > \e[0m'
END="\e[0m"
GREEN="\e[1;92m"
RED="\e[1;91m"
CYAN="\033[36m"
MAGENTA="\033[35m"
YELLOW="\033[33m"

###############################################################################################
###############################################################################################

function box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 6
  echo " -${b//?/-}-
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 7)" "-$w" "$l" "$(tput setaf 6)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

###############################################################################################
###############################################################################################

cleanup() {
        rm -rf ~/junk > /dev/null
  }

###############################################################################################
###############################################################################################

#Spinner for sleep:

spinner () {
    local chars=('|' / - '\')

    # hide the cursor
    tput civis
    trap 'printf "\010"; tput cvvis; return' INT TERM

    printf %s "$*"

    while :; do
        for i in {0..3}; do
            printf %s "${chars[i]}"
            sleep 0.3
            printf '\010'
        done
    done
}

###############################################################################################
###############################################################################################

copy ()
{
    local pid return

    spinner "$spin" & pid=$!

    # Slow copy command here
    sleep 3

    return=$?

   # kill spinner, and wait for the trap commands to complete
    kill "$pid"
    wait "$pid"

    if [[ "$return" -eq 0 ]]; then
        echo " "
    else
        echo ERROR
    fi
}

###############################################################################################
###############################################################################################

quit()
{
cleanup

cat << !

`printf "${CYAN}            +----------------------------------------+ ${END}"`
`printf "${CYAN}            |                                        | ${END}"`
`printf "${CYAN}            |  Thank you for using Object Explorer!  | ${END}"`
`printf "${CYAN}            |     Vaibhav_Masane A.K.A. @DrGeek      | ${END}"`
`printf "${CYAN}            |                                        | ${END}"`
`printf "${CYAN}            +----------------------------------------+ ${END}"`

!


spin=$(printf "${RED}cleaning up and quitting the program ...${END}") && copy && clear
exit 0
}

###############################################################################################
###############################################################################################

change()
{

echo ""
printf "\nSelect option: \n"
echo ""
change=("Publish" "Discard" "Sub Menu 2" "Main Menu" "Quit Program")

select menu in "${change[@]}"; do

if [ "$menu" = "Sub Menu 2" ]; then
        createobject
        elif [ "$menu" = "Main Menu" ]; then
        mainmenu
        elif [ "$menu" = "Quit Program" ]; then
        quit
        elif [ "$menu" = "Publish" ]; then
        time mgmt_cli publish -s "$session"
        elif [ "$menu" = "Discard" ]; then
        time mgmt_cli discard -s "$session"
        else
#if no valid option is chosen, chastise the user
        echo "That's not a valid option! Hit ENTER to show menu."
        fi
done

}

###############################################################################################
###############################################################################################

mainmenu()
{

printf "\nSelect option to continue: \n"
echo ""
mainmenu=("Create or Add Objects" "Export Objects" "Quit Program")
select opt in "${mainmenu[@]}"; do
        if [ "$opt" = "Quit Program" ]; then
        quit
        elif [ "$opt" = "Create or Add Objects" ]; then
sessioncreator
creaddobject
        elif [ "$opt" = "Export Objects" ]; then
exportobject
        else
#if no valid option is chosen, chastise the user
        echo "That's not a valid option! Hit ENTER to show menu."
        fi
done

}

###############################################################################################
###############################################################################################

creaddobject()
{

printf "\nSelect option to continue: \n"
echo ""
creaddobject=("Create Objects" "Add Objects" "Quit Program")
select creadd in "${creaddobject[@]}"; do
        if [ "$creadd" = "Quit Program" ]; then
        quit
        elif [ "$creadd" = "Create Objects" ]; then
createobject
        elif [ "$creadd" = "Add Objects" ]; then
groupadder
        else
#if no valid option is chosen, chastise the user
        echo "That's not a valid option! Hit ENTER to show menu."
        fi
done

}

###############################################################################################
###############################################################################################

sessioncreator()
{

printf "\nProvide credentials to create session:\n"

printf "\n${GREEN}Enter Smartconsole Username: ${END}"
read username

# Disable local echo
stty -echo
printf "${GREEN}Enter Smartconsole Password: ${END}"
read password
# Enable local echo again
stty echo
printf "\n"
spin=$(printf "${CYAN}\nCreating session ...${END}")
copy
# Define the folder name you're looking for
folder="junk"

# Check if the folder exists
if [ ! -d "$folder" ]; then
  # Folder doesn't exist, create it
  mkdir "$folder"
fi
mgmt_cli login user "$username" password "$password" > ~/junk/session
input=$(grep -o "\S*" ~/junk/session | grep -i "sid" | sed "s/://g")
#sleep 3
if [ "$input" = "sid" ]; then

printf "${YELLOW}\nSession created successfully.\n${END}"
printf "${MAGENTA}\n`grep -i "sid\|uid" ~/junk/session | grep -v "user-uid"`\n${END}"
session=$(echo ~/junk/session)
spin=$(printf "${CYAN}\nScanning database ...${END}")
copy
#sleep 7
printf "${YELLOW}\nDatabase scanned successfully.\n${END}"
sleep 0.5
fi

if [ "$input" != "sid" ]; then

printf "${RED}\n`grep -i "message" ~/junk/session`\n${END}"
printf "\n${RED}Exiting with error..\n${END}"
sleep 3
printf "\n${RED}Please try again by running the script with correct credentials.\n${END}"
printf "\n"
sleep 2
exit 0

fi

}

###############################################################################################
###############################################################################################

createobject()
{

echo ""
createobject=("Host Object" "Network Object" "Service TCP Object" "Service UDP Object" "Sub Menu 1" "Main Menu" "Quit Program")

box_out "Note:" " " "If creating .csv file manually, make sure to use below parameters:" "1. Host Object: name,ip-address" "2. Network Subnet: name,subnet,mask-length" "3. Service UDP Object: name,port (eg.,2 or 2-10)" "4. Service TCP Object: name,port (eg.,2 or 2-10)" "5. Add Objects to group or groups : name,members.add"

printf "\nSelect option: \n"
echo ""
select submenu in "${createobject[@]}"; do

if [ "$submenu" = "Host Object" ]; then
hostcreator
change

elif [ "$submenu" = "Network Object" ]; then
networkcreator
change

elif [ "$submenu" = "Service TCP Object" ]; then
tcpcreator
change

elif [ "$submenu" = "Service UDP Object" ]; then
udpcreator
change

elif [ "$submenu" = "Sub Menu 1" ]; then
creaddobject
change

elif [ "$submenu" = "Main Menu" ]; then
mainmenu

elif [ "$submenu" = "Quit Program" ]; then
        quit
        else
                echo  "That's not a valid option! Hit ENTER to show menu"
        fi
        done
}

###############################################################################################
###############################################################################################

hostcreator()
{

printf "\nEnter following details to create API compatible file:"
printf "\n"
printf "\n${GREEN}Filename containing list of IP objects: ${END}"

read list

grep -v '^[[:space:]]*$' $list > ~/junk/sortedlist

blank=$(echo ~/junk/sortedlist)

printf "${GREEN}Word that needs to get combined with the above list(eg.,IP_): ${END}"

read tmp

printf "$tmp%s\n" $(< $blank) > ~/junk/iplist

file=$(echo ~/junk/iplist)

paste -d, $file $blank > ~/junk/outfin

sed -i '1s/^/name,ip-address \n/' ~/junk/outfin

call=$(echo ~/junk/outfin)

time mgmt_cli add host --batch "$call" -s "$session"

##################

echo ""
printf "${GREEN}Do you want to add newly created host objects to a group/groups?(y/n): ${END}"
read groupinput

if [ "$groupinput" = "y" ]; then

        printf "\n1. Single Group"
        printf "\n2. Multiple Groups"
	  echo ""
        printf "${GREEN}\nSelect option from above[1/2]: ${END}"
read groupoption

        if [ "$groupoption" = "1" ]; then

printf "\n${GREEN}Enter group name: ${END}"
read name1

printf "$name1,%s\n" $(< $file) > ~/junk/iplistout

sed -i '1s/^/name,members.add \n/' ~/junk/iplistout

callout=$(echo ~/junk/iplistout)

time mgmt_cli set group --batch "$callout" -s "$session"

change

fi

        if [ "$groupoption" = "2" ]; then

printf "\n${GREEN}Enter filename containing list of group names: ${END}"
read groupfile

awk -v OFS="," -v ORS="\r\n" '
    NR==FNR && NF>0 {a[++n]=$0; next}
    NF>0 {for (i=1; i<=n; i++) print $0, a[i]}
' $file $groupfile > ~/junk/compactlist

sed -i '1s/^/name,members.add \n/' ~/junk/compactlist

deck1=$(echo ~/junk/compactlist)

time mgmt_cli set group --batch "$deck1" -s "$session"

change

fi

fi

if [ "$groupinput" = "n" ]; then

change

fi

}

###############################################################################################
###############################################################################################

networkcreator()
{

printf "\nEnter following details to create API compatible file:"
echo ""
printf "\n"
printf "${GREEN}Filename containing list of Network: ${END}"
read list2

grep -v '^[[:space:]]*$' $list2 > ~/junk/sortedlist2

blank2=$(echo ~/junk/sortedlist2)

printf "${GREEN}Word that needs to get combined with the above list(eg.,NET_): ${END}"
read tmp2
printf "${GREEN}Filename containing list of mask length(eg.,(16,24)): ${END}"
read mask2

grep -v '^[[:space:]]*$' $mask2 > ~/junk/sortedmask2

blankmask2=$(echo ~/junk/sortedmask2)

printf "$tmp2%s\n" $(< $blank2) > ~/junk/iplist2

file2=$(echo ~/junk/iplist2)

paste -d, $file2 $blank2 $blankmask2 > ~/junk/outfin2

sed -i '1s/^/name,subnet,mask-length \n/' ~/junk/outfin2

call2=$(echo ~/junk/outfin2)

time mgmt_cli add network --batch "$call2" -s "$session"

##################

echo ""
printf "${GREEN}Do you want to add newly created network objects to a group/groups?(y/n): ${END}"
read groupinput2

if [ "$groupinput2" = "y" ]; then

        printf "\n1. Single Group"
        printf "\n2. Multiple Groups"
	  echo ""
        printf "${GREEN}\nSelect option from above[1/2]: ${END}"
read groupoption2

        if [ "$groupoption2" = "1" ]; then

printf "\n${GREEN}Enter group name: ${END}"
read name2

printf "$name2,%s\n" $(< $file2) > ~/junk/iplistout2

sed -i '1s/^/name,members.add \n/' ~/junk/iplistout2

callout2=$(echo ~/junk/iplistout2)

time mgmt_cli set group --batch "$callout2" -s "$session"

change

fi

        if [ "$groupoption2" = "2" ]; then

printf "\n${GREEN}Enter filename containing list of group names: ${END}"
read groupfile2

awk -v OFS="," -v ORS="\r\n" '
    NR==FNR && NF>0 {a[++n]=$0; next}
    NF>0 {for (i=1; i<=n; i++) print $0, a[i]}
' $file2 $groupfile2 > ~/junk/compactlist2

sed -i '1s/^/name,members.add \n/' ~/junk/compactlist2

deck2=$(echo ~/junk/compactlist2)

time mgmt_cli set group --batch "$deck2" -s "$session"

change

fi

fi

if [ "$groupinput3" = "n" ]; then

change

fi

}

###############################################################################################
###############################################################################################

tcpcreator()
{

printf "\nEnter following details to create API compatible file:\n"

printf "\n${GREEN}Filename containing list of TCP ports: ${END}"

read list3

grep -v '^[[:space:]]*$' $list3 > ~/junk/sortedlist3

blank3=$(echo ~/junk/sortedlist3)

printf "${GREEN}Word that needs to get combined with the above list(eg.,TCP_): ${END}"

read tmp3

printf "$tmp3%s\n" $(< $blank3) > ~/junk/iplist3

file3=$(echo ~/junk/iplist3)

paste -d, $file3 $blank3 > ~/junk/outfin3

sed -i '1s/^/name,port \n/' ~/junk/outfin3

call3=$(echo ~/junk/outfin3)

time mgmt_cli add service-tcp --batch "$call3" -s "$session"

##################

echo ""
printf "${GREEN}Do you want to add newly created service objects to a group/groups?(y/n): ${END}"
read groupinput3

if [ "$groupinput3" = "y" ]; then

        printf "\n1. Single Group"
        printf "\n2. Multiple Groups"
	  echo ""
        printf "${GREEN}\nSelect option from above[1/2]: ${END}"
read groupoption3

        if [ "$groupoption3" = "1" ]; then

printf "\n${GREEN}Enter group name: ${END}"
read name3

printf "$name3,%s\n" $(< $file3) > ~/junk/iplistout3

sed -i '1s/^/name,members.add \n/' ~/junk/iplistout3

callout3=$(echo ~/junk/iplistout3)

time mgmt_cli set service-group --batch "$callout3" -s "$session"

change

fi

        if [ "$groupoption3" = "2" ]; then

printf "\n${GREEN}Enter filename containing list of group names: ${END}"
read groupfile3

awk -v OFS="," -v ORS="\r\n" '
    NR==FNR && NF>0 {a[++n]=$0; next}
    NF>0 {for (i=1; i<=n; i++) print $0, a[i]}
' $file3 $groupfile3 > ~/junk/compactlist3

sed -i '1s/^/name,members.add \n/' ~/junk/compactlist3

deck3=$(echo ~/junk/compactlist3)

time mgmt_cli set service-group --batch "$deck3" -s "$session"

change

fi

fi

if [ "$groupinput3" = "n" ]; then

change

fi

}

###############################################################################################
###############################################################################################

udpcreator()
{

printf "\nEnter following details to create API compatible file:"
printf "\n"
printf "\n${GREEN}Filename containing list of UDP ports: ${END}"

read list4

grep -v '^[[:space:]]*$' $list4 > ~/junk/sortedlist4

blank4=$(echo ~/junk/sortedlist4)

printf "${GREEN}Word that needs to get combined with the above list(eg.,UDP_): ${END}"

read tmp4

printf "$tmp4%s\n" $(< $blank4) > ~/junk/iplist4

file4=$(echo ~/junk/iplist4)

paste -d, $file4 $blank4 > ~/junk/outfin4

sed -i '1s/^/name,port \n/' ~/junk/outfin4

call4=$(echo ~/junk/outfin4)

time mgmt_cli add service-udp --batch "$call4" -s "$session"

##################

echo ""
printf "${GREEN}Do you want to add newly created service objects to a group/groups?(y/n): ${END}"
read groupinput4

if [ "$groupinput4" = "y" ]; then

        printf "\n1. Single Group"
        printf "\n2. Multiple Groups"
	  echo ""
        printf "${GREEN}\nSelect option from above[1/2]: ${END}"
read groupoption4

        if [ "$groupoption4" = "1" ]; then

printf "\n${GREEN}Enter group name: ${END}"
read name4

printf "$name4,%s\n" $(< $file4) > ~/junk/iplistout4

sed -i '1s/^/name,members.add \n/' ~/junk/iplistout4

callout4=$(echo ~/junk/iplistout4)

time mgmt_cli set service-group --batch "$callout4" -s "$session"

change

fi

        if [ "$groupoption4" = "2" ]; then

printf "\n${GREEN}Enter filename containing list of group names: ${END}"
read groupfile4

awk -v OFS="," -v ORS="\r\n" '
    NR==FNR && NF>0 {a[++n]=$0; next}
    NF>0 {for (i=1; i<=n; i++) print $0, a[i]}
' $file4 $groupfile4 > ~/junk/compactlist4

sed -i '1s/^/name,members.add \n/' ~/junk/compactlist4

deck4=$(echo ~/junk/compactlist4)

time mgmt_cli set service-group --batch "$deck4" -s "$session"

change

fi

fi

if [ "$groupinput4" = "n" ]; then

change

fi

}

###############################################################################################
###############################################################################################

groupadder()
{

echo ""
box_out "Note:" " " "1. This option requires input file which is ready to execute." "2. File should only contain name of objects that needs to be added in a group" "3. List of group should only contain names of groups." "4. Add Objects to group or groups : name,members.add"

        printf "\n1. Object Group"
        printf "\n2. Service Group"
        printf "\n3. Return to Sub Menu"
	  echo ""
        printf "${GREEN}\nSelect option from above to continue[1-3]: ${END}"
read groupinput5

if [ "$groupinput5" = "1" ]; then

        printf "\n1. Single Group"
        printf "\n2. Multiple Groups"
	  echo ""
        printf "${GREEN}\nSelect option from above[1/2]: ${END}"
read groupoption51

        if [ "$groupoption51" = "1" ]; then

printf "\n${GREEN}Enter filename containing list of IP object names: ${END}"
read file51

grep -v '^[[:space:]]*$' $file51 > ~/junk/sortedlist51

blank51=$(echo ~/junk/sortedlist51)

printf "\n${GREEN}Enter group name: ${END}"
read name51

printf "$name51,%s\n" $(< $blank51) > ~/junk/iplistout51

sed -i '1s/^/name,members.add \n/' ~/junk/iplistout51

callout51=$(echo ~/junk/iplistout51)

time mgmt_cli set group --batch "$callout51" -s "$session"

change

fi

        if [ "$groupoption51" = "2" ]; then

printf "\n${GREEN}Enter filename containing list of IP object names: ${END}"
read file512

printf "${GREEN}Enter filename containing list of group names: ${END}"
read groupfile51

awk -v OFS="," -v ORS="\r\n" '
    NR==FNR && NF>0 {a[++n]=$0; next}
    NF>0 {for (i=1; i<=n; i++) print $0, a[i]}
' $file512 $groupfile51 > ~/junk/compactlist51

sed -i '1s/^/name,members.add \n/' ~/junk/compactlist51

deck51=$(echo ~/junk/compactlist51)

time mgmt_cli set group --batch "$deck51" -s "$session"

change

fi

fi

if [ "$groupinput5" = "2" ]; then

        printf "\n1. Single Group"
        printf "\n2. Multiple Groups"
	  echo ""
        printf "${GREEN}\nSelect option from above[1/2]: ${END}"
read groupoption52

        if [ "$groupoption52" = "1" ]; then

printf "${GREEN}Enter filename containing list of Service object names: ${END}"
read file52

grep -v '^[[:space:]]*$' $file52 > ~/junk/sortedlist52

blank52=$(echo ~/junk/sortedlist52)

printf "\n${GREEN}Enter service group name: ${END}"
read name52

printf "$name52,%s\n" $(< $blank52) > ~/junk/iplistout52

sed -i '1s/^/name,members.add \n/' ~/junk/iplistout52

callout52=$(echo ~/junk/iplistout52)

time mgmt_cli set service-group --batch "$callout52" -s "$session"

change

fi

        if [ "$groupoption52" = "2" ]; then

printf "\n${GREEN}Enter filename containing list of Service object names: ${END}"
read file522

printf "${GREEN}Enter filename containing list of group names: ${END}"
read groupfile52

awk -v OFS="," -v ORS="\r\n" '
    NR==FNR && NF>0 {a[++n]=$0; next}
    NF>0 {for (i=1; i<=n; i++) print $0, a[i]}
' $file522 $groupfile52 > ~/junk/compactlist52

sed -i '1s/^/name,members.add \n/' ~/junk/compactlist52

deck52=$(echo ~/junk/compactlist52)

time mgmt_cli set service-group --batch "$deck52" -s "$session"

change

fi

fi

if [ "$groupinput5" = "3" ]; then

creaddobject

fi

}

###############################################################################################
###############################################################################################

exportobject()
{

exportobject=("Export objects from network group" "Export objects from multiple network groups at once" "Export objects from service group" "Export objects from multiple service groups at once" "Main Menu" "Quit program")

box_out "Note:" " " "If creating .csv file manually, make sure to use below parameters:" "2. Export objects from multiple groups at once: name" "4. Export objects from multiple service groups at once: name"

# Define the folder name you're looking for
folder_name="exported_files"

# Check if the folder exists
if [ ! -d "$folder_name" ]; then
  # Folder doesn't exist, create it
  mkdir "$folder_name"
fi

clock="$(date | awk '{$1=""; print $4}' | sed 's/:/_/g')"

printf "\nSelect option: \n"
echo ""
select exportmenu in "${exportobject[@]}"; do


if [ "$exportmenu" = "Export objects from network group" ]; then
exgroup

elif [ "$exportmenu" = "Export objects from multiple network groups at once" ]; then
exgroups

elif [ "$exportmenu" = "Export objects from service group" ]; then
svcgroup

elif [ "$exportmenu" = "Export objects from multiple service groups at once" ]; then
svcgroups

elif [ "$exportmenu" = "Main Menu" ]; then
mainmenu

elif [ "$exportmenu" = "Quit program" ]; then
        quit
        else
                echo  "That's not a valid option! Hit ENTER to show menu"
        fi
        done
}

###############################################################################################
###############################################################################################

exgroup()
{

printf "${GREEN}\nEnter group name: ${END}"
read groupname

printf "\n1. IPv4 Member Details"
printf "\n2. IPv6 Member Details"
printf "\n3. Both"

printf "\n${GREEN}Select option from above to continue [1-3]: ${END}"
read detail
spin=$(printf "${CYAN}\nExporting Data ...${END}")
copy
#sleep 5
printf "\n"
if [ "$detail" = "1" ]; then
echo object-name,ipv4-address,ipv4-address-first,ipv4-address-last,subnet4,mask-length4 > ./exported_files/IPv4-$groupname-$today-$clock.csv
time mgmt_cli -r true show group name "$groupname" --format json | jq --raw-output '.members[] | "\(.name),\(."ipv4-address"),\(."ipv4-address-first"),\(."ipv4-address-last"),\(.subnet4),\(."mask-length4")"' | sed  's/null/X/g' >> ./exported_files/IPv4-$groupname-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/IPv4-$groupname-$today-$clock.csv".
echo ""
fi


if [ "$detail" = "2" ]; then
echo object-name,ipv6-address,ipv6-address-first,ipv6-address-last,subnet6,mask-length6 > ./exported_files/IPv6-$groupname-$today-$clock.csv
time mgmt_cli -r true show group name "$groupname" --format json | jq --raw-output '.members[] | "\(.name),\(."ipv6-address"),\(."ipv6-address-first"),\(."ipv6-address-last"),\(.subnet6),\(."mask-length6")"' | sed  's/null/X/g' >> ./exported_files/IPv6-$groupname-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/IPv6-$groupname-$today-$clock.csv".
echo ""
fi

if [ "$detail" = "3" ]; then
echo object-name,ipv4-address,ipv4-address-first,ipv4-address-last,subnet4,mask-length4,ipv6-address,ipv6-address-first,ipv6-address-last,subnet6,mask-length6 > ./exported_files/$groupname-$today-$clock.csv
time mgmt_cli -r true show group name "$groupname" --format json | jq --raw-output '.members[] | "\(.name),\(."ipv4-address"),\(."ipv4-address-first"),\(."ipv4-address-last"),\(.subnet4),\(."mask-length4"),\(."ipv6-address"),\(."ipv6-address-first"),\(."ipv6-address-last"),\(.subnet6),\(."mask-length6")"' | sed  's/null/X/g' >> ./exported_files/$groupname-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/$groupname-$today-$clock.csv".
echo ""
fi


}

###############################################################################################
###############################################################################################

exgroups()
{

printf "${GREEN}\nFilename containing list of groupname: ${END}"
read listed

printf "%s\n" $(< $listed) > namelist

sed -i '1s/^/name \n/' namelist

caller=$(echo namelist)

printf "\n1. IPv4 Member Details"
printf "\n2. IPv6 Member Details"
printf "\n3. Both"



printf "${GREEN}\nSelect option from above to continue [1-3]: ${END}"
read detail
spin=$(printf "${CYAN}\nExporting Data ...${END}")
copy

printf "\n"
if [ "$detail" = "1" ]; then
echo group-name,object-name,ipv4-address,ipv4-address-first,ipv4-address-last,subnet4,mask-length4 > ./exported_files/IPv4-$listed-$today-$clock.csv
time mgmt_cli -r true show group --batch "$caller" --format json | jq --raw-output '.response[] | "\(.name),\(.members[] | "\(.name),\(."ipv4-address"),\(."ipv4-address-first"),\(."ipv4-address-last"),\(.subnet4),\(."mask-length4")")"' | sed  's/null/X/g' >> ./exported_files/IPv4-$listed-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/IPv4-$listed-$today-$clock.csv".
echo ""
fi


if [ "$detail" = "2" ]; then
echo group-name,object-name,ipv6-address,ipv6-address-first,ipv6-address-last,subnet6,mask-length6 > ./exported_files/IPv6-$listed-$today-$clock.csv
time mgmt_cli -r true show group --batch "$caller" --format json | jq --raw-output '.response[] | "\(.name),\(.members[] | "\(.name),\(."ipv6-address"),\(."ipv6-address-first"),\(."ipv6-address-last"),\(.subnet6),\(."mask-length6")")"' | sed  's/null/X/g' >> ./exported_files/IPv6-$listed-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/IPv6-$listed-$today-$clock.csv".
echo ""
fi

if [ "$detail" = "3" ]; then
echo group-name,object-name,ipv4-address,ipv4-address-first,ipv4-address-last,subnet4,mask-length4,ipv6-address,ipv6-address-first,ipv6-address-last,subnet6,mask-length6 > ./exported_files/$listed-$today-$clock.csv
time mgmt_cli -r true show group --batch "$caller" --format json | jq --raw-output '.response[] | "\(.name),\(.members[] | "\(.name),\(."ipv4-address"),\(."ipv4-address-first"),\(."ipv4-address-last"),\(.subnet4),\(."mask-length4"),\(."ipv6-address"),\(."ipv6-address-first"),\(."ipv6-address-last"),\(.subnet6),\(."mask-length6")")"' | sed  's/null/X/g' >> ./exported_files/$listed-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/$listed-$today-$clock.csv".
echo ""
fi

}

###############################################################################################
###############################################################################################

svcgroup()
{

printf "${GREEN}\nEnter service group name: ${END}"
read svcgroupname
spin=$(printf "${CYAN}\nExporting Data ...${END}")
copy
printf "\n"

echo object-name,service-type,port > ./exported_files/$svcgroupname-$today-$clock.csv
time mgmt_cli -r true show service-group name "$svcgroupname" --format json | jq --raw-output '.members[] | "\(.name),\(.type),\(.port)"' | sed  's/null/X/g' >> ./exported_files/$svcgroupname-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/$svcgroupname-$today-$clock.csv".
echo ""

}

###############################################################################################
###############################################################################################

svcgroups()
{

printf "${GREEN}\nFilename containing list of groupname: ${END}"
read svcgrouplist
spin=$(printf "${CYAN}\nExporting Data ...${END}")
copy
printf "%s\n" $(< $svcgrouplist) > grouplist

sed -i '1s/^/name \n/' grouplist

groupcaller=$(echo grouplist)

printf "\n"

echo group-name,object-name,service-type,port > ./exported_files/$svcgrouplist-$today-$clock.csv
time mgmt_cli -r true show service-group --batch "$groupcaller" --format json | jq --raw-output '.response[] | "\(.name),\(.members[] | "\(.name),\(.type),\(.port)")"' | sed  's/null/X/g' >> ./exported_files/$svcgrouplist-$today-$clock.csv
echo -n "Check locally with the filename ./exported_files/$svcgrouplist-$today-$clock.csv".
echo ""

}

###############################################################################################
###############################################################################################
##WELCOME################
#########################
##START WELCOME MESSAGE##
###############################################################################################
###############################################################################################
clear
cat << !

          ____ _               _                _       _
         / ___| |__   ___  ___| | ___ __   ___ (_)_ __ | |_
        | |   | '_ \ / _ \/ __| |/ / '_ \ / _ \| | '_ \| __|
        | |___| | | |  __/ (__|   <| |_) | (_) | | | | | |_
         \____|_| |_|\___|\___|_|\_\ .__/ \___/|_|_| |_|\__|
                                   |_|
  ___  _     _           _     _____            _
 / _ \| |__ (_) ___  ___| |_  | ____|_  ___ __ | | ___  _ __ ___ _ __
| | | | '_ \| |/ _ \/ __| __| |  _| \ \/ / '_ \| |/ _ \| '__/ _ \ '__|
| |_| | |_) | |  __/ (__| |_  | |___ >  <| |_) | | (_) | | |  __/ |
 \___/|_.__// |\___|\___|\__| |_____/_/\_\ .__/|_|\___/|_|  \___|_|
          |__/                           |_|


!


printf "       \e[0;30m\e[106m  Checkpoint Object Explorer. Author: @Vaibhav_Masane  \e[0m\n"

###############################################################################################
###############################################################################################

banner()
{
  echo "            +------------------------------------------+"
  printf "            |      %s        |\n" "`date`"
  echo "            +------------------------------------------+"
}
banner ""

###############################################################################################
###############################################################################################

today="$(date +%d-%m-%Y)"

###############################################################################################
###############################################################################################

###############################################################################################
###############################################################################################

cat << !

                              Note:
 "This script will help to create host IP objects,Network subnets,
  and TCP/UDP services in bulk. Also with this script, one can add
  or extract bulk objects in/from one or more groups at once.If
  for any reason you make a typo and need to exit use CTRL+C."

!

###############################################################################################
###############################################################################################

echo ""

printf "Press ENTER to continue..."
read ANYKEY

sleep 1

mainmenu

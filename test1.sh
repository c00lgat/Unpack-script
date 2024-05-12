#!/bin/bash


function check_if_verbose(){
	if [[ "$1" == *"-v"* ]];
	then
		echo "Unpacking $2..."
		return 1
	fi
}


param="-"
file="file.txt"
output=$(echo $(check_if_verbose "$param" "$file"))
check_if_verbose_status=$?
echo $check_if_verbose_status
echo $output


echo $(check_if_verbose "$param" "$file")



#!/bin/bash

args=("$@")

# Runs the 'file' command on the input, determines the file type by isolating the second field of the output using awk.
function get_file_type(){
	echo $(file $1) | awk '{print $2}'
}

# Checks if the pattern '-v' was entered by the user. Accordingly, it determines if the output should be verbose.
function check_if_verbose(){
	# $1 - command options (-r, -v). used to check if the "-v" option was used
	# $2 - file to be uncompressed/unpacked
	# $3 - file to ignore
	#if [[ "$1" == *"-v"* ]];
	#then
	#	echo "Unpacking $2..."
	#fi
	
	if [[ "$3" == "-flag"  && "$1" == *"-v"* ]];
	then
		echo "Ignoring $2..."
	else 
		echo "Unpacking $2..."
	fi
}

# Checks if the pattern '-r' was entered by the user. Accordingly, it determines if the unpacking should be recursive or not; in cases of folders.
function check_if_recursive() {
	# $1 = command options (-r, -v). used to check if the "-r" option was used
	if [[ "$1" == *"-r"* ]];
	then
		echo 1
	else
		echo 0
	fi
}

# Saves the command options (-v, -r) in a variable, for ease of use. Parses the console options entered
function check_positional_argument(){
	command_options=""
	if [[ ${args[0]} == "-v" || ${args[0]} == "-r" ]]
	then
		command_options="${command_options}${args[0]}"
	fi

	if [[ ${args[1]} == "-v" || ${args[1]} == "-r" ]]
	then
		command_options="${command_options} ${args[1]}"
	fi

	echo "$command_options"
}

function decompress_logic() {
	# $1 is the passed command options, if any (-r, -v)
	# $2 is the positional console argument (file names passed through the command line) or in the case of directory unpack, is the files inside the directory
	# $3 is the FILETYPE of each positional console argument
	# $4 is a directory flag
	case "$3" in
			"gzip")
				# The line of code below uses the built in -v option, but since the assignment asks for a simple implementation, i will simply print "Unpacking file..." instead, thus is why directing the stdout to the /dev/null as with the rest of the cases.
				gunzip "$check_command_options" "$2" 1> /dev/null
				# Using the custom verbose option by calling the function check_if_verbose and then pasting the value we got from the function
				echo $(check_if_verbose "$check_command_options" "$2")

				archive_counter=$((archive_counter + 1))
				;;
			"bzip2")
				bunzip2 "$check_command_options" "$2" 1> /dev/null
				echo $(check_if_verbose "$check_command_options" "$2")
				archive_counter=$((archive_counter + 1))
				;;
			"Zip")
				unzip "$check_command_options" "$2" 1> /dev/null
				echo $(check_if_verbose "$check_command_options" "$2")
				archive_counter=$((archive_counter + 1))
				;;
			"compress'd")
				gunzip -S "$(echo $2 | awk -F'\\.' '{print $2}')" "$check_command_options" "$2" 1> /dev/null
				echo $(check_if_verbose "check_command_options" "$2")
				archive_counter=$((archive_counter + 1))
				;;
			"directory")
				directory_unpack $1 $2			
				;;
			*)
				echo $(check_if_verbose "$check_command_options" "${2}" "-flag")
				uncompressed_files_counter=$((uncompressed_files_counter + 1))
	esac

}

function directory_unpack() {
	# $1 the passed command options, if any (-r -v)
	# $2 folder name
	
	if [[ $(check_if_recursive "$1" -eq 1) ]]
	then
		for file in $(find "$2" -type f -exec echo "{}" \;)
		do
			decompress_logic "$1" "$file" "$(get_file_type "$file")"
		done

	else
		for file in $(find "$2" -maxdepth 1 -type f -exec echo "{}" \;)
		do
			decompress_logic "$1" "$file" "$(get_file_type "$file")"
		done
	fi
}

check_command_options=$(check_positional_argument)

number_of_command_options=$(echo "$check_command_options" | awk -F ' ' '{print NF}')

archive_counter=0
uncompressed_files_counter=0
for i in $(seq $((number_of_command_options + 1)) $#)
	do
	FILETYPE=$(get_file_type "${!i}")
	if [[ -e "${!i}" ]];
	then
		decompress_logic "$check_command_options" "${!i}" "$FILETYPE"
	else
		echo "File/folder "${!i}" does not exist."
		exit 1
	fi
done

echo "Decompressed $archive_counter archive(s)"
echo "Ignored $uncompressed_files_counter file(s)"

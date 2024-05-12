#!/bin/bash


for i in $@; do
	FILE_EXTENSION=$(file $i)
	echo $FILE_EXTENSION
done

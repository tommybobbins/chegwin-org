#!/bin/bash

for FILE in *
do
SFILE=$(echo $FILE | sed 's/_(DocTitle)_/_/g') 
echo mv \'$FILE\' $SFILE
mv $FILE $SFILE
###mv $FILE $SFILE
done

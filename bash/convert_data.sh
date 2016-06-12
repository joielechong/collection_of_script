#/bin/bash
####################################################################
# Extract all sheet from spreadsheet file (.ods) and convert it
# to csv file.
# 
# Dependency: 	LibreOffice for converting ods to xls file
#		excel2csv for converting xls to csv.
#
# Copyright by Juan Rio Sipayung, 11 June 2016, Saturday.
# License under Apache License v2.	
####################################################################

DATA_DIRECTORY=data;
XLS_DIRECTORY=xls;
TOTAL_SHEET=20;
DEST_FILE_TYPE=xls;
SOURCE_FILE_TYPE=ods;
GENERATED_FILE_TYPE=csv;


# Check if LibreOffice is running
if pgrep "soffice" > /dev/null
then
    echo "LibreOffice is running, please close it first.";
    echo "script will terminated.";
    exit;
fi

echo '---------------------------'
echo 'converting to xls...'
for i in *.$SOURCE_FILE_TYPE; 
  do  soffice --headless --convert-to $DEST_FILE_TYPE "$i" ; 
done

echo 'Moving xls file to folder...'
if [ ! -d "$XLS_DIRECTORY" ]; then
  mkdir $XLS_DIRECTORY;
else
  rm -f $XLS_DIRECTORY;
  mkdir $XLS_DIRECTORY;
fi

mv *.$DEST_FILE_TYPE $XLS_DIRECTORY;

echo 'Go to xls folder..'
cd $XLS_DIRECTORY;

echo 'converting to csv...'
if [ ! -d "$DATA_DIRECTORY" ]; then
  mkdir $DATA_DIRECTORY;
else
  rm -f $DATA_DIRECTORY;
  mkdir $DATA_DIRECTORY;
fi

#Must substract 1 because sheet index start from 0 in excel2csv.jar arguments.
TOTAL_SHEET=$((TOTAL_SHEET-1));

for xlsFile in *.$DEST_FILE_TYPE;
do
  #get file name
  filename=$(basename $xlsFile);
  filename="${filename%.*}";
  #echo $filename;
  
  # our file is in format like 01-20.ods, 21-40.ods, 41-60.ods, etc
  # so we need to remove the last part after -, then we get: 01, 21, 41.
  startNumber="${filename%-*}";
  #echo $startNumber;
  #then we need to get the integer value
  number="${startNumber//[A-Z]/}";
  #echo $numberYY;
  
  echo "Processing file $xlsFile";
 
  for i in `seq 0 $TOTAL_SHEET`;
  do
    echo "   -> Process sheet $number";
  #  echo "processing sheet $1";
    java -jar ../excel2csv.jar -i $i $xlsFile $DATA_DIRECTORY/$number.$GENERATED_FILE_TYPE;
    number=$(($number+1));
  done
done  


cd $DATA_DIRECTORY;

theBiggestNumber=0;
#check the biggest number in file list
for genFile in *.$GENERATED_FILE_TYPE;
do
  number="${genFile%.*}";
  if [ "$number" -gt "$theBiggestNumber" ]; then
    theBiggestNumber=$number;
  fi
done

#check missing generated file
for i in `seq 1 $theBiggestNumber`;
do
  genFile=$i.$GENERATED_FILE_TYPE;
  if [ ! -f "$genFile" ]; then
    genFile="${genFile%.*}";
    echo "data $genFile not found";
  fi
done
BIGGEST_NUMBER=0;
#check the biggest number in file list
for genFile in *.csv;
do
  number="${genFile%.*}";
  if [ "$number" -gt "$BIGGEST_NUMBER" ]; then
    BIGGEST_NUMBER=$number;
  fi
  
done

echo "the biggest number = $BIGGEST_NUMBER";

#check missing generated file
for i in `seq 1 $BIGGEST_NUMBER`;
do
  file=$i.csv;
  if [ ! -f "$file" ]; then
    echo "file $file not found";
  fi
done 

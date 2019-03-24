cd zone

for f in *
do
  while read domain; do
    FIRST=`echo "$domain" | awk '{print $1;}'`
    if [[ $FIRST == *$f ]]; then
      echo $FIRST > /dev/null
    else
      echo $FIRST
      echo "A line in ${f} does not match the domain name!"
      exit 1
    fi
  done <$f
done

exit 0

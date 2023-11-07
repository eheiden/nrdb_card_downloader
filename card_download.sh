#!/bin/bash

declare -a urls=()
declare -a names=()


echo 'Downloading card printing info into cards.json...'

curl -g "https://api-preview.netrunnerdb.com/api/v3/public/printings?fields[printings]=stripped_title&images&page[limit]=3000" | json > cards.json.temp

#move the old cards.json over for safe keeping
if test -f "cards.json"; then
    mv cards.json cards.json.prev
fi

#copy over the temp file to the new cards.json file
mv cards.json.temp ./cards.json

if test -f "urls.txt"; then
    mv urls.txt urls.txt.last
fi

echo 'Creating urls.txt...'

#get all of the image urls, store them in array $urls()
for URL in $(curl -g "https://api-preview.netrunnerdb.com/api/v3/public/printings?fields[printings]=images&page[limit]=3000" | jq '.data[].attributes.images.nrdb_classic.large' | sed -e 's/"//g');
do urls+=($URL);
done

#get all of the image titles, store them in array $names()
for NAME in $(curl -g "https://api-preview.netrunnerdb.com/api/v3/public/printings?fields[printings]=card_id&page[limit]=3000" | jq '.data[].attributes.card_id' | sed -e 's/"//g');
do names+=($NAME);
done

# iterate through the urls and output the url and # the title into a file we'll feed to curl as a config file later

len=${#urls[@]}

for(( i=0; i<${len}; i++ )); do
	echo "url = \"${urls[$i]}\"";
	echo "output = \"${names[$i]}.jpg\"";
done > urls.txt

curl --parallel --parallel-max 15 --config urls.txt

if test -f "urls.txt.last"; then
	rm urls.txt.last
fi
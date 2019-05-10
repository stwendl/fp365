#!/bin/bash

# Copyright Pacifc Comnex, 2019


# node.js per
# https://github.com/nodejs/help/wiki/Installation

# O365 acces per
# https://pnp.github.io/office365-cli/

# resources from directory per 
# https://docs.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0#properties

# image editor 
# https://www.iloveimg.com

# Region marker
# create CityName-suite.html from the sample LosAltos-200.html
# edit the filename of the .png file to use as back ground
# edit locations. You can use the map and hover over a location to get the coordinates, when done comment the coordinates code out.
# png file created from pdf file on a mac, then saved as png file, and cropped with online png cropping tool from https://www.iloveimg.com
# then upload to mailgw:/usr/share/nginx/html/ as CityName-suite.png

# path for nginx installation html document root 
L=/usr/share/nginx/html/fp365

# path for example data  -- comment for production
L=..

# extract from office365 - uncomment for production
#export PATH=/usr/local/lib/nodejs/node-v10.15.3-linux-x64/bin/:$PATH
#o365 graph user list --properties displayName,mail,officeLocation,mobilePhone,jobTitle > $L/var/current.dat

#Create Example code - comment for production
echo "displayName                   mail                                   officeLocation      mobilePhone    jobTitle" >       $L/var/current.dat
echo "----------------------------  -------------------------------------  ------------------  -------------  --------" >>      $L/var/current.dat 
echo "Test User                     test.user@example.com                  CityName,Suite,123  555-123-4567   Administrator" >> $L/var/current.dat    


diff $L/var/current.dat $L/var/last.dat > /dev/null
if [ $? -eq 0 ]; then
	# no change in directory - no more processing needed
	exit
fi

# make current data the active
mv $L/var/current.dat $L/var/last.dat

# extract data from o365
# create index.html file
{
	# write header
	echo "<HTML><head><meta name=\"Author\" content=\"Directory\">  <title>Directory</title></HEAD>"
	echo "<body text=\"#000000\" bgcolor=\"#FFFFFF\" link=\"#0000A0\" vlink=\"#000099\" alink=\"#FF0000\">"
	echo "<h1>Company Directory</h1>"
	echo '<table class="fixed_header" border=1  cellpading=0 cellspacing=0>'
	echo '<thead><tr><th>Name</th><th>Email</th><th>Mobile</th><th>Title</th><th>Location</th></tr></thead><tbody>'

	# process data and format and create index.html
	sed 's/ \+ /:/g' < $L/var/last.dat | tail -n +3 | awk -F: '{if ($6 == 'true' && $3 != "null" && $1 != "") {if($3=="null"){URL=""} else {R=$3;split(R,RA,","); C+=1; URL=sprintf("href=\"http://mailgw/fp365/%s/%s/?desk=%s\"",RA[1],RA[2],RA[3])};printf "<tr bgcolor=%s><td align=left>%s</td><td align=left>%s</td><td align=right>%s</td><td align=right>%s</td><td align=right><a %s>%s</a></td></tr>\n",C%2 ? "white" : "lightblue", $1, $2, $4=="null" ? "" : $4, $5=="null" ? "" : $5, $3=="null"?"":URL, $3=="null"? "" : $3}}'

	# write trailer
	echo '<tr><td align=left colspan=3><small>Created on mailgw by crontab. Copyright Pacific Comnex 2019, All Rights Reserved</small></td><td align=right colspan=2><small>Date: '
	date
	echo '</small></td></tr></table></small>'
	echo '</tbody></table>'
	echo '</html>'
} > $L/index.html


# now create subdirectories if they don't exist and populate with prototype index.html and proto.png

for s in `sed 's/ \+ /:/g' < $L/var/last.dat | tail -n +3 | awk -F:  '{print $3}' | grep -v null | awk -F, '{ if (NF == 3) print $1}' | sort -u` ; do 
	if [ ! -d $L/$s ]; then
		mkdir $L/$s
	fi
	for r in `sed 's/ \+ /:/g' < $L/var/last.dat | tail -n +3 | grep $s | awk -F:  '{print $3}' | grep -v null | awk -F, '{ if (NF == 3) print $2}' | sort -u` ; do 
		if [ ! -d $L/$s/$r ]; then
			mkdir $L/$s/$r
			cp $L/etc/proto.html $L/$s/$r/index.html
			cp $L/etc/proto.png $L/$s/$r/image.png
		fi
	done
done


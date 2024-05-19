#!/usr/bin/env bash
# https://github.com/RapidEdwin08/iattract

ROMdir=~/RetroPie/roms
attractLISTdir=/opt/retropie/configs/all/attractmode/romlists

GLattractLOGO=$(
echo '
              _______________           ______________
             | gamelist.xml  |  ---->  | romlist.txt  |
             | ------------- |         |------------- |
             | ------------- |         |------------- |
             | ------------- |         |------------- |
             | ------------- |         |------------- |
             | ------------- |         |------------- |
             | ------------- |         |------------- |
             | ------------- |         |------------  |
             |_______________|         |______________|                      
'
)
# Function to check if attractmode Installed
checkATTRACTromlist() {
if [[ ! -d $attractLISTdir ]]; then
	dialog --no-collapse --title " [$attractLISTdir] NOT FOUND! " --ok-label CONTINUE --msgbox "Are You Sure [attractmode] is Installed?"  25 75
	GLattractMENU
fi
}

# Function to check if gamelist.xml exists
checkROMgl() {
if [ "$(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename 2>/dev/null )" == '' ]; then
	dialog --no-collapse --title " Found {0} Folders in [$ROMdir] with a [gamelist.xml]" --ok-label CONTINUE --msgbox "$ROMdir [Avail $(df -h $ROMdir |awk '{print $4}' | grep -v Avail )]"  25 75
	GLattractMENU
fi
}

# Function to convert XML file to text file - SupremeTeam
convert_xml_to_text() {
    local xml_file="$1"
    local output_dir="$2"
    local folder_name=$(basename "$(dirname "$xml_file")")

	local tmpFILE=/dev/shm/tmp.xml
	rm $tmpFILE > /dev/null 2>&1
	while read -r line; do
		# Replace New Lines with Space If line does NOT end in >
		if [[ ! "$(echo ${line:(-1)})" == '>' ]] then
			echo $line | tr '\n' ' ' >> $tmpFILE
		else
			# Output the whole line
			echo "$line" >> $tmpFILE
		fi
	done < "$xml_file"
 
    # Remove any file extension from the folder name
    folder_name=${folder_name%.*}
 
    # Define the output file without any file extension
    local output_file="${output_dir}/${folder_name}.txt"
 
    # Write the header to the output file
    echo "#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons" > "$output_file"
 
    # Parse the XML and iterate over each game entry
    xmlstarlet sel -t -m '//game' \
                   -v "concat(substring(path,3),';',name,';${folder_name};;', \
                   (substring(releasedate,1,4)),';',developer,';',genre,';',players,';;;;;;;;;;;;;;;;;;')" \
                   -n "$tmpFILE" | while read -r line; do
        # Parse Only the File name from path # Remove leading './' | Remove everything after First Instance of ; | Remove everything after Last instance of . | Remove the last character . # Obtain the REST after
        linePATH=$(echo "$line" | sed 's/^\.\/\(.*\)\..*$/\1/' | cut -f 1 -d ';' | sed 's+[^.]*$++' | sed 's+.$++')
		lineREST=$(echo "$line" | rev | sed 's+[^;]*$++' | sed 's+.$++' | rev)
        echo "$linePATH;$lineREST" >> "$output_file"
    done
	rm $tmpFILE > /dev/null 2>&1
}
 
GLattractMENU()
{
tput reset
ROMdirCOUNT=$(( $(ls -1 $ROMdir | awk 'NR>2' | wc -l) ))
currentROMglCOUNT=$(( $(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename 2>/dev/null | wc -l) ))
GLattractMAIN=$(dialog --no-collapse --title " Create attractmode [romlist.txt] from [gamelist.xml]" \
	--ok-label OK --cancel-label EXIT \
	--menu "{$currentROMglCOUNT} of {$ROMdirCOUNT} Folders in [$ROMdir] with a gamelist.xml $GLattractLOGO" 25 75 20 \
	1 " SELECT A [gamelist.xml] from [$ROMdir] " \
	2 " SCAN ALL [gamelist.xml] from [$ROMdir]  " \
	3 " SELECT A [ROM] Folder  with [attract --build-romlist] " \
	4 " SCAN ALL [ROM] Folders with [attract --build-romlist] " \
	X " EXIT  " 2>&1>/dev/tty)
if [ "$GLattractMAIN" == 'X' ] || [ "$GLattractMAIN" == '' ]; then tput reset; exit 0; fi
checkATTRACTromlist
if [ "$GLattractMAIN" == '1' ]; then checkROMgl; GLselectMENU; fi
if [ "$GLattractMAIN" == '3' ]; then GLselectMENUattract; fi
if [ "$GLattractMAIN" == '2' ]; then
	checkROMgl
	confSCANall=$(dialog --no-collapse --title " SCAN ALL ROM Folders for [gamelist.xml] " \
		--ok-label OK --cancel-label BACK \
		--menu "                          ? ARE YOU SURE ?             \n{$currentROMglCOUNT} of {$ROMdirCOUNT} Folders in [$ROMdir] with a gamelist.xml" 25 75 20 \
		1 " SCAN ALL [gamelist.xml] from [$ROMdir]  " \
		2 " BACK " 2>&1>/dev/tty)
	if [ "$confSCANall" == '1' ]; then
		tput reset
		for i in $(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename | grep -v 'music' | grep -v 'videos' 2>/dev/null); do
			echo Scanning "$ROMdir/$i"
			convert_xml_to_text "$ROMdir/$i/gamelist.xml" "$attractLISTdir"
		done
		lsROMlist=$(find $attractLISTdir -type f -printf "%f\n" | sort)
		dialog --no-collapse --title "SCAN COMPLETE!  [$attractLISTdir]:        " --ok-label CONTINUE --msgbox "$lsROMlist "  25 75
		GLattractMENU
	fi
GLattractMENU
fi
if [ "$GLattractMAIN" == '4' ]; then
	confSCANall=$(dialog --no-collapse --title " SCAN ALL [ROM] Folders with [attract --build-romlist] " \
		--ok-label OK --cancel-label BACK \
		--menu "                          ? ARE YOU SURE ?             \n{$(find $ROMdir -maxdepth 1 -type d | tail -n +2 | grep -v '/music' | grep -v '/videos' | wc -l)} ROM Folders Found in [$ROMdir]" 25 75 20 \
		1 " SCAN ALL [ROM] Folders with [attract --build-romlist] " \
		2 " BACK " 2>&1>/dev/tty)
	if [ "$confSCANall" == '1' ]; then
		tput reset
		for i in $(find $ROMdir -maxdepth 1 -type d | xargs -n 1 basename | tail -n +2 | grep -v 'music' | grep -v 'videos' | sort 2>/dev/null); do
			if [[ ! "$(ls -1 $ROMdir/$i)" == '' ]]; then attract --build-romlist "$i" -o "$i" 2>/dev/null; fi
		done
		lsROMlist=$(find $attractLISTdir -type f -printf "%f\n" | sort)
		dialog --no-collapse --title "SCAN COMPLETE!  [$attractLISTdir]:        " --ok-label CONTINUE --msgbox "$lsROMlist "  25 75
		GLattractMENU
	fi
GLattractMENU
fi
tput reset
exit 0
}

GLselectMENU()
{
tput reset
checkATTRACTromlist
currentROMglCOUNT=$(( $(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename | grep -v 'music' | grep -v 'videos' 2>/dev/null | wc -l) ))
let i=0 # define counting variable
W=() # define working array
while read -r line; do # process file by file
    let i=$i+1
    W+=($i "$line")
done < <( ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename | grep -v 'music' | grep -v 'videos' 2>/dev/null )
FILE=$(dialog --title " SELECT Folder to Create attractmode [romlist.txt] from [gamelist.xml]" --ok-label " SELECT " --cancel-label BACK --menu "{$currentROMglCOUNT} of {$ROMdirCOUNT} Folders in [$ROMdir] with a gamelist.xml" 25 75 20 "${W[@]}" 3>&2 2>&1 1>&3  </dev/tty > /dev/tty) # show dialog and store output
tput reset
if [ ! "$FILE" == '' ]; then
	selectFILE=$(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename | grep -v 'music' | grep -v 'videos' 2>/dev/null | sed -n "`echo "$FILE p" | sed 's/ //'`")
	if [ -d "$ROMdir/$selectFILE" ]; then
		GLselectSUBmenu=$(dialog --no-collapse --title "              ? ARE YOU SURE ?             " \
		--ok-label OK --cancel-label BACK \
		--menu " Current Selection: [$ROMdir/$selectFILE/gamelist.xml] " 25 75 20 \
		1 "Create attract [romlist.txt] from [$selectFILE/gamelist.xml]" \
		B "BACK  " 2>&1>/dev/tty)
		if [ "$GLselectSUBmenu" == 'B' ] || [ "$GLselectSUBmenu" == '' ]; then GLselectMENU; fi		
		if [ "$GLselectSUBmenu" == '1' ]; then
			tput reset
			echo Scanning "$selectFILE/gamelist.xml"
			convert_xml_to_text "$ROMdir/$selectFILE/gamelist.xml" "$attractLISTdir"
			dialog --no-collapse --title "Create attractmode [romlist.txt] from [$selectFILE/gamelist.xml] COMPLETE!  " --ok-label CONTINUE --msgbox "[$attractLISTdir/$selectFILE.txt]"  25 75
			GLselectMENU
		fi
		GLselectMENU
	fi
fi
GLattractMENU
}

GLselectMENUattract()
{
tput reset
checkATTRACTromlist
let i=0 # define counting variable
W=() # define working array
while read -r line; do # process file by file
    let i=$i+1
    W+=($i "$line")
done < <( find $ROMdir -maxdepth 1 -type d | xargs -n 1 basename | tail -n +2 | grep -v 'music' | grep -v 'videos' | sort 2>/dev/null )
FILE=$(dialog --title " SELECT A [ROM] Folder" --ok-label " SELECT " --cancel-label BACK --menu " Choose a [ROM] Folder to Scan with [attract --build-romlist]" 25 75 20 "${W[@]}" 3>&2 2>&1 1>&3  </dev/tty > /dev/tty) # show dialog and store output
tput reset
if [ ! "$FILE" == '' ]; then
	selectFILE=$(find $ROMdir -maxdepth 1 -type d | xargs -n 1 basename | tail -n +2 | grep -v 'music' | grep -v 'videos' | sort 2>/dev/null | sed -n "`echo "$FILE p" | sed 's/ //'`")
	if [ -d "$ROMdir/$selectFILE" ]; then
		GLselectSUBmenu=$(dialog --no-collapse --title "              ? ARE YOU SURE ?             " \
		--ok-label OK --cancel-label BACK \
		--menu " Current Selection: [$ROMdir/$selectFILE] " 25 75 20 \
		1 "SCAN [$selectFILE] with [attract --build-romlist]" \
		B "BACK  " 2>&1>/dev/tty)
		if [ "$GLselectSUBmenu" == 'B' ] || [ "$GLselectSUBmenu" == '' ]; then GLselectMENUattract; fi		
		if [ "$GLselectSUBmenu" == '1' ]; then
			tput reset
			attract --build-romlist "$selectFILE" -o "$selectFILE"
			dialog --no-collapse --title "Create attractmode [romlist.txt] from [$selectFILE] COMPLETE!  " --ok-label CONTINUE --msgbox "$logVAR [$attractLISTdir/$selectFILE.txt]"  25 75
			GLselectMENUattract
		fi
		GLselectMENUattract
	fi
fi
GLattractMENU
}

GLattractMENU
tput reset
exit 0

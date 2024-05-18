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
# Function to check if gamelist.xml exists and if attractmode Installed
checkATTRACTromlist() {
# Check if NO Files/Folders
if [ "$(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename 2>/dev/null )" == '' ]; then
	dialog --no-collapse --title " Found {0} Folders in [$ROMdir] with a [gamelist.xml]" --ok-label CONTINUE --msgbox "$ROMdir [Avail $(df -h $ROMdir |awk '{print $4}' | grep -v Avail )]"  25 75
	GLattractMENU
fi
# Check if attract/romlist/ Folder Exists
if [[ ! -d $attractLISTdir ]]; then
	dialog --no-collapse --title " [$attractLISTdir] NOT FOUND! " --ok-label CONTINUE --msgbox "Are You Sure [attractmode] is Installed?"  25 75
	GLattractMENU
fi
}

# Function to convert XML file to text file - SupremeTeam
convert_xml_to_text() {
    local xml_file="$1"
    local output_dir="$2"
    local folder_name=$(basename "$(dirname "$xml_file")")
 
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
                   -n "$xml_file" | while read -r line; do
        # Remove leading './' and file extension to obtain Only the path - Obtain the rest after
        linePATH=$(echo "$line" | sed 's/^\.\/\(.*\)\..*$/\1/' | cut -f 1 -d '.')
        lineREST=$(echo "$line" | sed 's/^[^;]*;//' | rev | cut -f 1 -d '.' | rev)
        echo "$linePATH;$lineREST" >> "$output_file"
    done
}
 
# Function to scan a directory for gamelist.xml and process it - SupremeTeam
scan_and_process_game_folder() {
    local roms_dir="$1"
    local romlist_dir="$2"
    echo "Scanning directory for game folders: $roms_dir"
    find "$roms_dir" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' folder; do
        local xml_file="${folder}/gamelist.xml"
        if [[ -f "$xml_file" ]]; then
            echo "Found XML file in folder: $folder"
            convert_xml_to_text "$xml_file" "$romlist_dir"
        else
            echo "No gamelist.xml found in folder: $folder"
        fi
    done
    echo "All folders processed."
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
	X " EXIT  " 2>&1>/dev/tty)
if [ "$GLattractMAIN" == 'X' ] || [ "$GLattractMAIN" == '' ]; then tput reset; exit 0; fi
checkATTRACTromlist
if [ "$GLattractMAIN" == '1' ]; then GLselectMENU; fi
if [ "$GLattractMAIN" == '2' ]; then
	confSCANall=$(dialog --no-collapse --title " SCAN ALL ROM Folders for [gamelist.xml] " \
		--ok-label OK --cancel-label BACK \
		--menu "                          ? ARE YOU SURE ?             \n{$currentROMglCOUNT} of {$ROMdirCOUNT} Folders in [$ROMdir] with a gamelist.xml" 25 75 20 \
		1 " SCAN ALL [gamelist.xml] from [$ROMdir]  " \
		2 " BACK " 2>&1>/dev/tty)
	if [ "$confSCANall" == '1' ]; then
		tput reset
		for i in $(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename 2>/dev/null); do
			echo Scanning "$ROMdir/$i"
			convert_xml_to_text "$ROMdir/$i/gamelist.xml" "$attractLISTdir"
		done
		lsROMlist=$(find $attractLISTdir -type f -printf "%f\n" | sort -n)
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
currentROMglCOUNT=$(( $(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename 2>/dev/null | wc -l) ))
let i=0 # define counting variable
W=() # define working array
while read -r line; do # process file by file
    let i=$i+1
    W+=($i "$line")
done < <( ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename 2>/dev/null )
FILE=$(dialog --title " SELECT Folder to Create attractmode [romlist.txt] from [gamelist.xml]" --ok-label " SELECT " --cancel-label BACK --menu "{$currentROMglCOUNT} of {$ROMdirCOUNT} Folders in [$ROMdir] with a gamelist.xml" 25 75 20 "${W[@]}" 3>&2 2>&1 1>&3  </dev/tty > /dev/tty) # show dialog and store output
tput reset
if [ ! "$FILE" == '' ]; then
	selectFILE=$(ls $ROMdir/*/gamelist.xml 2>/dev/null | rev | cut -c 14- | rev | xargs -n 1 basename 2>/dev/null | sed -n "`echo "$FILE p" | sed 's/ //'`")
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

GLattractMENU
tput reset
exit 0

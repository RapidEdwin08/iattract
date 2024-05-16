#!/bin/bash
 
# Function to convert XML file to text file
convert_xml_to_text() {
    local xml_file=$1
    local output_dir=$2
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
        # Remove leading './' and any file extension from the path
		linePATH=$(echo "$line" | sed 's/^\.\/\(.*\)\..*$/\1/' | cut -f 1 -d '.')
		lineREST=$(echo -n "$line" | sed 's/^[^;]*;//' | rev | cut -f 1 -d '.' | rev)
        echo ""$linePATH";"$lineREST"" >> "$output_file"
    done
}
 
# Function to scan a directory for gamelist.xml and process it
scan_and_process_game_folder() {
    local roms_dir=$1
    local romlist_dir=$2
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
 
# Main menu
PS3='Please select the game folder to scan: '
options=("Scan 'retropie/roms' for gamelist.xml" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Scan 'retropie/roms' for gamelist.xml")
            roms_dir="/home/pi/RetroPie/roms"
            romlist_dir="/opt/retropie/configs/all/attract/romlist"
            mkdir -p "$romlist_dir"
            scan_and_process_game_folder "$roms_dir" "$romlist_dir"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY";;
    esac
done

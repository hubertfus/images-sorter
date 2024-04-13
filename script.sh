#!/bin/bash
if ! command -v exiftool &> /dev/null; then
    echo "installing exiftool packet."
    sudo apt update
    sudo apt upgrade -y libimage-exiftool-perl
    sudo apt install -y libimage-exiftool-perl
    echo "installation complete"
fi

path=$1
path_to_save=$2
search_images_in_directory(){
    for file in "$1"/*; do
    	if [ -d "$file" ]; then
    	    search_images_in_directory "$s1$file"
        elif [[ "$file" == *.jpg || "$file" == *.png ]]; then
            created=$(exiftool  -d "%Y-%m-%d %H:%M:%S" -CreateDate "$file" 2>/dev/null | sed 's/Create Date\s*:\s*//')
           if [[ -z "$created" ]]; then
              created=$(stat -c %y "$file" 2>/dev/null)
           fi
     	   created=$(echo $created | cut -d ' ' -f 1 | sed 's/-/\//g')
    	   mkdir -p "$path_to_save/$created"
    	   cp "$file" "$path_to_save/$created/"
        fi
    done
}
search_images_in_directory "$path"
find "$path_to_save" -type f -exec md5sum {} + | sort | uniq -w32 -d --all-repeated=separate | \
    while read -r md5 file; do
        duplicate_files=($(find "$path_to_save" -type f -exec md5sum {} + | grep "$md5" | awk '{print $2}'))
        for ((i=1;i<${#duplicate_files[@]}; i++)) do
            rm -f "${duplicate_files[i]}"
        done
    done
exit

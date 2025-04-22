# Script backup.sh 

# ENCRYPTION NOTE: Default password of "" is used for this demo script
# For prompting user password -> uncomment the commented two lines 73-74

#!/bin/bash

help() {
    cat << EOF
Backs up a directory as a compressed encrypted file.

Usage:
  $0 <directory> [-c compression] <output>

Parameters (mandatory fields):
  directory : Full path of directory to backup
  output    : Name of output archive file

Options:
  -h, --h   : Help
  -c        : Compression type (gzip, bzip2, xz) [Default: tar]

Examples:
  ./backup.sh /home/user/Documents -c gzip docs_backup
  ./backup.sh /home/user/Documents docs_backup
EOF
}

valid_directory_check() {
    if [ ! -d "$1" ]; then
        echo "Error: Invalid directory: $1" >&2
        exit 1
    fi
}

compression_choice() {
    case "$1" in
        gzip) echo "-czf .tar.gz" ;;
        bzip2) echo "-cjf .tar.bz2" ;;
        xz) echo "-cJf .tar.xz" ;;
        none|"") echo "-cf .tar" ;;
        *) echo "Unsupported compression: $1" >&2; exit 1 ;;
    esac
}

output_filename() {
    local output=$1
    local ext=$2 

    if [ "$output" != *"$ext" ]; then
        echo "${output}${ext}"
    else
        echo "$output"
    fi
}

create_archive() {
    local tar_opts=$1
    local dir=$2
    local temp=$(mktemp)

    tar $tar_opts "$temp" "$dir"
    echo "$temp"
}

encrypt_archive() {
    local in_file=$1
    local out_file=$2

    password=""  # default

    # ### To prompt for user password uncomment the two lines below!
    # echo "Enter encryption password:" > /dev/tty
    # read -s password

    openssl enc -aes-256-cbc -pbkdf2 -salt -in "$in_file" -out "$out_file.enc" -pass pass:"$password"
}

clean_up() {
    rm -f "$1"
}

# -------------- main ----------------
{
    if [ $# -eq 0 ]; then
        help
        exit 1
    fi

    if [[ "$1" == "-h" || "$1" == "--h" ]]; then
        help
        exit 0
    fi

    dir=$1
    valid_directory_check "$dir"

    if [ "$2" == "-c" ]; then
        comp=$3
        output=$4
    else
        comp="none"
        output=$2
    fi
    
    choice=$(compression_choice "$comp") || exit 1
    read tar_opts extension <<< "$choice"
    output=$(output_filename "$output" "$extension")
    temp=$(create_archive "$tar_opts" "$dir")
    encrypt_archive "$temp" "$output" 
    clean_up "$temp"

} 1>/dev/null 2>error.log

# bash-backup-script
Bash script to back up a directory as a compressed encrypted archive.

## Usage
```bash
./backup.sh <directory> [-c compression] <output>

## Parameters:
  directory : Full path of directory to backup
  output    : Name of output archive file

## Options:
  -h, --h   : Help
  -c        : Compression type (gzip, bzip2, xz) [Default: tar]

## Examples:
  ./backup.sh /home/user/Documents -c gzip docs_backup
  ./backup.sh /home/user/Documents docs_backup

## Output
Encrypted archive: `mybackup.tar.xxx.enc`  

## Notes
- Supported compression types `gzip`, `bzip2`, `xz` or none (default `tar`).
- Encryption with OpenSSL (AES-256-CBC + PBKDF2).
- Default password empty (for automation). Option to prompt for user password.
- Errors logged in `error.log`. 
- All non-error output is suppressed.

#!/bin/bash

# this is a script to automatically decrypt a file with gnupg, edit it, and 
# re-encrypt if there are changes.

working_dir=/home/jpkotta/doc
backup_dir=/home/jpkotta/backup
recipient=jpkotta
editor=emacs

plaintext_file=key.txt
crypt_file=${plaintext_file}.gpg
comp_file=${plaintext_file}.back

cd $working_dir

# decrypt the file
# gpg will prompt for password
if /usr/bin/gpg --output ./$plaintext_file --decrypt ./$crypt_file ; then
    echo "The file key.txt.gpg has been decrypted to $working_dir/$plaintext_file."
else
    echo "Error decrypting the file $working_dir/$crypt_file."
    exit 1
fi

# backup the file so we can see if changes were made
/bin/cp -f ./$plaintext_file ./${plaintext_file}.back

# open the file for viewing/editing
$editor ./$plaintext_file >&/dev/null

# compare the backup with the one from the editor
if ! diff ./$plaintext_file ./$comp_file >& /dev/null ; then
    # note that diff returns true if the files are identical
    echo "The file $working_dir/$plaintext_file has been modified.  Should I re-encrypt it?"
    select resp in {yes,no} ; do
        if [[ $resp == "yes" ]] ; then
            echo "Backing up $crypt_file"
            /bin/cp -vf ./$crypt_file $backup_dir
            if /usr/bin/gpg --yes --recipient $recipient --encrypt $plaintext_file ; then
                echo "File $plaintext_file has been successfully encrypted to $crypt_file."
            else
                echo "Error encrypting $plaintext_file."
            fi
            break
        elif [[ $resp == "no" ]] ; then
            break
        else
            true # nop
        fi
    done
fi

# delete all plaintext files 
echo "$working_dir/$plaintext_file will be deleted in 3 seconds.  Press ctrl-c to cancel."

for i in {3,2,1} ; do
    echo $i
    sleep 1
done

# (many editors make backup copies)
/bin/rm -f ./$plaintext_file ./$comp_file ./${plaintext_file}.bck ./${plaintext_file}~ ./"#${plaintext_file}#"

    
    

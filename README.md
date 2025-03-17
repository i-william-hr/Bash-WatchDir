# Bash-WatchDir william@william.hr 03.2025
#v1.0

This script watches a dir for new folders and files and subsequently calls another script with the path as var.
It is verified before copy that the filehandle is closed and the file is complete.

Currently it will run a script with -d (directory) or -f (file) option and the full path (no matter if directory or file):

      - /root/scripts/ftp.sh -d /var/www/964ec945bcd80254ce1e98c5c509c2d4-edeu2jeuso/
      
      - /root/scripts/ftp.sh -f /var/www/964ec945bcd80254ce1e98c5c509c2d4-edeu2jeuso/C.pdf

Included is a script to upload to FTP servers.

Requires:
 - inotify-tools
 - curl
                                                                                          
Known bugs:

    - none at this time
                                                                                          

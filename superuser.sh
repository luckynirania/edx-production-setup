if [ -z "$2" ]
then
        echo "provide username and email"
else
        sudo su edxapp -s /bin/bash
        cd
        source edxapp_env
        /edx/bin/python.edxapp /edx/bin/manage.edxapp lms manage_user $1 $2 --staff --superuser --settings=production
        cd /edx/app/edxapp/edx-platform
        ./manage.py lms --settings production changepassword $1 
fi

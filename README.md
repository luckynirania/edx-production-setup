# Getting server live
1. Create AWS instance from ```Ubuntu-16.04```
2. ```t2.large, 60 GB storage```
3. In security group add three entries
    ```HTTP```
    ```HTTPS```
    ```CUSTOM``` (Allow from anywhere in access dropdown menu)
4. generate pem file for future access
5. ssh from pem
6.      sudo locale-gen en_US en_US.UTF-8 # for proper terminal output 
        sudo dpkg-reconfigure locales
        sudo dpkg --configure -a
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo reboot
7. Create a config file ```config.yml``` in home directory i.e., ```~/config.yml``` with following content
8.      # add the following two lines, replacing the text 123.456.789 with your server's IP address.
        # Keep the quotes.
        EDXAPP_LMS_BASE: "123.456.789"
        EDXAPP_CMS_BASE: "123.456.789"
9.      sudo wget https://github.com/luckynirania/edx-production-setup/blob/main/edx.platform-install.sh
        sudo chmod 755 edx.platform-install.sh
        sudo nohup ./edx.platform-install.sh & # it will take about 90 minutes in background, so chill
10. To check whether the process is finished or is ongoing, just do ```sudo /edx/bin/supervisorctl status```. If entries are the following, then script is finished
11.     analytics_api                    RUNNING   pid 11601, uptime 5:34:15
        certs                            RUNNING   pid 10720, uptime 5:11:37
        cms                              RUNNING   pid 26833, uptime 0:31:05
        discovery                        RUNNING   pid 4353, uptime 5:14:56
        ecommerce                        RUNNING   pid 6318, uptime 5:37:10
        ecomworker                       RUNNING   pid 8532, uptime 5:36:09
        edxapp_worker:cms_default_1      RUNNING   pid 27010, uptime 0:30:35
        edxapp_worker:cms_high_1         RUNNING   pid 27011, uptime 0:30:35
        edxapp_worker:lms_default_1      RUNNING   pid 27014, uptime 0:30:35
        edxapp_worker:lms_high_1         RUNNING   pid 27013, uptime 0:30:35
        edxapp_worker:lms_high_mem_1     RUNNING   pid 27012, uptime 0:30:35
        forum                            RUNNING   pid 13084, uptime 5:10:27
        insights                         RUNNING   pid 23465, uptime 5:29:37
        lms                              RUNNING   pid 26745, uptime 0:31:08
        notifier-celery-workers          RUNNING   pid 6609, uptime 5:13:51
        notifier-scheduler               RUNNING   pid 6575, uptime 5:14:04
        xqueue                           RUNNING   pid 9116, uptime 5:12:29
        xqueue_consumer                  RUNNING   pid 9209, uptime 5:12:26
12. Creating admin account prevents a lot of headaches in future (enables django admin)
13.     sudo su edxapp -s /bin/bash
        cd
        source edxapp_env
        /edx/bin/python.edxapp /edx/bin/manage.edxapp lms manage_user yourusername youruseremail --staff --superuser --settings=production
        cd /edx/app/edxapp/edx-platform
        ./manage.py lms --settings production changepassword yourusername

# Setting up SMTP
1. Edit ```/edx/app/edxapp/lms.auth.json```
    1.      EMAIL_HOST_PASSWORD: 'password'
            EMAIL_HOST_USER: 'email'
2. Edit ```/edx/app/edxapp/cms.auth.json```
    1.      EMAIL_HOST_PASSWORD: 'password'
            EMAIL_HOST_USER: 'email'
3. Edit ```/edx/app/edxapp/lms.env.json```
    1.      EMAIL_BACKEND: django.core.mail.backends.smtp.EmailBackend
            EMAIL_HOST: smtp.gmail.com
            EMAIL_PORT: 587
            EMAIL_USE_TLS: true
    2. anything with ```@example.com``` with your email
4. Edit ```/edx/app/edxapp/lms.env.json```
    1.      EMAIL_BACKEND: django.core.mail.backends.smtp.EmailBackend
            EMAIL_HOST: smtp.gmail.com
            EMAIL_PORT: 587
            EMAIL_USE_TLS: true
    2. anything with ```@example.com``` with your email
5. Edit ```/edx/etc/lms.yml```
    All those above changes in this file too
6. Edit ```/edx/etc/studio.yml```
    All those above changes in this file too
7. Restart server to take effect
    1.      /edx/bin/supervisorctl restart lms
            /edx/bin/supervisorctl restart cms
            /edx/bin/supervisorctl restart edxapp_worker:
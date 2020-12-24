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
        EDXAPP_LMS_BASE: "paatha.org"
        EDXAPP_CMS_BASE: "studio.paatha.org"
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

# Binding Domain Name
1. Do the A entry for both lms and cms domains using your domain name provider

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

# Changing Platform Name
1. set ```PLATFORM_NAME``` variable in both  ```/edx/etc/lms.yml``` and ```/edx/etc/studio.yml```
2. Restart server to take effect
    1.      /edx/bin/supervisorctl restart lms
            /edx/bin/supervisorctl restart cms
            /edx/bin/supervisorctl restart edxapp_worker:

# SSL certificate
1. add domain name for which we apply for SSL
    1.    ```server_name paatha.org``` to server block in file ```/edx/app/nginx/sites-available/lms```
    2. ```server_name studio.paatha.org``` to server block in file ```/edx/app/nginx/sites-available/cms```
2. Install Certbot
    1.      sudo apt-get update
            sudo apt-get install software-properties-common
            sudo add-apt-repository universe
            sudo add-apt-repository ppa:certbot/certbot
            sudo apt-get update
            sudo apt-get install certbot python-certbot-nginx
3. Apply for SSL
    1.     sudo certbot --authenticator standalone --installer nginx --pre-hook "service nginx stop" --post-hook "service nginx start"
    2. provide your email for alerts and accept terms and conditions
    3. The prompt should show the domain names for which we will applying the SSL
    4. Select All domain name
    5. Choose option 2 to enable redirect http to https
    6. If all things work as planned, Congratualtions message should appear under IMPORTANT NOTES

# Redirection issues
1. It may happen that after logging from studio, we get redirected to lms. To resolve, edit in configuration files we changed during SMTP setup the following
2. ```SESSION_COOKIE_DOMAIN``` to ```".paatha.org"``` 
3. ```LOGIN_REDIRECT_WHITELIST``` is set to ```"studio.paatha.org"```
4. Restart server to take effect
    1.      /edx/bin/supervisorctl restart lms
            /edx/bin/supervisorctl restart cms
            /edx/bin/supervisorctl restart edxapp_worker:
            
# Enable Search 
1. To enable search, change the following in ```/edx/app/edxapp/lms/envs/common.py```
2. ```ENABLE_COURSEWARE_SEARCH: True```
3. ```ENABLE_DASHBOARD_SEARCH: True```
4. ```ENABLE_COURSE_DISCOVERY: True```
5. ```SEARCH_ENGINE: "search.elastic.ElasticSearchEngine"```
6. and following in ```/edx/app/edxapp/cms/envs/common.py```
7. ```ENABLE_COURSEWARE_INDEX : True```
8. ```ENABLE_LIBRARY_INDEX : True```
9. ```SEARCH_ENGINE : "search.elastic.ElasticSearchEngine"```
10. Note :- update 'Course Schedule' Entries from 'settings -> Schedule and Details' tab in order to appear courses in search. Also don't forget to reindex. 

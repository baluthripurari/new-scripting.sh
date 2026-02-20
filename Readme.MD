# Create .netrc (VERY IMPORTANT)

 * vi ~/.netrc


# Add exactly this (replace values):

* machine oneartifatory.company.com
* login YOUR_USERID
* password YOUR_PASSWORD

# Secure it:

* chmod 600 ~/.netrc

* chmod +x /app/scripts/deploy.sh
* chmod +x /app/scripts/deploy-multiple.sh

# Deploy single micro

* ./deploy.sh payment 26.02.100 payment-micro payment-31-42-42-242-234.jar

# Deploy all micros

* ./deploy-multiple.sh deploy-list.txt


(crontab -l 2>/dev/null; echo "*/5 * * * * /bin/bash /app/scripts/monitor_mybiztools.sh >> /app/logs/cron.log 2>&1") | crontab -

crontab -l | grep monitor_mybiztools

* * * * * /bin/bash /app/scripts/monitor_mybiztools.sh >> /app/logs/cron.log 2>&1

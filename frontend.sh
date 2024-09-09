#!/bin/bash

LOGS_FOLDER="/var/logs/expense"
SCRIPT_NAME=$(echo $0 | cut -d '.' -f1)
TIMESTAMP=$(date +Y%-m%-d%-H%-M%-S%)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -eq 0 ]; then
        echo -e "$2 ... $R failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .. $G Success $N" | tee -a $LOG_FILE
    fi
}

echo "Script started at $(date)" | tee -a $LOG_FILE

if [ $ID -ne 0 ]; then
    echo -e "$R Error: This script must be run as root $N"
    exit 1
fi

# Developer has chosen Nginx as a web server. Install Nginx Web Server.
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

# Enable nginx
systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling Nginx"

# Start nginx
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting Nginx"

# Remove the default content that web server is serving.
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default content"

# Download frontend content
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE

# Extract the frontend content
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extract frontend code"

# Copy expense configuration
cp /home/repos/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE $? "Copying expense configuration"

# Restart Nginx
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting Nginx"


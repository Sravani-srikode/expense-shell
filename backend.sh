#!bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p $LOGS_FOLDER

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2... is $R failed $N" | tee -a $LOG_FILE
    else
        echo -e "$2... is $G Success $N" | tee -a $LOG_FILE
    fi
}

echo "Script started at: $(date)" | tee -a $LOG_FILE

if [ $ID -ne 0 ]; then
    echo -e "$R You are not a root user $N, $Y try using sudo access $N"
    exit 1
fi

# Developer has chosen NodeJs >20
dnf module disable nodejs -y &>>$LOG_FILE # disable default version 18
VALIDATE $? "Disabling default NodeJs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJs:20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJs"

# Add Application user
id expense &>>LOG_FILE
if [ $? -ne 0 ]; then
    echo -e "expense user does not exist... $G Creating Now $N"
    useradd expense &>>LOG_FILE
else
    echo -e "expense user already exists... $Y SKIPPING $N" | tee -a $LOG_FILE
fi

# Setup directory to keep application in one standard location
mkdir -p /app
VALIDATE $? "Creating /app directory"

# Download application code and unzip
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/* #remove existing code
unzip /tmp/backend.zip
VALIDATE $? "Extracting backend application code"

# Install dependencies 
npm install &>> $LOG_FILE

# setup a new service in systemd
cp /home/repos/expense-shell/backend.service /etc/systemd/system/backend.service

# load schema to the Database
dnf install mysql -y &>> $LOG_FILE # Installing mysql client
VALIDATE $? "Installing mysql Client"

mysql -h 172.31.41.176 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE
VALIDATE $? "Loading Schema"

# Reload Service
systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading Service"

# Enable and start Server
systemctl enable backend &>> $LOG_FILE
VALIDATE $? "enabling backend"
systemctl restart backend &>> $LOG_FILE
VALIDATE $? "Restarting backend"

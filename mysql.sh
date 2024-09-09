#!/bin/bash

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

# Developer has chosen the database MySQL. Install MySQL Server 8.0.x
dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? "Installing mySQL server"

# Start MySQL Service
systemctl enable mysqld
VALIDATE $? "Enabling MySQL" &>>LOG_FILE

systemctl start mysqld
VALIDATE $? "Starting MySQL" &>>LOG_FILE

# mysql -h mysql.daws81s.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE

# change the default root password in order to start using the database service. 
# Using password ExpenseApp@1

if [ $? -ne 0 ]; then
    echo -e "MySQL Password not set up, $Y SETTING NOW $N"  | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting password"
else
    echo -e "MySQL password already set up.. $Y SKIPPING $N" | tee -a $LOG_FILE

fi

# check data by using client package called mysql
# mysql -h <host-address> -u root -p<password>
mysql
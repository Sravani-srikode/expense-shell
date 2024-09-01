#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$1... is $R failed $N"
    else
        echo -e "$1... is $G Success $N"
    fi
}

if [ $ID -ne 0 ]; then
    echo -e "$R You are not a root user $N, $Y try using sudo access $N"
    exit 1
fi

# Developer has chosen the database MySQL. Install MySQL Server 8.0.x
dnf install mysql-server -y
VALIDATE $? "Installing mySQL server"

# Start MySQL Service
systemctl enable mysqld
VALIDATE $? "Enabling MySQL"

systemctl start mysqld
VALIDATE $? "Started MySQL"

# change the default root password in order to start using the database service. 
# Using password ExpenseApp@1

if [ $? -ne 0 ]; then
    echo -e "MySQL Password not set up, $Y SETTING NOW $N"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting password"
else
    echo -e "MySQL password already set up.. $Y SKIPPING $N"

fi

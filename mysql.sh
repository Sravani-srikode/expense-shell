#!/bin/bash

ID=$(id -u)
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"


VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$1... is $R failed $N"
    else
        echo -e "$1... is $G Success $N"
    fi
}

if [ $ID -ne 0 ]; then
    echo "You are not a root user, try using sudo access"
    exit 1
fi

echo -e "Script excecution $Y started $N"
VALIDATE $?


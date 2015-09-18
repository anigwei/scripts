#!/bin/bash

#Agafar usuaris del fixer CMS.CSV i passar-los 
for i in $(cat cms.csv)
        do 
		echo $i:$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-8};) >> passwords.txt
		echo "* Creada contrasenya per l\'usuari $i"
	done

#Crear usuari al sistema
for i in $(cat passwords.txt)
        do
                user=$(echo $i | cut -d ":" -f1)
                password=$(echo $i | cut -d ":" -f2)
                sudo useradd -d /home/estudiants/$user -s /bin/false -g estudiants -p $(openssl passwd -1 $password) $user
		mkdir /home/estudiants/$user
		mkdir /home/estudiants/$user/public_html	
		chmod 755 /home/estudiants/$user
		chmod 775 /home/estudiants/$user/public_html
		chown root:root /home/estudiants/$user
		chown $user:estudiants /home/estudiants/$user/public_html
                echo "* Creat usuari $user al sistema i la estructura de directoris"
        done

#Crear BBDD amb mateix username i otorgar permis a nou usuari amb mateix username
for i in $(cat passwords.txt)
        do
                user=$(echo $i | cut -d ":" -f1)
                password=$(echo $i | cut -d ":" -f2)
                mysql -uroot -p0comoras0 --execute="CREATE DATABASE $user;"
                mysql -uroot -p0comoras0 --execute="CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';"
                mysql -uroot -p0comoras0 --execute="GRANT ALL PRIVILEGES ON $user.* TO '$user'@'localhost';"
                echo "* Created database for user $user "
        done


#ENVIA CORREU
for i in $(cat passwords.txt);
        do
                user=$(echo $i | cut -d ":" -f1);
                password=$(echo $i | cut -d ":" -f2);
                cp email_cas.txt email_1.tmp;
                sed -i "s/USER/$user/g" email_1.tmp
                sed -i "s/PASSWORD/$password/g" email_1.tmp
                mail -s 'Acceso a alumnos eimtDBD' "$user@uoc.edu" < email_1.tmp;
                echo Email sent to user $user: "$user@uoc.edu" ;
                rm email_1.tmp;
        done

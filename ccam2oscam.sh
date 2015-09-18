#!/bin/bash

IFS=$'\n'

echo "Script cline2oscam.sh per Andreu Bassols @anigwei Setembre 2015"

if [ ! -f linies.txt ];
then
   echo "* Alerta: L'script requereix la presència del fitxer LINIES.TXT amb una cline per linia!"
   exit 1
fi

if [ -f oscam.server ];
then
   echo "* Alerta: El fitxer oscam.server ja existeix. S'inclouran noves linies al final de tot"
fi

if [ ! -f reader.tpl.txt ];
then

        echo "* Creant reader.tpl.txt..."
        echo "[reader]
        label                         = LABEL
        protocol                      = cccam
        device                        = SERVIDOR,PORT
        user                          = USUARI
        password                      = PASSWORD
        inactivitytimeout             = 30
        group                         = 1
        cccversion                    = 2.3.0
        ccckeepalive                  = 1
        cccreshare                    = 1" > reader.tpl.txt
fi


echo -n "* Processant..."

for i in $(cat linies.txt)
        do
                servidor=$(echo $i | awk '{ print $2 }')
                port=$(echo $i | awk '{ print $3 }')
                usuari=$(echo $i | awk '{ print $4 }')
                pass=$(echo $i | awk '{ print $5 }')
                cp reader.tpl.txt reader.tmp
                sed -i "s/SERVIDOR/$servidor/g" reader.tmp
                sed -i "s/PORT/$port/g" reader.tmp
                sed -i "s/USUARI/$usuari/g" reader.tmp
                sed -i "s/PASSWORD/$pass/g" reader.tmp
                sed -i "s/LABEL/Linia $servidor/g" reader.tmp
                echo " " >> oscam.server
                echo "#Nova Linia afegida automaticament el $(date)" >> oscam.server
                cat reader.tmp >> oscam.server
                rm reader.tmp
                echo -n "."
        done
echo " "
echo "* Afegides $(cat linies.txt | wc -l) linies de lines.txt a format OSCAM dintre de oscam.txt"

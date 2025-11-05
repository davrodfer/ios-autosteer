#!/bin/sh

#  Script.sh
#  autosteer
#
#  Created by David Rodríguez Fernández on 21/11/24.
#  

# Simula los datos mostrados por el GPS, escuchando en un puerto con netcat
# Enviando datos generados con un netcat sobre un dispositivo real
# Captura: nc -v vehiculo.local 9001 | tee -a  llh_example_data.txt

RATE=0.3  # 5Hz
PORT=9001

while true ; do
    while true ; do
        while read linea; do
          echo ${linea}
          sleep ${RATE}
        done <llh_example_data.txt
    done | nc -vl  ${PORT}
    echo "Fin de la conexion"
done

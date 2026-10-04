#!/bin/bash
# mikildap.sh - Gestion de correos del dominio miki.ldap

BASE="dc=miki,dc=ldap"
ADMIN="cn=admin,$BASE"

read -s -p "Contraseña admin LDAP: " PASS
echo

while true; do
    echo ""
    echo "===== MENU LDAP ====="
    echo "1. Eliminar correo de un usuario"
    echo "2. Modificar correo de un usuario"
    echo "3. Buscar usuarios"
    echo "0. Salir"
    read -p "Opcion: " OP

    case $OP in
        1)
            read -p "Usuario (uid): " USR
            DN=$(ldapsearch -x -LLL -b "$BASE" "(uid=$USR)" dn | grep "^dn:" | cut -d' ' -f2-)
            ldapmodify -x -D "$ADMIN" -w "$PASS" << FIN
dn: $DN
changetype: modify
delete: mail
FIN
            ;;
        2)
            read -p "Usuario (uid): " USR
            read -p "Nuevo correo: " MAIL
            DN=$(ldapsearch -x -LLL -b "$BASE" "(uid=$USR)" dn | grep "^dn:" | cut -d' ' -f2-)
            ldapmodify -x -D "$ADMIN" -w "$PASS" << FIN
dn: $DN
changetype: modify
replace: mail
mail: $MAIL
FIN
            ;;
        3)
            echo "1. Un usuario"
            echo "2. Todos los usuarios"
            read -p "Opcion: " SUB
            if [ "$SUB" = "1" ]; then
                read -p "Usuario (uid): " USR
                ldapsearch -x -LLL -b "$BASE" "(uid=$USR)" uid mail
            else
                ldapsearch -x -LLL -b "$BASE" "(objectClass=inetOrgPerson)" uid mail | grep -E "^(uid|mail):"
            fi
            ;;
        0)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opcion no valida"
            ;;
    esac
done

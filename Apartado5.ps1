do {
    Write-Host "`n===== MENÚ GESTIÓN DOMINIO =====" -ForegroundColor Cyan
    Write-Host "1. Información del dominio"
    Write-Host "2. Crear Unidad Organizativa (OU)"
    Write-Host "3. Ver miembros de una OU"
    Write-Host "4. Crear grupo"
    Write-Host "5. Crear usuario"
    Write-Host "0. Salir"
    $opcion = Read-Host "Elige una opción"

    switch ($opcion) {
        "1" {
            Write-Host "Equipo: $env:COMPUTERNAME"
            Write-Host "Dominio: $env:USERDNSDOMAIN"
            $ous = (Get-ADOrganizationalUnit -Filter *).Count
            $grupos = (Get-ADGroup -Filter *).Count
            $usuarios = (Get-ADUser -Filter *).Count
            Write-Host "OUs: $ous | Grupos: $grupos | Usuarios: $usuarios"
        }
        "2" {
            $ouNombre = Read-Host "Nombre de la nueva OU"
            $ouPath = Read-Host "Path padre (ej: DC=nombre,DC=aws)"
            New-ADOrganizationalUnit -Name $ouNombre -Path $ouPath
            Write-Host "OU '$ouNombre' creada." -ForegroundColor Green
        }
        "3" {
            $ouDN = Read-Host "DN de la OU"
            Get-ADObject -SearchBase $ouDN -Filter * -SearchScope OneLevel |
                Select-Object Name, ObjectClass
        }
        "4" {
            $grpNombre = Read-Host "Nombre del grupo"
            $grpPath = Read-Host "Path (ej: OU=MiOU,DC=nombre,DC=aws)"
            New-ADGroup -Name $grpNombre -GroupScope Global -Path $grpPath
            Write-Host "Grupo '$grpNombre' creado." -ForegroundColor Green
        }
        "5" {
            $user = Read-Host "Nombre de usuario (SAM)"
            $fname = Read-Host "Nombre"
            $lname = Read-Host "Apellido"
            $pass = Read-Host "Contraseña" -AsSecureString
            $path = Read-Host "Path OU"
            $grp = Read-Host "Grupo al que asignar"
            New-ADUser -SamAccountName $user -GivenName $fname -Surname $lname `
                -Name "$fname $lname" -AccountPassword $pass -Enabled $true `
                -Path $path -ChangePasswordAtLogon $true
            Add-ADGroupMember -Identity $grp -Members $user
            Write-Host "Usuario '$user' creado y añadido a '$grp'." -ForegroundColor Green
        }
        "0" { Write-Host "Saliendo..." -ForegroundColor Yellow }
        default { Write-Host "Opción no válida." -ForegroundColor Red }
    }
} while ($opcion -ne "0")

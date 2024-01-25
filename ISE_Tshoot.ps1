# Solicitar el nombre del equipo remoto
$nombreEquipoRemoto = Read-Host "Ingrese el nombre del equipo remoto"

# Realizar una prueba de ping para verificar la conectividad
if (Test-Connection -ComputerName $nombreEquipoRemoto -Count 2 -Quiet) {
    Write-Host "Conectividad exitosa con $nombreEquipoRemoto`n"
} else {
    Write-Host "No se pudo establecer una conexión con $nombreEquipoRemoto."
    break
}

# Definir las credenciales del usuario TestUser
$usuario = "svc_ise"
$password = ConvertTo-SecureString "Opt1mus@t1me" -AsPlainText -Force
$credenciales = New-Object System.Management.Automation.PSCredential($usuario, $password)


# Definir los comandos a ejecutar
$comandos = @(
#    "gpupdate /force",
    "ipconfig -all"
    "ping dcbeap02.opti.local",
    "ping CABEAP01.opti.local",
    "gpresult /R /SCOPE COMPUTER | findstr ISE",
    "certutil -store My | findstr CABEAP01",
    "netsh lan show interfaces",
    "netsh wlan show profiles  | findstr Turia"
)

# Bloque de script para ejecutar comandos de forma remota
foreach ($comando in $comandos) {
    Write-Host "`n - Ejecutando comando: $comando"

    $output = Invoke-Command -ComputerName $nombreEquipoRemoto -Credential $credenciales -ScriptBlock {
        param($comando)
        $resultado = Invoke-Expression -Command $comando
        return $resultado
    } -ArgumentList $comando

    # Mostrar el output del comando en pantalla
    Write-Host "`n$output"

}

# Obtener la ubicacion del PC en el Directorio Activo
Get-AdComputer -Identity $nombreEquipoRemoto -Properties CanonicalName | Select-Object CanonicalName

# Solicitar la dirección IP del computador remoto
$originalIpAddress = Read-Host "Ingrese la dirección IP del computador"

$hostNameRemoto = [System.Net.Dns]::GetHostEntry($originalIpAddress).HostName
$resolvedIpAddress = [System.Net.Dns]::GetHostAddresses($hostNameRemoto) | Where-Object { $_.AddressFamily -eq 'InterNetwork' }

if ($resolvedIpAddress.IPAddressToString -ne $originalIpAddress) {
        Write-host "`nLa dirección IP resuelta ($($resolvedIpAddress.IPAddressToString)) no coincide con la dirección IP original ($originalIpAddress)"
		break
   } else {
        Write-host "`nEl nombre del computador y la IP $originalIpAddress si coinciden"
}


# Realizar una prueba de ping para verificar la conectividad
if (Test-Connection -ComputerName $hostNameRemoto -Count 2 -Quiet) {
    Write-Host "`nConectividad exitosa con $hostNameRemoto"
} else {
    Write-Host "`nNo se pudo establecer una conexión con $hostNameRemoto."
    break
}



# Definir las credenciales del usuario TestUser
$usuario = "USERNAME"
$password = ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
$credenciales = New-Object System.Management.Automation.PSCredential($usuario, $password)


# Definir los comandos a ejecutar
$comandos = @(
    "gpupdate /force",
    "ipconfig -all"
    "ping dcbeap02.opti.local",
    "ping cabeap01.opti.local",
    "gpresult /R /SCOPE COMPUTER | findstr ISE",
    "certutil -store My",
    "netsh lan show interfaces",
    "netsh wlan show profiles  | findstr Turia"
)

# Bloque de script para ejecutar comandos de forma remota
foreach ($comando in $comandos) {
    Write-Host "`n - Ejecutando comando: $comando"

    $output = Invoke-Command -ComputerName $hostNameRemoto -Credential $credenciales -ScriptBlock {
        param($comando)
        $resultado = Invoke-Expression -Command $comando
        return $resultado
    } -ArgumentList $comando

    # Mostrar el output del comando en pantalla
    Write-Host "`n$output"

}

# Obtener la ubicacion del PC en el Directorio Activo
Get-AdComputer -Identity $hostNameRemoto -Properties CanonicalName | Select-Object CanonicalName

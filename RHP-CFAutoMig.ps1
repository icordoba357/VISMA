####Script para Migracion a Centraliced Files####
#Autor: Ivan Cordoba
#Fecha: Septiembre 2019
#contacto: ivan.cordoba@visma.com
####
####
#   _ _ _
#  /_/_/_/\
# /_/_/_/\/\
#/_/_/_/\/\/\
#\_\_\_\/\/\/
# \_\_\_\/\/
#  \_\_\_\/
####
####
####Definicion inicial de Variables####
##
##SERVER
##Consulta servidor donde se ejecuta el proceso y lo guarda como variable
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$title = 'Migracion a Centralized Files'
$msg   = 'Ingrese nombre de Servidor:'

$Server = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

##
##SERVICIO
##Consulta nombre de servicio a detener y lo guarda como variable
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$title = 'Migracion a Centralized Files'
$msg   = "Ingrese nombre de Servicio a detener:"

$Servicio = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

##
##TENANT
##Consulta Tenant a migrar y lo guarda como variable
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$title = 'Migracion a Centralized Files'
$msg   = 'Ingrese nombre del Tenant:'

$Tenant = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

##
##
##Se definen origenes y destinos para los directorios LOG FOTOS e IN-OUT
$OrigenLog = '\\'+$Server+'\e$\Program Files\RHProX2R4\cgi-bin\'+$Tenant+'\log'
$DestinoLog = '\\SD-P-RHPFIL01\E$\RHProX2R4\cgi-bin\'+$Tenant+'\log\'

$OrigenFotos = '\\'+$Server+'\e$\Program Files\RHProX2R4\fotos\'+$Tenant
$DestinoFotos = '\\SD-P-RHPFIL01\E$\RHProX2R4\fotos\'+$Tenant+'\'

$OrigenInOut = '\\'+$Server+'\e$\Program Files\RHProX2R4\In-Out\'+$Tenant
$DestinoInOut = '\\SD-P-RHPFIL01\E$\RHProX2R4\In-Out\'+$Tenant+'\'
$LogLog = 'Log.txt'
$LogFotos = 'fotos.txt'
$LogInOut = 'InOut.txt'

    #1-Se detiene el servicio
Get-Service -Name $Servicio -ComputerName $Server | Set-Service -Status Stopped 
   
    #2-Se copian los directorios con sus respectivos archivos y se genera log
ROBOCOPY $OrigenLog $DestinoLog /E /log:$LogLog /NFL /NDL
ROBOCOPY $OrigenFotos $DestinoFotos /E /log:$LogFotos /NFL /NDL
ROBOCOPY $OrigenInOut $DestinoInOut /E /log:$LogInOut /NFL /NDL
    
    #3-Modificacion de archivos .ini

$Ladoble = "\\"
$File = "\rhproappsrv.ini" #Modificar luego por rhproappsrv.ini
$File1 = "\RHProProcesos.ini" #Modificar luego por RHProProcesos.ini
$Origen0 = $Ladoble+$Server+"\e$\Program Files\RHProX2R4\cgi-bin\"+$Tenant
$Origen1 = $Ladoble+$Server+'\e$\Program Files\RHProX2R4\cgi-bin\Procesos'
$Origen2 = $Origen1+$File1
$Origen = $Origen0+$File
$OldString = "e:\Program Files\RHProX2R4\cgi-bin\"+$Tenant
$NewString = "\\SD-P-RHPFIL01\e$\RHProX2R4\cgi-bin\"+$Tenant

$InputFiles | ForEach {
    (Get-Content -Path $Origen)-ireplace [regex]::Escape($OldString),$NewString}  | Set-Content $Origen0'\rhproappsrv.ini'
    $InputFiles | ForEach {
    (Get-Content -Path $Origen2)-ireplace [regex]::Escape($OldString),$NewString}  | Set-Content $Origen1'\RHProProcesos.ini'

    #4-Reconfigurar tabla Sistema (Script SQL)-Pendiente

    #5-Cambiar usuario que levanta el servicio
       
    #Se Inicia Servicio
Get-Service -Name $Servicio -ComputerName $Server | Set-Service -Status Running
    

    #Se definen Variables para envio de correo
$Attachement = $LogLog, $LogFotos, $LogInOut
$From= 'DBZ_Reports@raet.com' #Desde donde se envia el correo
$To= 'ivan.cordoba@visma.com' #Especificar a quienes se envia el correo en caso de mas de un destinatario separar por comas entre comillas simples
$Asunto= 'Resultado Migracion a CF' #Asunto del correo
$SMTP= 'mail.intracom.nl' #Servidor SMTP para envio del correo
$Puerto= 25 #Puerto envio SMTP
    #Envio de correo
Send-MailMessage -From $From -To $TO -Subject $Asunto -Body 'Se adjunta archivo con resultados' -SmtpServer $SMTP -Port $Puerto -Attachments $Attachement
    
####FIN SCRIPT####

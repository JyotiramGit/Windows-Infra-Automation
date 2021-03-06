
# STIG ID: WG110 IIS  Limit of connectionsis set  by setting "maxconnections" to the configuration using Powershell.
Import-Module WebAdministration
Set-WebConfigurationProperty '/system.applicationHost/sites/site[@name="Default Web Site"]' -Name Limits -Value @{MaxConnections=100}

#---------------------------------------------------------------------------------------------------------------------------------------
# WG140 IIS7 - Check 'Client Certificate Required' button in SSL Setting.
# WG340 IIS7 and WG342 IIS - Ensure Require SSL and Require 128-bit SSL are checked for Private and Public Web Servers.
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/security/access" -name "sslFlags" -value "Ssl,SslNegotiateCert,SslRequireCert" -Force

# WA000-WI6200 - Set the ".Net trust Level" to Medium.
set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.web/trust" -name "level" -Value "Medium" -Force

#STIG ID: WA000-WI120 IIS7 - Set 'alternateHostName' to 'system.webserver/serverRuntime' in Configuration editor
set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -Location 'Default Web Site' -filter "system.webServer/serverRuntime" -name "alternateHostName" -Value "DevOps" -Force

# WA000-WI6260 - uncheck the allow unlisted file extensions checkbox.
set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.webServer/security/requestFiltering" -name "fileExtensions.allowUnlisted" -Value "False" -Force

# WA000-WI6140 IIS7  - set the value for Debug to False.
set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -filter "system.web/compilation" -name "debug" -Value "false" -Force

#--------------------------------------------------------------------------------------------------------------------------------------
$names = Get-WebApplication -Site "Default Web Site"
foreach($name in $names)
 {
	$app = $name.Attributes[0].Value;
	$path = "MACHINE/WEBROOT/APPHOST/Default Web Site$app"

	# WG140 IIS7 and WG340 IIS7 and WG342 IIS - Check 'Client Certificate Required' button in SSL Setting and Ensure Require SSL and Require 128-bit SSL are checked for Private and Public Web Servers.
	set-WebConfigurationProperty -pspath $path -filter "system.webServer/security/access" -name "sslFlags" -Value "Ssl,SslNegotiateCert,SslRequireCert" -Force

	# WA000-WI6200 - Set the ".Net trust Level" to Medium.
	set-WebConfigurationProperty -pspath $path -filter "system.web/trust" -name "level" -Value "Medium" -Force
	
	# WA000-WI6260 - uncheck the allow unlisted file extensions checkbox.
	set-WebConfigurationProperty -pspath $path -filter "system.webServer/security/requestFiltering" -name "fileExtensions.allowUnlisted" -Value "False" -Force
 
    # WA000-WI6140 IIS7  - set the value for Debug to False.
    set-WebConfigurationProperty -pspath $path -filter "system.web/compilation" -name "debug" -Value "false" -Force
	
	#STIG ID: WA000-WI120 IIS7 - Set 'alternateHostName' to 'system.webserver/serverRuntime' in Configuration editor
	$appcmd = "$Env:SystemRoot\system32\inetsrv\appcmd.exe set config 'Default Web Site$app' -section:system.webServer/serverRuntime /alternateHostName:'DevOps' /commit:apphost"
    Invoke-Expression $appcmd | Out-Null
	Start-Sleep -s 10
 }
 
#----------------------------------------------------------------------------------------------------------------------------------------

 
# Disable PCT 1.0 Client
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Client' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Client' -name Enabled -value 0 -PropertyType 'DWord' -Force | Out-Null

# Disable PCT 1.0 Server
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server' -name Enabled -value 0 -PropertyType 'DWord' -Force | Out-Null

# Disable SSL 2.0 Client
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -name Enabled -value 0 -PropertyType 'DWord' -Force | Out-Null

# Disable SSL 2.0 Server
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name Enabled -value 0 -PropertyType 'DWord' -Force | Out-Null
 
# Disable SSL 3.0 Client
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -name Enabled -value 0 -PropertyType 'DWord' -Force | Out-Null

# Disable SSL 3.0 Server
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -name Enabled -value 0 -PropertyType 'DWord' -Force | Out-Null

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Enable TLS 1.1 Client
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name Enabled -value 1 -PropertyType 'DWord' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name DisabledByDefault -value 0 -PropertyType 'DWord' -Force | Out-Null

# Enable TLS 1.1 Server
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name Enabled -value 1 -PropertyType 'DWord' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name DisabledByDefault -value 0 -PropertyType 'DWord' -Force | Out-Null

# Enable TLS 1.2 Client
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name Enabled -value 1 -PropertyType 'DWord' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name DisabledByDefault -value 0 -PropertyType 'DWord' -Force | Out-Null

# Enable TLS 1.2 Server
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name Enabled -value 1 -PropertyType 'DWord' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name DisabledByDefault -value 0 -PropertyType 'DWord' -Force | Out-Null

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Enable TLS 1.0 Client if present then set 'Enabled' to 1.
$registryPath = “HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client"

	If(Test-Path $registryPath)
	{
	 New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name Enabled -value 1 -PropertyType 'DWord' -Force | Out-Null
	}

# Enable TLS 1.0 Server if present then set 'Enabled' to 1.
$registryPath = “HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"

	If(Test-Path $registryPath)
	{
	 New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name Enabled -value 1 -PropertyType 'DWord' -Force | Out-Null
	}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# WG520 and WG610  - Ensure there are FQDN entries and IP addresses assigned to port 80 for HTTP and port 443 for HTTPS.
$myFQDN=(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
$IPAddress = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress
Clear-ItemProperty 'IIS:\Sites\Default Web Site' -Name bindings
New-WebBinding -Name 'Default Web Site' -IPAddress "$IPAddress" -Port 80 -Protocol http -HostHeader $myFQDN
New-WebBinding -Name 'Default Web Site' -IPAddress "$IPAddress" -Port 443 -Protocol https -HostHeader $myFQDN

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#STIG ID: WG170 IIS7 - Each readable web document directory must contain a default, home, index, or equivalent document.
$Docs = "Default.htm","Default.asp","index.htm","index.html","iisstart.htm","Default.aspx"
$remainingdocs = @()

#delete default document from all websites under 'Default web site' if the document of that type is not present in content view.
foreach($name in $names)
{
$app = $name.Attributes[0].Value;
$Path = $name.physicalpath

foreach($doc in $Docs)
 {
   $strFileName = "$Path\$doc"
   If (!(Test-Path $strFileName))
	{	 
     Remove-WebconfigurationProperty "system.webserver/defaultdocument/files" "IIS:\sites\Default Web Site$app" -name collection -AtElement @{value=$doc} -Force -WarningAction SilentlyContinue
	}
 }
 $Document = Get-WebConfigurationProperty -Filter /system.webServer/defaultDocument/files/add -PSPath "IIS:\sites\Default Web Site" -Location "$app" -Name value | select value
 $remainingdocs += $Document
}
$Rdocs = $remainingdocs.value | select -uniq

#delete default document from  'Default web site' if the document of that type is not present in content view.
foreach($doc in $Docs)
 {
   $strFileName = "C:\inetpub\wwwroot\$doc"
   If (!(Test-Path $strFileName))
	{
	  if (!($Rdocs -Contains $doc))
		{
		 Remove-WebconfigurationProperty "system.webserver/defaultdocument/files" "IIS:\sites\Default Web Site" -name collection -AtElement @{value=$doc} -Force -WarningAction SilentlyContinue
		}
	}
 }

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# WA000-WI6120 - A global authorization rule to restrict access must exist on the web server.Allowed access to Administrators using Powershell script.

$rule = Get-WebConfiguration "system.webServer/security/authorization" -PSPath "IIS:\" |  select -ExpandProperty collection | Select users
if (!(($rule.users) -contains "Administrators"))
{
 Add-WebConfiguration -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/security/authorization" -value @{accessType="Allow";users="Administrators"} 
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# STIG ID: WA000-WI6022,WA000-WI6024,WA000-WI6026,WA000-WI6028
$pools = Get-ChildItem iis:\apppools
foreach ($pool in $pools)
{
  $poolname = $pool.Name
  #STIG ID: WA000-WI6022 IIS7 set the value for Request Limit to a value other than 0.
  Set-ItemProperty IIS:\AppPools\$poolname -Name recycling.periodicRestart.requests -Value 10
  
  #STIG ID: WA000-WI6024 IIS7 set the value for Virtual Memory Limit to a value other than 0
  Set-ItemProperty IIS:\AppPools\$poolname -Name recycling.periodicRestart.memory -Value 100000
  
  #STIG ID: WA000-WI6026 IIS7 set the value for Private Memory Limit to a value other than 0
  Set-ItemProperty IIS:\AppPools\$poolname -Name recycling.periodicRestart.privateMemory -Value 100000
  
  #STIG ID: WA000-WI6028 IIS7 ensure the value for Idle Time out is set to 20
  Set-ItemProperty IIS:\AppPools\$poolname -name processModel -value @{idletimeout="00:20:00"}
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
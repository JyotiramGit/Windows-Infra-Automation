#STIG:APPNET0031 - remove the values stored in Windows registry key HKLM\Software\Microsoft\StrongName\Verification.
#There should be no assemblies or hash values listed under this registry key...
Set-ExecutionPolicy Unrestricted
$StronNameReg = “REGISTRY::HKLM\Software\Microsoft\StrongName\Verification\"
IF(Test-Path $StronNameReg)
 {
   $StronNameRegValue = Get-ItemProperty $StronNameReg
   If($StronNameRegValue -ne $null)
   {
     Remove-Itemproperty -Path REGISTRY::HKLM\Software\Microsoft\StrongName\Verification\ -Name * -Force
   }
 }
#=======================================================================================================================================================================

#STIG:APPNET0046,APPNET0050,APPNET0068,APPNET0069 - Change the hexadecimal value of registry key -
# "HKEY_USER\[UNIQUE USER SID VALUE]\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing\State" to a Hex value of 10000. 

$HKU = Get-ChildItem "REGISTRY::HKEY_USERS"
Foreach($Key in $HKU)
{
 $registryPath = “REGISTRY::$key\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing"
 
 #Check if registry path is present or not,if not add the registry path
  IF(!(Test-Path $registryPath))
  {
   New-Item -Path $registryPath -Force
   New-ItemProperty $registryPath -name State -value 65536 -PropertyType DWORD -Force | Out-Null
  }
  else
   {
    $value1 = (Get-ItemProperty $registryPath).State -eq $null 
	#Check if registry key is present or not,if not add the registry key with value
	If($value1 -eq $true) 
    {
      New-ItemProperty -Path $registryPath -Name "State" -Value 65536 -PropertyType DWord -Force
    }
     else
      {
	       $Value = (Get-ItemProperty -Path $registryPath -Name State).State
	       $HexValue = "{0:x}" -f $Value
		   $HexValueLength =$HexValue.Length
		   
	       # If Hexadecimal length is not 5 then replace the hex value to 10000 
		   if($HexValueLength -ne "5")
		   {
		     Set-ItemProperty -Path $registryPath -Name "State" -Value 65536 -Force
		   }
	       else
	         {
			   #Get each nibble position of hex value and replace the nibble position by 10000 accordingly
			   # STIG : APPNET0068,APPNET0068 - change the hexadecimal value for nibble position 5 to "1"
		       if($HexValue[0]-ne "1")
		       {
		         $HexValue = $HexValue.replace($HexValue[0],"1")
		       }
			   # STIG :  APPNET0050 - change the hexadecimal values for nibble positions 3 and 4 to "0"
		       if($HexValue[1]-ne "0")
		       {
		         $HexValue = $HexValue.replace($HexValue[1],"0")
		       }
			   # STIG :  APPNET0050 - change the hexadecimal values for nibble positions 3 and 4 to "0"
		       if($HexValue[2]-ne "0")
		       {
		         $HexValue = $HexValue.replace($HexValue[2],"0")
		       }
			   # STIG :  APPNET0046 - change the hexadecimal value in nibble position 2 to "0"
		       if($HexValue[3]-ne "0")
		       { 
		         $HexValue = $HexValue.replace($HexValue[3],"0")
		       }
			   if($HexValue[4]-ne "0")
		       {
		          $HexValue = $HexValue.replace($HexValue[4],"0")
		       }
		  
		       $Value = [Convert]::ToInt32($HexValue, 16)
		       Set-ItemProperty -Path $registryPath -Name "State" -Value $Value -Force
	        }
       }
    }
  }
 
 #=======================================================================================================================================================================
 
   #STIG:APPNET0063 - Change the registry key "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\AllowStrongNameBypass" to a DWORD value of 0. 
   $DotNetPath = “REGISTRY::HKLM\SOFTWARE\Microsoft\.NETFramework"
    New-ItemProperty -Path $DotNetPath -Name "AllowStrongNameBypass" -Value 0 -PropertyType DWord -Force
	
 #=======================================================================================================================================================================
 
#APPNET0061-Remove unsupported versions of the .NET Framework

Import-Module DISM
If ((Get-windowsoptionalfeature -FeatureName NetFx3 -Online | Select-Object -ExpandProperty State) -eq "Enabled")
 {
   Disable-WindowsOptionalFeature -FeatureName NetFx3 -Online -NoRestart 
   Disable-WindowsOptionalFeature -FeatureName NetFx3ServerFeatures -Online -NoRestart
 }
 
 #=======================================================================================================================================================================
 
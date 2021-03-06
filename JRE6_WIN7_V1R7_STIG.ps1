
$fullPathIncFileName = $MyInvocation.MyCommand.Definition
$currentScriptName = $MyInvocation.MyCommand.Name
$currentExecutingPath = $fullPathIncFileName.Replace($currentScriptName, "")
$PropertyFilePath = Join-Path -Path $currentExecutingPath -ChildPath "deployment.properties"
$ConfigRef = Join-Path -Path $currentExecutingPath -ChildPath "deployment.config"

# Check if OS Architecture is 32 bit or 64 bit

if ((Get-WMIObject win32_operatingsystem).OSArchitecture -eq '64-bit')
 {
    # Get Actual path of Source file and Destination file
	$JavaPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\javaws.exe"
	
	If (-not (Test-Path $JavaPath))
	{
	  Write-Host "Java is not installed on this Machine"
	  exit(0)
	}

	$JavaInstalldir = (Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\javaws.exe" -name "path").Path
    $LibPath = $JavaInstalldir -replace "bin","lib"
	
    $actualFilePAth = $LibPath + "\deployment.properties"
	$RefFile = Get-Content $PropertyFilePath
	
 	$ConfigFilePAth = $LibPath + "\deployment.config"
	$ConfigRefFile = Get-Content $ConfigRef
	
	# If 'Deployment.Propertyies' file is not present at destination location then copy the file.
	
	If (-not(Test-Path $actualFilePAth))
	{
	  Copy-Item $PropertyFilePath $LibPath
	}
	
	# If 'Deployment.Config' file is not present at destination location then copy the file.
	If (-not(Test-Path $ConfigFilePAth))
	{
	  Copy-Item $ConfigRef $LibPath
	}
	
	$ActualFile = Get-Content $actualFilePAth
	$ConfigFile = Get-Content $ConfigFilePAth
	
#If file is present but it is null then copy content from reference file to destination file
	
if($ActualFile -eq  $Null)
{
 $RefFile | Out-File $actualFilePAth
}
else
{
# If file contents present then do the string manipulation

foreach ($crntRefLine in $RefFile)
{
  If($ActualFile.Contains($crntRefLine))
  {
   #If text Line Found,ignore that lines and go to next line in reference file 
  }
   else
   {
    # check if reference line contains "=",split the text and compare with destination file
    if ($crntRefLine.Contains("="))
    {
	 $OrginalRefLine=$crntRefLine
	 $crntRefLineNew = $crntRefLine.trim().ToLower()
	 $crntRefLineArr1 = $crntRefLineNew -split "="
     $crntRefLineNew =  $crntRefLineArr1[0]
	 $RefLineFoundInActual = $false
	  # Read text lines of destination file
	 foreach($crntActualLine  in $ActualFile)
     {
	    $OriginalcrntActualLine=$crntActualLine
		$crntActualLine  = $crntActualLine.trim().ToLower()
        
		if([string]::IsNullOrWhiteSpace($crntActualLine )) 
        {            
          continue
        }
		# check if destination line contains "=",split the text and compare with destination file
         if($crntActualLine.Contains("="))
          {
             $crntActualLine1 = $crntActualLine -split "="
             $crntActualLine =  $crntActualLine1[0]
		
			 if($crntActualLine -eq $crntRefLineNew)
              {
				(Get-Content $actualFilePAth) -replace $OriginalcrntActualLine, $OrginalRefLine | Set-Content $actualFilePAth
				 $RefLineFoundInActual = $true 		
              }
		  }
	  }
	  #If reference line contains '=' but is not present in destination file then add that line to destination file
	  if($RefLineFoundInActual -eq $false)
	  {
	     Add-Content $actualFilePAth "`n$crntRefLine"
	  }
	  #String manipulation ends here
    }
	else
    {
	 Add-Content $actualFilePAth "`n$crntRefLine"
	}
  }
 }
}
# Deployment.property  file manipulation ends here
#Deployment.config  file manipulation starts here
	
# If empty config file is present then copy the contents
   if($ConfigFile -eq  $Null)
   { 
     $ConfigRefFile | Out-File $ConfigFilePAth
   }
    else
   {
    foreach ($crntRefLine in $ConfigRefFile)
    {
     If($ConfigFile.Contains($crntRefLine))
    {
      #If line found in actual file,ignore and check next line in reference file
    }
     else
    {
	 # check if reference line contains "=",split the text and compare with destination file
     if ($crntRefLine.Contains("="))
     {
	 $OrginalRefLine=$crntRefLine
	 $crntRefLineNew = $crntRefLine.trim().ToLower()
	 $crntRefLineArr1 = $crntRefLineNew -split "="
     $crntRefLineNew =  $crntRefLineArr1[0]
	 	 
	 $RefLineFoundInActual = $false
	  # Read text lines of destination file
	 foreach($crntActualLine  in $ConfigFile)
      {
	    $OriginalcrntActualLine=$crntActualLine
		$crntActualLine  = $crntActualLine.trim().ToLower()
        
		if([string]::IsNullOrWhiteSpace($crntActualLine )) 
        {            
          continue
        }
		
		# check if destination line contains "=",split the text and compare with destination file
         if($crntActualLine.Contains("="))
           {
             $crntActualLine1 = $crntActualLine -split "="
             $crntActualLine =  $crntActualLine1[0]
			 if($crntActualLine -eq $crntRefLineNew)
              {
				(Get-Content $ConfigFilePAth).replace($OriginalcrntActualLine, $OrginalRefLine) | Set-Content $ConfigFilePAth
				 $RefLineFoundInActual = $true 		
              }
		   }
	    }
		#If reference line contains '=' but is not present in destination file then add that line to destination file
	    if($RefLineFoundInActual -eq $false)
	    {
	     Add-Content $ConfigFilePAth -Value "`n$crntRefLine"
	    }
     }
	 else
      {
	   Add-Content $ConfigFilePAth -Value "`n$crntRefLine"
	  }	
   }
  }
 }
# Deployment.Config file manipulation ends here
	
 }
 else
 {
  write-host "OS is 32-bit"
 } 
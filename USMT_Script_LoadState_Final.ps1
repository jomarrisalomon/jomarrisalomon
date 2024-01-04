#Parameter bindings

[CmdletBinding()]
param (
       [Parameter(Mandatory=$True)]
       [string]$TargetServer = "hostname",                             # Target File server of new domain server
       [Parameter(Mandatory=$True)]
       [string]$TargetComputer = "hostname",                           # Target OLD computer from OLD domain 
       [Parameter(Mandatory=$True)]
       [string]$Olduser = "olduser",                                   # Old username from OLD domain
       [Parameter(Mandatory=$True)]
       [string]$NewDomain = "NewDomain",                               # Target Domain name of new domain
       [Parameter(Mandatory=$True)]
       [string]$Newuser = "hostname",                                  # New username from NEW domain
       [Parameter(Mandatory=$True)]                           
       [string]$NewDomainAdminUsername = "NewDomainAdminUsername",     # Admin User of new domain
       [Parameter(Mandatory=$True)]
       [securestring]$AdminPwd = "password"                            # Admin Pwd
)

# Ensures that powershell scripts can be used prior to running code

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Set target server that contains the Domain-User State Migration tool folder/kit

cmdkey /add:$TargetServer /user:$NewDomain\$NewDomainAdminUsername /pass:$AdminPwd

$computer = (Get-WmiObject win32_computersystem).Name
$arch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$mutarget = ('/' + 'mu' + ':' + $olduser + ':' + '$NewDomain\' + $newuser )                                        #Creates parameter for USMT to taregt old user to new user profile
$path = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\User State Migration Tool\amd64"
$WindowsKitPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\User State Migration Tool"

# If the windows kit is already downloaded locally, skip

If (!(Test-Path 'C:\Program Files (x86)\Windows Kits\10\Assessment and Development Kit')){
        Copy-Item -Path "\\inari-srv1\User_Profile_Backup\Windows Kits" -Recurse -Destination "C:\Program Files (x86)" -Force
        }
	Elseif ($WindowsKitPath -eq $true){
        Write-Verbose -Message "Windows Kit Folder already installed, proceeding with script"
        Continue
        }

# Create a remote file share path to the target file server of new domain

New-PSDrive -Name "K" -PSProvider FileSystem -Root "\\$TargetServer\User_Profile_Backup" -Persist 

# Change directory to new created path

cd $path

# Loads the profile that was imported from the OLD workstation located in the file server

cmd /c "loadstate \\$TargetServer\User_Profile_Backup\$targetcomputer /i:migapp.xml /i:migdocs.xml $mutarget /c /v:13 /l:scan.log"

# Disconnects and removes file path

Remove-PSDrive -Name "K"


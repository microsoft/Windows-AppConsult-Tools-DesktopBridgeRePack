<#

.SYNOPSIS
MakeAPPXForWin10S

.DESCRIPTION
Takes an APPX or BUNDLE file, repackages and signs it using the Store test certificate.
There is only one parameter which is the full path to a .APPX or .APPXBUNDLE file

.EXAMPLE
Use a full path to an .APPX file:
MakeAPPXForWin10S.cmd "C:\Temp\MyDesktopBridgeFile.appx"

.EXAMPLE
Use a local path to an .APPX file:
MakeAPPXForWin10S.cmd "MyLocalfolderAPPXFile.appx"

.EXAMPLE
Use a full path to an .APPXBUNDLE file:
MakeAPPXForWin10S.cmd "MyLocalfolderAPPXBUNDLEFile.appxbundle"

.NOTES
The signed Appx/Bundle file name will be 'InitialFileNameStoreSigned.appx' or 'InitialFileNameStoreSigned.appxbundle' in the same folder as the original file

.LINK
https://github.com/sbovo/DesktopBridgeTools/tree/develop/RepackageForWindows10S

#>
[CmdletBinding()]
Param(
    [parameter(Mandatory=$true, HelpMessage="Full path to the .APPX or .APPXBUNDLE file")]
    [AllowEmptyString()]
    [string]$AppxOrBundleFile
)


# Functions
function ModifyManifestFile ($ManifestFile) {
    Add-Type -A 'System.Xml.Linq'
    try {
        $doc = [System.Xml.Linq.XDocument]::Load($ManifestFile)
    }
    catch {
        Write-Host "[Error] Not able to open '$ManifestFile'" -ForegroundColor Red
        $telemetryException = New-Object "Microsoft.ApplicationInsights.DataContracts.ExceptionTelemetry"  
        $telemetryException.Exception = $_.Exception  
        $client.TrackException($telemetryException)  
        exit
    }

    $AppxManifestModified = $false
    foreach($element in $doc.Descendants())
    {
        if($element.Name.LocalName -eq 'Identity')
        {
            foreach($attribute in $element.Attributes())
            {
                if($attribute.Name.LocalName -eq "Publisher")
                {
                    $attribute.value='CN=Appx Test Root Agency Ex'
                    $AppxManifestModified = $true
                    Write-Host "Done" -ForegroundColor Yellow
                    break
                }
            }
        }
    }
   
    if ($AppxManifestModified)
    {
        try {
             $doc.Save($AppxManifestFile);
        }
        catch {
            Write-Host "[Error] Not able to save back '$AppxManifestFile'" -ForegroundColor Red
            exit
        }
    }
    else
    {
        Write-Host "[Error] Not able to find the Publisher attribute for the identity element in '$AppxManifestFile'" -ForegroundColor Red
        exit
    }
}


function Work($AppxOrBundleFile, $InsideAppx) {
    $FileExtension = ([System.IO.Path]::GetExtension($AppxOrBundleFile)).ToUpper()
    # 1. Creates a new unique folder for extracting the Appx/Bundle files
    $Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Extracting Appx/Bundle files" -PercentComplete ($Index / $Steps * 100)
    $AppxPathOnly = Split-Path -Path $AppxOrBundleFile
    if ($AppxPathOnly -eq "") # AppxOrBundleFile is located in the current directory
    {
        # AppxPathOnly = current path
        $AppxPathOnly=Split-Path $PSScriptPath
    }
    # Does not use an unique folder name. Reusing the same folder in order to allow manual modifications
    #$CurrentDateTime = Get-Date -UFormat "%Y-%m-%d-%Hh-%Mm-%Ss"
    $AppxOrBundleFilenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($AppxOrBundleFile)
    $UnzippedFolder =  $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension #+ "_" + $CurrentDateTime
    Write-Host "[INFO] Unzipped folder = '$UnzippedFolder'"
    Write-Host "[WORK] Extracting files from '$AppxOrBundleFile' to '$UnzippedFolder'..."

    if($FileExtension -eq '.APPX') {
        # APPX
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' unpack /p $AppxOrBundleFile /d $UnzippedFolder /o
    }
    else {
        #BUNDLE
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' unbundle /p $AppxOrBundleFile /d $UnzippedFolder /o
    }
    Write-Host "Done" -ForegroundColor Yellow
    # =============================================================================


    # 2. Modifies the 'CN' in the extracted AppxManifest.xml
    $Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Modifying AppxManifest.xml file" -PercentComplete ($Index / $Steps * 100)

    # So we are looking for Publisher="CN=Blabla.�&  blablabla!?; etc..."
    # or Publisher='CN=Blabla.�&  blablabla!?; etc...'
    if($FileExtension -eq '.APPX') {
        # APPX
        $AppxManifestFile = $UnzippedFolder + "\AppxManifest.xml"
        Write-Host "[WORK] Modifying the '$AppxManifestFile' to use Publisher=""CN=Appx Test Root Agency Ex""..."
        ModifyManifestFile($AppxManifestFile)    
    }
    else {
        # BUNDLE
        $AppxManifestFile = $UnzippedFolder + "\AppxMetadata\AppxBundleManifest.xml"
        Write-Host "[WORK] Modifying the '$AppxManifestFile' to use Publisher=""CN=Appx Test Root Agency Ex""..."
        ModifyManifestFile($AppxManifestFile)
        
        # All Manifest of all packages have to be modified
        Get-ChildItem $UnzippedFolder -Filter *.appx | 
        Foreach-Object {
            Work -AppxOrBundleFile $_.FullName -InsideAppx $true     
        }
    }

    # =============================================================================


    # 3. Recreates the Appx/Bundle file with the modified AppxManifest.xml
    $Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Repackaging the Appx/Bundle file" -PercentComplete ($Index / $Steps * 100)
    $ModifiedAppxBundleFile = ""
    if($FileExtension -eq '.APPX') {
        # APPX
        if ($InsideAppx) {
            $ModifiedAppxBundleFile = $AppxOrBundleFile
        }
        else {
            $ModifiedAppxBundleFile = $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension + "StoreSigned.appx"
        }
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' pack -p $ModifiedAppxBundleFile -d $UnzippedFolder -l -o
    }
    else {
        # BUNDLE
        $ModifiedAppxBundleFile = $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension + "StoreSigned.appxbundle"
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' bundle -p $ModifiedAppxBundleFile -d $UnzippedFolder -o
    }
    if ($InsideAppx) {
        # Deletes the temp Appx fodler
        Remove-Item $UnzippedFolder -force -Recurse
    }
    Write-Host "Done" -ForegroundColor Yellow
    # =============================================================================


    # 4. Sign the Appx/Bundle file with the AppxTestRootAgency providedby the Store team
    $Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Signing the Appx file" -PercentComplete ($Index / $Steps * 100)
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe' sign /a /v /fd SHA256 /f "AppxTestRootAgency.pfx" $ModifiedAppxBundleFile
    Write-Host "Done" -ForegroundColor Yellow
    # =============================================================================


    Write-Host "`nNewly and signed Appx/Bundle file available at " -nonewline
    Write-Host "$ModifiedAppxBundleFile" -ForegroundColor Green

    # App packager (MakeAppx.exe) - https://msdn.microsoft.com/en-us/library/windows/desktop/hh446767(v=vs.85).aspx
    # Porting and testing your classic desktop applications on Windows 10 S with the Desktop Bridge - https://blogs.msdn.microsoft.com/appconsult/2017/06/15/porting-and-testing-your-classic-desktop-applications-on-windows-10-s-with-the-desktop-bridge/

    # Ends AppInsights telemetry
    $client.Flush()

    # ApplicationInsights documentation - https://docs.microsoft.com/en-us/azure/application-insights/application-insights-custom-operations-tracking
}
# =============================================================================


# Starting point
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 

# AppInsights telemetry initialization
Add-Type -Path ".\DllsLocalCopies\Microsoft.ApplicationInsights.dll"  
$client = New-Object Microsoft.ApplicationInsights.TelemetryClient  
$client.InstrumentationKey="22708eb2-9a6b-4b7f-a0a2-e67b7b5c0b03"
$client.TrackPageView("MakeAPPXForWin10S") 

if ($AppxOrBundleFile -eq '') {
    Write-Host "[Error] A .APPX or .APPXBUNDLE file was not specified." -ForegroundColor Red
    Write-Host "Please use 'get-help .\MakeAPPXForWin10S.ps1' for more details" 
    exit 
}

$FileExtension = ([System.IO.Path]::GetExtension($AppxOrBundleFile)).ToUpper()
if ($FileExtension -ne '.APPX' -and $FileExtension -ne '.APPXBUNDLE') {
    Write-Host "[Error] '$AppxOrBundleFile' is not either a .APPX or a .APPXBUNDLE file." -ForegroundColor Red
    Write-Host "Please use 'get-help .\MakeAPPXForWin10S.ps1' for more details" 
    exit 
}

$AppxExists = Test-Path $AppxOrBundleFile
if ($AppxExists -eq $false)
{
    Write-Host "[Error] '$AppxOrBundleFile' file was not found" -ForegroundColor Red
    exit
}
Write-Host "[INFO] AppxOrBundle = '$AppxOrBundleFile'"
$Index = 0
$Steps = 4

Work -AppxOrBundleFile $AppxOrBundleFile -InsideAppx $false  
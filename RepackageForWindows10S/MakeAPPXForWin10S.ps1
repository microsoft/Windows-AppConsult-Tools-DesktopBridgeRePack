[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    [string]$AppxOrBundleFile
)

Clear-Host
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 
$AppxExists = Test-Path $AppxOrBundleFile
if ($AppxExists -eq $false)
{
    Write-Host "[Error] '$AppxOrBundleFile' file was not found" -ForegroundColor Red
    exit
}
Write-Host "[INFO] AppxOrBundle = '$AppxOrBundleFile'"
$Index = 0
$Steps = 4

# 1. Creates a new unique folder for extracting the APPX/BUNDLE files
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Extracting Appx/Bundle files" -PercentComplete ($Index / $Steps * 100)
$AppxPathOnly = Split-Path -Path $AppxOrBundleFile
if ($AppxPathOnly -eq "") # AppxOrBundleFile is located in the current directory
{
    # AppxPathOnly = current path
    $AppxPathOnly=Split-Path $MyInvocation.MyCommand.Path
}
# Does not use an unique folder name. Reusing the same folder in order to allow manual modifications
#$CurrentDateTime = Get-Date -UFormat "%Y-%m-%d-%Hh-%Mm-%Ss"
$AppxOrBundleFilenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($AppxOrBundleFile)
$UnzippedFolder =  $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension #+ "_" + $CurrentDateTime
Write-Host "[INFO] Unzipped folder = '$UnzippedFolder'"
Write-Host "[WORK] Extracting files from '$AppxOrBundleFile' to '$UnzippedFolder'..."
$FileExtension = ([System.IO.Path]::GetExtension($AppxOrBundleFile)).ToUpper()
if($FileExtension -eq '.APPX') {
    # APPX
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' unpack /l /p $AppxOrBundleFile /d $UnzippedFolder
}
else {
    #BUNDLE
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' unbundle /p $AppxOrBundleFile /d $UnzippedFolder    
}
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


# 2. Modifies the 'CN' in the extracted AppxManifest.xml
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Modifying AppxManifest.xml file" -PercentComplete ($Index / $Steps * 100)
$AppxManifestFile = $UnzippedFolder + "\AppxManifest.xml"
Write-Host "[WORK] Modifying the '$AppxManifestFile' to use Publisher=""CN=Appx Test Root Agency Ex""..."
# So we are looking for Publisher="CN=Blabla.�&  blablabla!?; etc..."
# or Publisher='CN=Blabla.�&  blablabla!?; etc...'
Add-Type -A 'System.Xml.Linq'
try {
    $doc = [System.Xml.Linq.XDocument]::Load($AppxManifestFile)
}
catch {
    Write-Host "[Error] Not able to open '$AppxManifestFile'" -ForegroundColor Red
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
# =============================================================================


# 3. Recreates the Appx file with the modified AppxManifest.xml
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Repackaging the Appx/Bundle file" -PercentComplete ($Index / $Steps * 100)
$ModifiedAppxFile = ""
if($FileExtension -eq '.APPX') {
    # APPX
    $ModifiedAppxFile = $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension + "StoreSigned.appx"
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' pack -p $ModifiedAppxFile -d $UnzippedFolder
}
else {
    #BUNDLE
    $ModifiedAppxFile = $AppxPathOnly + "\" + $AppxOrBundleFilenameWithoutExtension + "StoreSigned.appxbundle"
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' bundle -p $ModifiedAppxFile -d $UnzippedFolder
}
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


# 4. Sign the Appx file with the AppxTestRootAgency providedby the Store team
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Signing the Appx file" -PercentComplete ($Index / $Steps * 100)
& 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe' sign /a /v /fd SHA256 /f "AppxTestRootAgency.pfx" $ModifiedAppxFile
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


Write-Host "`nNewly and signed Appx file available at " -nonewline
Write-Host "$ModifiedAppxFile" -ForegroundColor Green

# App packager (MakeAppx.exe) - https://msdn.microsoft.com/en-us/library/windows/desktop/hh446767(v=vs.85).aspx
# Porting and testing your classic desktop applications on Windows 10 S with the Desktop Bridge - https://blogs.msdn.microsoft.com/appconsult/2017/06/15/porting-and-testing-your-classic-desktop-applications-on-windows-10-s-with-the-desktop-bridge/
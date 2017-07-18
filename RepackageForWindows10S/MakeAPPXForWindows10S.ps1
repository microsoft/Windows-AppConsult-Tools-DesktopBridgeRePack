[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    [string]$AppxFile
)

Clear-Host
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 
Write-Host "[INFO] AppxFile = '$AppxFile'"
$Index = 0
$Steps = 4

# 1. Create a new unique folder for extracting the APPX files
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx for Windows 10S" -status "Extracting Appx files" -PercentComplete ($Index / $Steps * 100)
$AppxPathOnly = Split-Path -Path $AppxFile
if ($AppxPathOnly -eq "") # AppxFile is located in the current directory
{
    # AppxPathOnly = current path
    $AppxPathOnly=Split-Path $MyInvocation.MyCommand.Path
}
$CurrentDateTime = Get-Date -UFormat "%Y-%m-%d-%Hh-%Mm-%Ss"
$AppxFilenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($AppxFile)
$UnzippedFolder =  $AppxPathOnly + "\" + $AppxFilenameWithoutExtension + "_" + $CurrentDateTime
Write-Host "[INFO] Unzipped folder = '$UnzippedFolder'"
Write-Host "[WORK] Extracting files from '$AppxFile' to '$UnzippedFolder'..."
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory($AppxFile, $UnzippedFolder)
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


# 2. Modify the 'CN' in the extracted AppxManifest.xml
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx for Windows 10S" -status "Modifying AppxManifest.xml file" -PercentComplete ($Index / $Steps * 100)
$AppxManifestFile = $UnzippedFolder + "\AppxManifest.xml"
Write-Host "[WORK] Modifying the '$AppxManifestFile' to use Publisher=""CN=Appx Test Root Agency Ex""..."
$AppxManifestContent = Get-Content -path $AppxManifestFile
# [^"]+ = Any characters except "
# So we are looking for Publisher="CN=Blabla.²&  blablabla!?; etc..."
$AppxManifestContent -Replace 'Publisher="CN=[^"]+"', 'Publisher="CN=Appx Test Root Agency Ex"' | Out-File  -Encoding "UTF8" $AppxManifestFile
#$AppxManifestContent -Replace "Publisher='CN=[^']+'", 'Publisher="CN=Appx Test Root Agency Ex"' | Out-File  -Encoding "UTF8" $AppxManifestFile

Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


# 3. Recreate the Appx file with the modified AppxManifest.xml
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx for Windows 10S" -status "Repackaging the Appx file" -PercentComplete ($Index / $Steps * 100)
$ModifiedAppxFile = $AppxPathOnly + "\" + $AppxFilenameWithoutExtension + "StoreSigned.appx"
& 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' pack -p $ModifiedAppxFile -d $UnzippedFolder -l
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


# 4. Sign the Appx file with the AppxTestRootAgency providedby the Store team
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx for Windows 10S" -status "Signing the Appx file" -PercentComplete ($Index / $Steps * 100)
& 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe' sign /a /v /fd SHA256 /f "AppxTestRootAgency.pfx" $ModifiedAppxFile
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


Write-Host "`nNewly and signed Appx file available at " -nonewline
Write-Host "$ModifiedAppxFile" -ForegroundColor Green

# App packager (MakeAppx.exe) - https://msdn.microsoft.com/en-us/library/windows/desktop/hh446767(v=vs.85).aspx
# Porting and testing your classic desktop applications on Windows 10 S with the Desktop Bridge - https://blogs.msdn.microsoft.com/appconsult/2017/06/15/porting-and-testing-your-classic-desktop-applications-on-windows-10-s-with-the-desktop-bridge/
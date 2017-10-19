[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    [string]$AppxFolder,
    [parameter(Mandatory=$false, HelpMessage="$true if the folder is a Bundle, $false if it is a simple Appx")]
    [switch]$IsBundle = $false
)


[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 
$AppxFolderExists = Test-Path $AppxFolder
if ($AppxFolderExists -eq $false)
{
    Write-Host "[Error] '$AppxFolder' folder was not found" -ForegroundColor Red
    exit
}
Write-Host "[INFO] AppxFolder = '$AppxFolder'"
Write-Host "[INFO] IsBundle   = '$IsBundle'"
$Index = 0
$Steps = 2

# 1. Recreates the Appx file with the modified AppxManifest.xml
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Repackaging the Appx file" -PercentComplete ($Index / $Steps * 100)
if ($IsBundle) {
    # BUNDLE
    $AppxFile = $AppxFolder + "StoreSigned.appxbundle"
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' bundle -p $AppxFile -d $AppxFolder -o
}
else {
    # APPX
    $AppxFile = $AppxFolder + "StoreSigned.appx"
    & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' pack -p $AppxFile -d $AppxFolder -o
}
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


# 2. Sign the Appx file with the AppxTestRootAgency providedby the Store team
$Index += 1
Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Signing the Appx file" -PercentComplete ($Index / $Steps * 100)
& 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe' sign /a /v /fd SHA256 /f "AppxTestRootAgency.pfx" $AppxFile
Write-Host "Done" -ForegroundColor Yellow
# =============================================================================


Write-Host "`nNewly and signed Appx/Bundle file available at " -nonewline
Write-Host "$AppxFile" -ForegroundColor Green

# App packager (MakeAppx.exe) - https://msdn.microsoft.com/en-us/library/windows/desktop/hh446767(v=vs.85).aspx
# Porting and testing your classic desktop applications on Windows 10 S with the Desktop Bridge - https://blogs.msdn.microsoft.com/appconsult/2017/06/15/porting-and-testing-your-classic-desktop-applications-on-windows-10-s-with-the-desktop-bridge/
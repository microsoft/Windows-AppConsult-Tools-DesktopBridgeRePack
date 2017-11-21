<#

.SYNOPSIS
RepackageAPPXFolderForWin10S

.DESCRIPTION
Takes an Appx/Bundle folder, repackages and sign it using the Store test certificate
There are two parameters
- The full path to the folder to package
- (Optional switch) -IsBundle

.EXAMPLE
Use a full path to an folder containing for APPX packaging:
`RepackageAPPXFolderForWin10S.cmd "C:\Temp\MyDesktopBridgeFolder"`

.EXAMPLE
Use a local path to a folder for APPX packaging:
`RepackageAPPXFolderForWin10S.cmd "LocalDesktopBridgeFolder"`

.EXAMPLE
Use a full path to a folder for APPXBUNDLE packaging:
`RepackageAPPXFolderForWin10S.cmd "C:\Temp\MyDesktopBridgeBundleFolder" -IsBundle`

.NOTES
The signed Appx/Bundle file name will be 'FolderNameStoreSigned.appx' or 'FolderNameStoreSigned.appxbundle' in the same folder as the original folder

.LINK
https://github.com/sbovo/DesktopBridgeTools/tree/develop/RepackageForWindows10S

#>[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)]
    [string]$AppxFolder,
    [parameter(Mandatory=$false, HelpMessage="true if the folder is a Bundle, false if it is a simple Appx")]
    [switch]$IsBundle = $false
)






function Repack($Folder, $Bundle) {
    # 1. Recreates the Appx file with the modified AppxManifest.xml
    $Index += 1
    Write-Progress -Activity "[$($Index)/$($Steps)] Make Appx/Bundle for Windows 10S" -status "Repackaging the Appx/Bundle file" -PercentComplete ($Index / $Steps * 100)
    $AppxFile = ([System.IO.DirectoryInfo]$AppxFolder).Parent.FullName + "\" +  [System.IO.Path]::GetFileNameWithoutExtension($AppxFolder)
    if ($IsBundle) {
        # BUNDLE
        $AppxFile = $AppxFile + "StoreSigned.appxbundle"
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' bundle -p $AppxFile -d $AppxFolder -l -o
    }
    else {
        # APPX
        $AppxFile = $AppxFile + "StoreSigned.appx"
        & 'C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe' pack -p $AppxFile -d $AppxFolder -l -o
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

    # Ends AppInsights telemetry
    $client.Flush()
}
# =============================================================================






# Starting point
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 

# AppInsights telemetry initialization
Add-Type -Path ".\DllsLocalCopies\Microsoft.ApplicationInsights.dll"  
$client = New-Object Microsoft.ApplicationInsights.TelemetryClient  
$client.InstrumentationKey="22708eb2-9a6b-4b7f-a0a2-e67b7b5c0b03"
$client.TrackPageView("RepackageAPPXFolderForWin10S") 

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

Repack -AppxOrBundleFile $AppxFolder -IsBundle $IsBundle  
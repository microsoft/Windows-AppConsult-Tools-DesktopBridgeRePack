# DesktopBridgeTools

Create and test your Desktop Bridge Apps Easely

## MakeAPPXForWin10S.cmd tool

The cmd just take an Appx/Bundle filename as parameter. It "repackages" and signs it with the Store AppxTestRootAgency certificate provided in the [documentation](https://docs.microsoft.com/en-us/windows/uwp/porting/desktop-to-uwp-test-windows-s)

Usage and details are available in the [**RepackageForWindows10S**](RepackageForWindows10S) folder of this repo

## RepackageAPPXFolderForWin10S.cmd tool

The cmd takes a folder path as paramater. The folder path is the extracted content for an Appx/Bundle. This tool is useful if you need to modify manually some files like the manifest or assets. The purpose is to repackage the folder into an Appx/Bundle and sign it using the Store AppxTestRootAgency certificate.

Usage and details are available in the [**RepackageForWindows10S**](RepackageForWindows10S) folder of this repo

## Notes

> The direct link for downloading the AppxTestRootAgency Store certificate is <https://go.microsoft.com/fwlink/?linkid=849018>


> The script uses Application Insights for strictly anonymous usage reports. There is no personal data collected. You are free to comment in scripts the lines using '$client' to remove any Application Insights usage.
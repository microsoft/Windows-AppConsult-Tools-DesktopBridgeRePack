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


# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

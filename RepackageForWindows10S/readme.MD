# MakeAPPXForWindows10S
## Usage
`MakeAPPXForWindows10S.cmd "C:\Temp\MyDesktopBridgeFile.appx"`

`MakeAPPXForWindows10S.cmd "MyLocalfolderAPPXFile.appx"`

## Actions
1. Creates a new unique folder for extracting the APPX files
2. Modifies the 'CN' in the extracted AppxManifest.xml
3. Recreates the Appx file with the modified AppxManifest.xml
4. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'InitialFileNameStoreSigned.appx'
  
# RepackageAPPXFolderForWindows10S
## Usage
`RepackageAPPXFolderForWindows10S.cmd "C:\Temp\MyDesktopBridgeFolder"`

`RepackageAPPXFolderForWindows10S.cmd "LocalDesktopBridgeFolder"`

## Actions
3. Recreates the Appx file with the content of the DesktopBridge folder
4. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'FolderNameStoreSigned.appx'

 MakeAPPXForWin10S
## Usage
`MakeAPPXForWin10S.cmd "C:\Temp\MyDesktopBridgeFile.appx"`

`MakeAPPXForWin10S.cmd "MyLocalfolderAPPXFile.appx"`

## Actions
1. Creates a new unique folder for extracting the APPX files
2. Modifies the 'CN' in the extracted AppxManifest.xml
3. Recreates the Appx file with the modified AppxManifest.xml
4. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'InitialFileNameStoreSigned.appx'
  
# RepackageAPPXFolderForWin10S
## Usage
`RepackageAPPXFolderForWin10S.cmd "C:\Temp\MyDesktopBridgeFolder"`

`RepackageAPPXFolderForWin10S.cmd "LocalDesktopBridgeFolder"`

## Actions
1. Recreates the Appx file with the content of the DesktopBridge folder
2. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'FolderNameStoreSigned.appx'

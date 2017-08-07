# MakeAPPXForWin10S
Takes a APPX file, repackages and sign it using the Store test certificate

## Usage
`MakeAPPXForWin10S.cmd "C:\Temp\MyDesktopBridgeFile.appx"`

`MakeAPPXForWin10S.cmd "MyLocalfolderAPPXFile.appx"`
<script src="https://gist.github.com/sbovo/d8ba18f79729b468c836f956774337b3.js"></script>

## Actions
1. Creates a new unique folder for extracting the APPX files
2. Modifies the 'CN' in the extracted AppxManifest.xml
3. Recreates the Appx file with the modified AppxManifest.xml
4. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'InitialFileNameStoreSigned.appx'
  
# RepackageAPPXFolderForWin10S
Takes an APPX folder, repackages and sign it using the Store test certificate
## Usage
`RepackageAPPXFolderForWin10S.cmd "C:\Temp\MyDesktopBridgeFolder"`

`RepackageAPPXFolderForWin10S.cmd "LocalDesktopBridgeFolder"`

## Actions
1. Recreates the Appx file with the content of the DesktopBridge folder
2. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'FolderNameStoreSigned.appx'

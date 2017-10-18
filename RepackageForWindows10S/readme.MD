# MakeAPPXForWin10S (supports BUNDLE)
Takes an APPX or BUNDLE file, repackages and signs it using the Store test certificate

## Usage
`MakeAPPXForWin10S.cmd "C:\Temp\MyDesktopBridgeFile.appx"`

`MakeAPPXForWin10S.cmd "MyLocalfolderAPPXFile.appx"`

`MakeAPPXForWin10S.cmd "MyLocalfolderAPPXBUNDLEFile.appxbundle"`

## Actions
1. Creates a new unique folder for extracting the APPX/BUNDLE files
2.1 If APPX, modifies the 'CN' in the extracted AppxManifest.xml
2.2 If BUNDLE, modifies the 'CN' in the extracted AppxMetadata\AppxBundleManifest.xml
3. Recreates the Appx file with the modified AppxManifest.xml
4. Signs the Appx/Bundle file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx/Bundle file name will be 'InitialFileNameStoreSigned.appx' 
> or
> 'InitialFileNameStoreSigned.appxbundle' 
  
# RepackageAPPXFolderForWin10S (BUNDLE Support soon)
Takes an APPX folder, repackages and sign it using the Store test certificate
## Usage
`RepackageAPPXFolderForWin10S.cmd "C:\Temp\MyDesktopBridgeFolder"`

`RepackageAPPXFolderForWin10S.cmd "LocalDesktopBridgeFolder"`

## Actions
1. Recreates the Appx file with the content of the DesktopBridge folder
2. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'FolderNameStoreSigned.appx'

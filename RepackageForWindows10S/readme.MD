# MakeAPPXForWin10S (supports BUNDLE)
Takes an Appx or Bundle file, repackages and signs it using the Store test certificate

## Usage
`MakeAPPXForWin10S.cmd "C:\Temp\MyDesktopBridgeFile.appx"`

`MakeAPPXForWin10S.cmd "MyLocalfolderAPPXFile.appx"`

`MakeAPPXForWin10S.cmd "MyLocalfolderAPPXBUNDLEFile.appxbundle"`

## Actions for APPX
1. Creates a new unique folder for extracting the Appx files
2. Modifies the 'CN' in the extracted AppxManifest.xml
3. Recreates the Appx file with the modified AppxManifest.xml
4. Signs the Appx file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'InitialFileNameStoreSigned.appx' 

## Actions for BUNDLE
1. Creates a new unique folder for extracting the Bundle files
2. Modifies the 'CN' in the extracted AppxMetadata\AppxBundleManifest.xml
3. Takes each internal Appx and do the same work as the one done for an unique Appx (extraction, AppxManifest.xml modification, packaging, signature)
4. Recreates the Bundle file with the modified AppxMetadata\AppxBundleManifest.xml and modified packages
5. Signs the Appx/Bundle file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Bundle file name will be 'InitialFileNameStoreSigned.appxbundle' 
  
# RepackageAPPXFolderForWin10S (supports BUNDLE)
Takes an Appx/Bundle folder, repackages and sign it using the Store test certificate
## Usage
### For Appx
`RepackageAPPXFolderForWin10S.cmd "C:\Temp\MyDesktopBridgeFolder"`

`RepackageAPPXFolderForWin10S.cmd "LocalDesktopBridgeFolder"`

### For Bundle
`RepackageAPPXFolderForWin10S.cmd "C:\Temp\MyDesktopBridgeBundleFolder" -IsBundle`

`RepackageAPPXFolderForWin10S.cmd "LocalDesktopBridgeBundleFolder" -IsBundle`

## Actions
1. Recreates the Appx/Bundle file with the content of the DesktopBridge folder
2. Signs the Appx/bundle file with the AppxTestRootAgency provided by the Store team ([direct link for downloading the certificate](https://go.microsoft.com/fwlink/?linkid=849018))

> The signed Appx file name will be 'FolderNameStoreSigned.appx'
> or
> 'FolderNameStoreSigned.appxbundle' 

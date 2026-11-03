Unicode true
Name "${PRODUCT_NAME}"
OutFile "${OUTPUT_PATH}"
RequestExecutionLevel user
SilentInstall silent
SetCompressor zlib
VIProductVersion "1.5.1.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "FileDescription" "${PRODUCT_NAME}"
VIAddVersionKey "FileVersion" "1.5.1"
VIAddVersionKey "ProductVersion" "1.5.1"
VIAddVersionKey "LegalCopyright" "Includes the official RustDesk client"

Section
  InitPluginsDir
  SetOutPath "$PLUGINSDIR"
  File "/oname=rustdesk--${SERVER_CONFIG}.exe" "${CLIENT_PATH}"
  ClearErrors
  ExecWait '"$PLUGINSDIR\rustdesk--${SERVER_CONFIG}.exe"' $0
  IfErrors launch_error
  SetErrorLevel $0
  Goto done

launch_error:
  MessageBox MB_OK|MB_ICONSTOP "Não foi possível iniciar o RustDesk."
  SetErrorLevel 1

done:
SectionEnd

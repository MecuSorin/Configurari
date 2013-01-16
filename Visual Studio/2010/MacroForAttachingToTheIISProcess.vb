Imports System
Imports EnvDTE80
Imports System.Diagnostics

Public Module AttachToWebServer

   Public Sub AttachToWebServer()

      Dim AspNetWp As String = "aspnet_wp.exe"
      Dim W3WP As String = "w3wp.exe"

      If Not (AttachToProcess(AspNetWp)) Then 
         If Not AttachToProcess(W3WP) Then 
            System.Windows.Forms.MessageBox.Show(String.Format("Process {0} or {1} Cannot Be Found", AspNetWp, W3WP), "Attach To Web Server Macro") 
         End If 
      End If 

   End Sub

   Public Function AttachToProcess(ByVal ProcessName As String) As Boolean 

      Dim Processes As EnvDTE.Processes = DTE.Debugger.LocalProcesses 
      Dim Process As EnvDTE.Process 
      Dim ProcessFound As Boolean = False 

      For Each Process In Processes 
         If (Process.Name.Substring(Process.Name.LastIndexOf("\") + 1) = ProcessName) Then 
            Process.Attach() 
            ProcessFound = True 
         End If
      Next

      AttachToProcess = ProcessFound 

   End Function

End Module
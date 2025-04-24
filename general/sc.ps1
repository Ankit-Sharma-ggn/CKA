 # Define task details
 $taskName = "WiresharkCapture"
 $scriptPath = "D:\capture\wireshark_capture.ps1"
 $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
 $trigger = New-ScheduledTaskTrigger -AtStartup
 
 # Optional: Make it repeat every 1 minute indefinitely
 # Trigger: Run once at system startup
 $trigger = New-ScheduledTaskTrigger -AtStartup
 
 # Run as SYSTEM
 $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
 
 # Register the task
 Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal
 
 
 Start-ScheduledTask -TaskName WiresharkCapture 
 
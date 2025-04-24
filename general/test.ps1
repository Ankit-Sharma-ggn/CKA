 # Define the URL and output CSV file
 $urls = "mckinsey-npn.oktapreview.com","google.com","amdc-wintel03.ads.mckinsey.com"  # Test-Connection requires a hostname or IP, not a full URL
 $outputCsv = "C:\temp\poll_results.csv"
 
 #### function to check if the URL is reachable  
 function Test-urlConnection {
     param (
         [string]$url
     )
     try {
         # Send a ping request to the URL
         $response = Test-netConnection  $url -port 443 -ErrorAction Stop
         $statusCode = "Success"
         $statusDescription = "Connection successful"
         # Check if the response is successful   
     } catch {
         $statusCode = "Error"
         $statusDescription = $_.Exception.Message
     }
     $list = [ordered]@{
 
         Timestamp = $timestamp
         url = $url
         Remoteaddress = $response.RemoteAddress
         TcpTestSucceeded = $response.TcpTestSucceeded
         NameResolutionSucceeded = $response.NameResolutionSucceeded
         StatusCode = $statusCode
         StatusDescription = $statusDescription
 
     }
     # Convert the list to a CSV format  
     $psobject = New-Object PSObject -Property $list
     return $psobject
 }
 while($true){
     $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
     foreach ( $url in $urls){
         # Call the function to check the URL connection
         $psobject = Test-urlConnection -url $url
         $psobject | Export-Csv -Path $outputCsv -NoTypeInformation -Append       
     }
     # Wait for 5 seconds before the next poll
     Start-Sleep -Seconds 2
     write-host "cycle completed"
 }

 
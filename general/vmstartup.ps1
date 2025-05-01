# Define the list of servers
$servers = @("Server1", "Server2", "Server3") # Replace with your server names

# Initialize an array to store the results
$results = @()

foreach ($server in $servers) {
    try {
        # Get the shares on the server
        $shares = Get-WmiObject -Class Win32_Share -ComputerName $server -ErrorAction Stop

        foreach ($share in $shares) {
            # Get the share path
            $path = $share.Path

            if (Test-Path -Path $path) {
                # Get file system information
                $fileInfo = Get-Item $path

                # Add the details to the results array
                $results += [PSCustomObject]@{
                    Server       = $server
                    ShareName    = $share.Name
                    SharePath    = $path
                    LastAccessed = $fileInfo.LastAccessTime
                    LastModified = $fileInfo.LastWriteTime
                    CreationDate = $fileInfo.CreationTime
                }
            }
        }
    } catch {
        Write-Warning "Failed to retrieve shares from $server: $_"
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "ShareDetails.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Share details have been exported to ShareDetails.csv"
# Script to fetch details of all delegated zones inside a primary zone

# Define the primary zone
$PrimaryZone = "example.com"

# Get all DNS zones
$Zones = Get-DnsServerZone -ComputerName localhost

# Filter delegated zones within the primary zone
$DelegatedZones = $Zones | Where-Object {
    $_.ZoneType -eq "Secondary" -or $_.ZoneType -eq "Stub" -and $_.ZoneName -like "*.$PrimaryZone"
}

# Output the details of delegated zones
if ($DelegatedZones) {
    Write-Host "Delegated Zones inside the primary zone '$PrimaryZone':"
    $DelegatedZones | ForEach-Object {
        Write-Host "Zone Name: $($_.ZoneName)"
        Write-Host "Zone Type: $($_.ZoneType)"
        Write-Host "-----------------------------------"
    }
} else {
    Write-Host "No delegated zones found inside the primary zone '$PrimaryZone'."
}
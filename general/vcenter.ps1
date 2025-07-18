$filepath = ""

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be executed with administrative privileges."
    exit 1
}


Write-Verbose "Running as Administrator"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

Write-Verbose "Disconnecting from any existing vCenter Server connection"
try {
    Disconnect-VIServer * -Confirm:$false -ErrorAction Stop | Out-Null
} catch {
    Write-Verbose "No active vCenter sessions to disconnect."
}

#$vcenterFQDN = Read-Host -Prompt 'Enter your vCenter Server FQDN'
$vcenterFQDNs = gc "$filepath\vcenterlist.txt"


$username = Read-Host -Prompt 'Enter your username'
$password = Read-Host -Prompt 'Enter your password' -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

foreach( $vcenterFQDN in $vcenterFQDNS){
    Write-Verbose "Connecting to $vcenterFQDN"
    try {
        Connect-VIServer -Server $vcenterFQDN -Credential $credential | Out-Null
        Write-Verbose "Connected to $vcenterFQDN"
    } catch {
        Write-Error "Failed to connect to vCenter: $($_.Exception.Message)"
        exit 1
    }

# --- Netmask to Prefix conversion function ---
    function Convert-NetmaskToPrefix {
        param (
            [Parameter(Mandatory = $true)]
            [string]$Netmask
        )

        $octets = $Netmask.Split('.')
        $binaryMask = ($octets | ForEach-Object { [Convert]::ToString([int]$_, 2).PadLeft(8, '0') }) -join ''
        return ($binaryMask -split '1').Length - 1
    }

    $esxiHosts = Get-VMHost | Where-Object { $_.ConnectionState -eq 'Connected' }
    Write-Verbose "Retrieved $($esxiHosts.Count) ESXi Host(s)"

    $output = @()
    $hostCounter = 0
    $totalHosts = $esxiHosts.Count

    foreach ($esxiHost in $esxiHosts) {
        $hostCounter++
    
        $progressParams = @{
            Activity = "Processing ESXi Hosts"
            Status = "Processing host $hostCounter of $totalHosts - $($esxiHost.Name)"
            PercentComplete = (($hostCounter / $totalHosts) * 100)
        }
        Write-Progress @progressParams
    
        Write-Host "[$hostCounter/$totalHosts] Processing ESXi host: $($esxiHost.Name)" -ForegroundColor Cyan
        Write-Verbose "Processing ESXi host: $($esxiHost.Name)"
    
        $cluster = Get-Cluster | Where-Object { $_.ExtensionData.Host -contains $esxiHost.ExtensionData.MoRef }
    
        if (-not $cluster) {
            Write-Host "  |-- Cluster: Standalone" -ForegroundColor Yellow
            Write-Verbose "$($esxiHost.Name) is not part of a cluster, setting Cluster value to 'Standalone'"
            $clusterName = "Standalone"
        } else {
            Write-Host "  |-- Cluster: $($cluster.Name)" -ForegroundColor Green
            Write-Verbose "$($esxiHost.Name) belongs to the cluster: $($cluster.Name)"
            $clusterName = $cluster.Name
        }
    
        $vmkernelAdapters = Get-VMHostNetworkAdapter -VMHost $esxiHost -VMKernel
        $hostVmkCount = 0
    
        Write-Host "  |-- Found $($vmkernelAdapters.Count) VMkernel adapter(s)" -ForegroundColor Gray
    
        foreach ($vmk in $vmkernelAdapters) {
            if ($vmk.IP -and $vmk.IP -ne "0.0.0.0") {
                Write-Host "      |-- $($vmk.Name): $($vmk.IP)/$($vmk.SubnetMask)" -ForegroundColor White
                Write-Verbose "Found VMkernel adapter $($vmk.Name) with IP: $($vmk.IP)"
                $hostVmkCount++
            
                $prefixLength = Convert-NetmaskToPrefix -Netmask $vmk.SubnetMask

                $hostInfo = [PSCustomObject]@{
                    Cluster      = $clusterName
                    ESXiHost     = $esxiHost.Name
                    VMKernel     = $vmk.Name
                    IPAddress    = $vmk.IP
                    SubnetMask   = $vmk.SubnetMask
                    PrefixLength = $prefixLength
                }
                $output += $hostInfo
            } else {
                Write-Host "      |-- $($vmk.Name): No valid IP address" -ForegroundColor DarkGray
            }
        }
    
        if ($hostVmkCount -eq 0) {
            Write-Warning "No VMkernel adapters with valid IP addresses found on ESXi host: $($esxiHost.Name)"
        }
    
        Write-Host ""
    }

    Write-Progress -Activity "Processing ESXi Hosts" -Completed

    Write-Verbose "Found $($output.Count) VMkernel adapters total"

    if ($output.Count -eq 0) {
        Write-Warning "No VMkernel adapter information was collected from any ESXi host. Check credentials, permissions, or network state."
    } else {
        $vcenterName = $vcenterFQDN -replace '\..*$', ''
        $csvFileName = "esxi_hosts_network_info_$vcenterName.csv"
    
        Write-Verbose "Writing output to CSV file: $csvFileName"
        $output | Export-Csv -Path "$filepath\$csvFileName" -NoTypeInformation
        Write-Host "Successfully created $csvFileName with $($output.Count) entries" -ForegroundColor Green
    }

    Write-Verbose "Disconnecting from vCenter Server"
    Disconnect-VIServer * -Confirm:$false
}
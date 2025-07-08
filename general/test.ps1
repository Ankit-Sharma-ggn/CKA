Configuration DSC-APC-DNSCaching

{

Import-DscResource -ModuleName 'PSDesiredStateConfiguration', 'xPSDesiredStateConfiguration', 'xPendingReboot'

 Node DSC-APC-DNSCaching 
    {
	#Install Role 'DNS Server'
		WindowsFeature DNS
		{
		Ensure = "Present"
		Name = "DNS"
		}
	#Install Role 'File and Storage Services'

	                #Install Feature "DNS Server Tools"
		                WindowsFeature RSAT-DNS-Server
		                {
		                Ensure = "Present"
		                Name = "RSAT-DNS-Server"
		                }

	#Copies the Firewall Rule File, Print Drivers File, and DNS Conditional forwarders info
		File "DSCFilecopy"
        {
            Ensure = "Present" 
            Type = "Directory"
            MatchSource = $True
			Checksum = "SHA-256"
            Recurse = $true
            SourcePath = "\\apc-dsc02\DSCShared\"
            DestinationPath = "C:\DSCFiles\"    
        }	

#Creates the DNS Conditional Forwarder Zones and associated Master Servers
        Script "Creates DNS Conditional Forward Zones and Associated Master Servers"
        {
        SetScript = {
			$csv= Import-Csv -Path C:\DSCFiles\DNS\APCDNSZonesMaster.csv
   			$special_csv = Import-Csv -Path "C:\DSCFiles\DNS\APCDNSSpecialZones.csv" | where { $_.Specialservers.split(",") -contains $(hostname) } | select name, DsIntegrated, MasterServers, AllowUpdate
            		if ( $special_csv ) { $csv += $special_csv } 
        	##Get Server Secondary Zones
            $existingconditional=Get-CimInstance -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -Filter "ZoneType = 4"|Select -Property @{n='Name';e={$_.ContainerName}}, @{n='MasterServers';e={([string]::Join(',', $_.MasterServers))}}
			##Function to remove Secondary Zones that will became Forwarders
			function RemoveSecondary
			{
			$Secondaryzones=Get-DnsServerZone -ErrorAction Ignore|Where-Object -FilterScript {$_.ZoneType -eq "Secondary"}
			if($Secondaryzones -ne $null)
				{
				foreach ($zone in $Secondaryzones)
					{
						If($csv.name -contains $zone.ZoneName)
						{
						$zone|Remove-DnsServerZone -Force
						}
					}
				}
			}
			
			### Function to create local DNS Conditional Forwareders.
            
            function fcnConfigureDNSRecord 
            
            {
            ### Index in to DNSZones array for the region.
            
            $ZoneName         = $NewDNSZone.Name
            $MasterServers    = $NewDNSZone.MasterServers -split ","
            
	        ### Create / Set Forwarders
            $cfzonecheck =$existingconditional|Where-Object -Property Name -EQ $ZoneName
            if($cfzonecheck -eq $null)
                {
                Add-DnsServerConditionalForwarderZone -Name $ZoneName -MasterServers $MasterServers -ForwarderTimeout 2
                }
            else
                {
                Set-DnsServerConditionalForwarderZone -Name $ZoneName -MasterServers $MasterServers -ForwarderTimeout 2
                }

            }
			### This section Removes Extra Zones.
			if($existingconditional -ne $null)
				{
				$compare = Compare-Object -ReferenceObject $existingconditional.Name -DifferenceObject $csv.Name
				}
			else
				{
					$compare = $null
				}
			if($compare -ne $null)
				{
					foreach($extra in $compare.InputObject)
					{
						if($existingconditional.Name -contains $extra)
						{
						Get-DnsServerZone -Name $extra|Remove-DnsServerZone -force
						}					
					}
				}		
			### This section creates Conditional Forwarders for the core Zones.  These entries are required!	

			RemoveSecondary

	        foreach ($NewDNSZone in $csv)
	        {
			        fcnConfigureDNSRecord
	
	        }

            }

        TestScript = {

        $Current=Get-CimInstance -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -Filter "ZoneType = 4"|Select -Property @{n='Name';e={$_.ContainerName}}, @{n='DsIntegrated';e={$_.DsIntegrated}}, @{n='MasterServers';e={([string]::Join(',', $_.MasterServers))}}, @{n='AllowUpdate';e={$_.AllowUpdate}}#|Export-csv -NoTypeInformation -Path D:\amdc-dns01.csv
	$csv= Import-Csv -Path C:\DSCFiles\DNS\APCDNSZonesMaster.csv
 	$csv= Import-Csv -Path C:\DSCFiles\DNS\APCDNSZonesMaster.csv
        $special_csv = Import-Csv -Path "C:\DSCFiles\DNS\APCDNSSpecialZones.csv" | where { $_.Specialservers.split(",") -contains $(hostname) } | select name, DsIntegrated, MasterServers, AllowUpdate
        if ( $special_csv ) { $csv += $special_csv } 
		if($Current -ne $null)
			{
				$compare = Compare-Object -ReferenceObject $Current -DifferenceObject $csv -Property Name,MasterServers
			}
		else
			{
				$compare="empty"
			}
        if($compare -eq $null)
            {$CFmatch=$true}
        else
            {$CFmatch=$false}
        $CFmatch

            }

        GetScript = {
            return @{Result="Creates the DNS Conditional Forwarder Zones and associated Master Servers"}
		}
		DependsOn = "[File]DSCFilecopy"
}

#Verifies DNS Server Pollution protection is Enabled
    Script DNSServerPollutionProtection
    {
    SetScript = {
    Set-DnsServerCache -PollutionProtection $true
    }
    TestScript = {
	$check=Get-DnsServerCache
		if($check.EnablePollutionProtection -eq "True")
			{
			$protectioncheck=$true
			}
		else
			{
			$protectioncheck=$false
			}
		$protectioncheck
    }
    GetScript = {
    return @{Result="Verifies DNS Server Pollution protection is Enabled"}
    }
	}
		#Add Secondary Zone for Offices Only xxx.mckinsey.com
		Script DNSofficeSecondaryZone
		{
			SetScript = {
				$secmasters=(((Get-DscLocalConfigurationManager).PartialConfigurations.Description|Where-Object -Filter {$_ -like "*FileServer*"}) -split "-")[1]
				if($secmasters -eq "AM"){$secmasters="157.191.125.136"}elseif($secmasters -eq "APC"){$secmasters="156.107.74.71"}elseif($secmasters -eq "EU"){$secmasters="10.109.133.4"}else{$secmasters="157.191.125.136"}
				$officecode=((Get-WmiObject Win32_ComputerSystem).Name -split "-")[0]
				if($officecode -eq "dev" -or $officecode -eq "win"){$officecode="amc"}
				$officezone= $officecode + ".mckinsey.com"
				Add-DnsServerSecondaryZone -Name $officezone -MasterServers $secmasters -ZoneFile ($officezone + ".dns")
			}
			TestScript = {
				$LCM=(Get-DscLocalConfigurationManager).PartialConfigurations.Description
				If($LCM -contains "DSC-AM-FileServer" -or $LCM -contains "DSC-EU-FileServer" -or $LCM -contains "DSC-APC-FileServer" -or $LCM -contains "DSC-DEV-FileServer")
					{
						$office=$true
						$officecode=((Get-WmiObject Win32_ComputerSystem).Name -split "-")[0]
						if($officecode -eq "dev" -or $officecode -eq "win"){$officecode="amc"}
						$officezone= $officecode + ".mckinsey.com"
						$Secondaryzones=Get-DnsServerZone -ErrorAction Ignore|Where-Object -FilterScript {$_.ZoneType -eq "Secondary"}
						if($Secondaryzones.ZoneName -contains $officezone)
						{
							$result=$true
						}
						else
						{
							$result=$false
						}
					}
				else
				{
					$result=$true
				}
				$result
			}
			GetScript = {
			return @{Result="Office Only - Verifies Office Secondary Zones Exist"}
			}
		}

        Script "Disable IPv6 DNS Queries"{
            GetScript = {
                return @{Result="Disable ipv6 DNS queries"}
            }
            
            setscript = {
                Add-DnsServerQueryResolutionPolicy -action DENY -name "DisableIPv6Queries" -QType "EQ,AAAA"
            }
        
            Testscript = {
                $policystate = Get-DnsServerQueryResolutionPolicy -name DisableIPv6Queries
                if($policystate.IsEnabled ){ 
                    $true 
                }
                else{ 
                    $false 
                } 
            }
        }
    }
}

DSC-APC-DNSCaching -ConfigurationData $ConfigData -OutputPath "D:\DSC_Temp\DSC-APC-DNSCaching"
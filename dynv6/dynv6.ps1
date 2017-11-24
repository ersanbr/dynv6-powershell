# Verify number of ipv6 has listed
$current_lines = Get-NetIPAddress -AddressFamily IPv6| where { $_.PrefixOrigin -match 'RouterAdvertisement'}| where { $_.SuffixOrigin -match 'Link'} | where {$_.AddressState -match 'Preferred'} | findstr -I -N IPAddress | %{ $_.Split(' ')[10]; } | Measure-Object | findstr.exe -I -N Count | %{ $_.split(' ')[5];}

# if is different of the 1, restart the adapter
if ($current_lines -ne 1){
	 Get-NetAdapter | ? Name -eq Ethernet | Disable-NetAdapter -Confirm:$false
	 Get-NetAdapter | ? Name -eq Ethernet | Enable-NetAdapter -Confirm:$false
	 Start-Sleep -s 10
}

# Get actual ipv6
$current =  Get-NetIPAddress -AddressFamily IPv6| where { $_.PrefixOrigin -match 'RouterAdvertisement'}| where { $_.SuffixOrigin -match 'Link'} | where {$_.AddressState -match 'Preferred'} | findstr -I -N IPAddress | %{ $_.Split(' ')[10]; }

$file = ($HOME + "\dynv6.addr6")

$log = ($HOME + "\dynv6.log")

$token = "YOUR TOKEN"

$hostname ="YOUR_HOSTNAME.dynv6.net"

# Test exist $file, if not create then
if (Test-Path -Path $file) {
        $old = Get-Content $file
    } else {
		echo "vazio" > $file
		$old = Get-Content $file
	}

# Test old ipv6 with collect, case equals not update dynv6
if ($old -eq $current) {
    ((Get-Date -format dd/MM/yyyy-HH:mm:s) + " - IPv6 address unchanged") >> $log
    } else {
		$url = ("http://dynv6.com/api/update?hostname=" + $hostname + "&ipv6=" + $current + "&token=" + $token)
		Invoke-RestMethod -Uri $url
		$current > $file
		((Get-Date -format dd/MM/yyyy-HH:mm:s) +" - IPv6 address updated") >> $log
    }

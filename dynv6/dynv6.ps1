$current = Get-NetIPAddress -AddressFamily IPv6| where { $_.PrefixOrigin -match 'RouterAdvertisement'}| where { $_.SuffixOrigin -match 'Link'} | findstr -I -N IPAddress | %{ $_.Split(' ')[10]; }

$file = ($HOME + "\dynv6.addr6")

$log = ($HOME + "\dynv6.log")

$token = "YOUR TOKEN"

$hostname ="YOUR_HOSTNAME.dynv6.net"

if (Test-Path -Path $file) {
        $old = Get-Content $file
    } else {
		echo "vazio" > $file
		$old = Get-Content $file
	}

if ($old -eq $current) {
    ((Get-Date -format dd/MM/yyyy-HH:mm:s) + " - IPv6 address unchanged") >> $log
    } else {
		$url = ("http://dynv6.com/api/update?hostname=" + $hostname + "&ipv6=" + $current + "&token=" + $token)
		Invoke-RestMethod -Uri $url
		$current > $file
		((Get-Date -format dd/MM/yyyy-HH:mm:s) +" - IPv6 address updated") >> $log
    }

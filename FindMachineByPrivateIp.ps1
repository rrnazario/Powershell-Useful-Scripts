Install-Module Az -Force
Import-Module Az.Resource

Function FindMachineByPrivateIp($privateIp)
{
    $vms = Get-AzVM
    $networks = Get-AzNetworkInterface

    $infos = @{}

    foreach ( $azVM in  $vms) {

       #$azVm

       $networkProfile = $azVm.NetworkProfile.NetworkInterfaces.id.Split("/")|Select -Last 1

       $IPConfig = ($networks | ? {$_.Name -eq $networkProfile}).IpConfigurations.PrivateIpAddress

       $infos[$azVm.OsProfile.ComputerName] = $IPConfig
    }

     return $infos.GetEnumerator() | ? {$_.Value.Contains($privateIp)}
}

$machine = FindMachineByPrivateIp("127.0.0.1")
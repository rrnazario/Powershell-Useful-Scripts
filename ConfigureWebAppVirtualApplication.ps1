Install-Module Az -Force
Import-Module Az.WebSites

Function ConfigureWebAppVirtualApplication($appName, $rg, $slot, $virtualApp, $physicalPath)
{
    $webApp = Get-AzWebAppSlot -Name $appName -ResourceGroupName $rg -Slot $slot

     $vp = ($webApp.siteconfig.VirtualApplications | % {$_.VirtualPath})

    if (!$vp.Contains("$virtualApp"))
    {
        $virtApp  = New-Object Microsoft.Azure.Management.WebSites.Models.VirtualApplication
        $virtApp.VirtualPath =  $virtualApp
        $virtApp.PhysicalPath =  $physicalPath
        $virtApp.PreloadEnabled  = $false
        
        $webApp.siteconfig.VirtualApplications.Add($virtApp)
        
        Set-AzWebAppSlot  -WebApp $webApp
    }
    else
    {
        Write-Host "Everything is Ok!"
    }
}

ConfigureWebAppVirtualApplication("MyAppName", "eastus2-rg", "production", "virtApp", "/v2/virtApp")
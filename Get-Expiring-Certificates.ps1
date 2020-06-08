Param(
    [Parameter(Mandatory = $true)]
    [string] $sendGridUserName,

    [Parameter(Mandatory = $true)]
    [string] $sendGridToken,

    [Parameter(Mandatory = $true)]
    [string] $mailFrom,

    [Parameter(Mandatory = $true)]
    [string] $mailTo,

    [Parameter(Mandatory = $false)]
    [string] $minimumDaysToAlert = 30
)

#Using Az modules
Import-Module Az.Resources
Import-Module Az.Accounts
Import-Module Az.Automation
Import-Module Az.Websites


$connectionName = 'DEVOPS ACCOUNT SERVICE PRINCIPAL'
$credential = Get-AutomationPSCredential -Name $connectionName
$account = Get-AutomationConnection -Name $connectionName

Connect-AzAccount -Credential $credential -TenantId $account.TenantId -ServicePrincipal -SubscriptionId $account.SubscriptionId

$currentSubs = (Get-AzContext).Subscription

$certsExpirating = @{}

$rgs = Get-AzResourceGroup

foreach($rg in $rgs)
{
    $certs = Get-AzWebAppCertificate -ResourceGroupName $rg.ResourceGroupName
    foreach($cert in $certs)
    {
        Write-Output "Checking $($cert.Name) ..."
        [DateTime]$expiration = $cert.ExpirationDate
        [int]$certExpiresIn = ($expiration - $(get-date)).Days
        
        Write-Output "Expiration in $certExpiresIn days"
        Write-Output "Expiration Date: $expiration"
        
        if ($certExpiresIn -gt $minimumDaysToAlert)
        {
            Write-Output "$($cert.Name) OK"
        }
        else
        {
            if (!$certsExpirating.ContainsKey($cert.Name))
            {
                $certsExpirating[$cert.Name] = $cert.ExpirationDate
            }
        }
    }
}

if ($certsExpirating.Count -gt 0)
{
    $subject =  "[Certificate Warning] $($certsExpirating.Count) certificate(s) almost expiring"
    
    $body    =  "<b>The following certificates are almost getting outdated.</b><br><hr>
                <b>Subscription information:</b><br>
                <li><b>Name:</b> $($currentSubs.Name)<br></li>
                <li><b>Subscription Id:</b> $($currentSubs.Id)<br></li>
                <li><b>Tenant Id:</b> $($currentSubs.TenantId)<br></li><hr>
                <table><tr><th>Certificate Name</th><th>Expiration date</th></tr>"
    
    foreach($cert in $certsExpirating.Keys)
    {
        $body   += "<tr><td>$cert</td><td>$($certsExpirating[$cert])</td></tr>"
    }    
                
    $body   += "</table>"

    $emailMessage = New-Object System.Net.Mail.MailMessage( $mailFrom , $mailTo, $subject, $body )
    $emailMessage.IsBodyHTML=$true
        
    $smtpServer = "smtp.sendgrid.net"
    $smtpPort = "587"

    $SMTPClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpPort )
    $SMTPClient.EnableSsl = $True
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $sendGridUserName, $sendGridToken );
    $SMTPClient.Send( $emailMessage )
}

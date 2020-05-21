Function GetUrlLatestPackerVersion()
{
    $baseUrl = "https://releases.hashicorp.com"
    $wr = Invoke-WebRequest "$baseUrl/packer/"
    $lis = $wr.ParsedHtml.GetElementsByTagName("li")
    $firstLink = $baseUrl + $lis[1].innerHTML.split(">")[0].Split("""")[1]
    $wr = Invoke-WebRequest $firstLink
    
    $extracted = ($wr.ParsedHtml.getElementsByTagName("li") | ? {$_.InnerHTML.Contains("windows_amd64.zip")}).InnerHTML.Split("""")[1]
    
    return "$baseUrl$extracted"
}
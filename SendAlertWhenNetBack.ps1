while (!(Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue))
{
    "Nothing"
    Start-Sleep -s 30
}

#Send Telegram Message
$telegramToken = "TELEGRAM_BOT_TOKEN"
$payload = @{
    "chat_id" = "_YOUR_CHAT_ID";
    "text" = "Internet is back!";
}


while ($true){
    Invoke-WebRequest `
                -Uri("https://api.telegram.org/bot{0}/sendMessage" -f $telegramToken) `
                -Method Post `
                -ContentType "application/json;charset=utf-8" `
                -Body (ConvertTo-Json -Compress -InputObject $payload)

    Start-Sleep -s 10
}
$b64 = "UwB0AGEAcgB0AC0AUAByAG8AYwBlAHMAcwAgAGMAYQBsAGMALgBlAHgAZQA="
$decoded = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($b64))
Invoke-Expression $decoded

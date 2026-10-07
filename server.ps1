$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath($PSScriptRoot)
$port = 8080
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.js'   = 'text/javascript; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.gif'  = 'image/gif'
  '.ico'  = 'image/x-icon'
  '.mp3'  = 'audio/mpeg'
  '.wav'  = 'audio/wav'
}

function Send-Response($client, [int]$status, [string]$statusText, [byte[]]$body, [string]$contentType) {
  $stream = $client.GetStream()
  $headers = "HTTP/1.1 $status $statusText`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nCache-Control: no-cache`r`nX-Content-Type-Options: nosniff`r`nConnection: close`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headers)
  $stream.Write($headerBytes, 0, $headerBytes.Length)
  if ($body.Length) { $stream.Write($body, 0, $body.Length) }
  $stream.Flush()
}

try {
  $listener.Start()
  Write-Host ''
  Write-Host 'Petit Monde is running at http://localhost:8080' -ForegroundColor Green
  Write-Host 'Petit Monde fonctionne sur http://localhost:8080' -ForegroundColor Green
  Write-Host 'Keep this window open. Press Ctrl+C to stop.' -ForegroundColor Yellow
  Start-Process 'http://localhost:8080/#videos'

  while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
      $reader = [System.IO.StreamReader]::new($client.GetStream(), [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()
      while (($line = $reader.ReadLine()) -ne '') { if ($null -eq $line) { break } }
      if ([string]::IsNullOrWhiteSpace($requestLine)) { continue }
      $parts = $requestLine.Split(' ')
      $urlPath = [System.Uri]::UnescapeDataString($parts[1].Split('?')[0])
      if ($urlPath -eq '/') { $urlPath = '/index.html' }
      $relative = $urlPath.TrimStart('/').Replace('/', [System.IO.Path]::DirectorySeparatorChar)
      $path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($root, $relative))
      if (-not $path.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        Send-Response $client 403 'Forbidden' ([System.Text.Encoding]::UTF8.GetBytes('Forbidden')) 'text/plain; charset=utf-8'
      } elseif (Test-Path -LiteralPath $path -PathType Leaf) {
        $body = [System.IO.File]::ReadAllBytes($path)
        $ext = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
        $contentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
        Send-Response $client 200 'OK' $body $contentType
      } else {
        Send-Response $client 404 'Not Found' ([System.Text.Encoding]::UTF8.GetBytes('Not found')) 'text/plain; charset=utf-8'
      }
    } catch {
      try { Send-Response $client 500 'Server Error' ([System.Text.Encoding]::UTF8.GetBytes('Server error')) 'text/plain; charset=utf-8' } catch {}
    } finally {
      $client.Close()
    }
  }
} finally {
  $listener.Stop()
}

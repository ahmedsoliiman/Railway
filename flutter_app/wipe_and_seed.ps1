$headers = @{
    "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Content-Type" = "application/json"
}

$resp = Invoke-RestMethod -Uri "https://xapwfwlkuhlbgvasrocv.supabase.co/rest/v1/station?select=code" -Method Get -Headers $headers
$stations = $resp.code

Write-Host "Wiping old trips..."
Invoke-RestMethod -Uri "https://xapwfwlkuhlbgvasrocv.supabase.co/rest/v1/trip" -Method Delete -Headers $headers

$trips = @()
$dateStart = Get-Date "2026-02-13"
$id = 10000

for ($day = 0; $day -le 7; $day++) {
    $dateStr = $dateStart.AddDays($day).ToString("yyyy-MM-dd")
    for ($i = 0; $i -lt $stations.Count; $i++) {
        $from = $stations[$i]
        # Each station goes to 5 other stations
        for ($j = 1; $j -le 5; $j++) {
            $toIdx = ($i + $j) % $stations.Count
            $to = $stations[$toIdx]
            
            $trips += @{
                Trip_ID = $id++
                Train_ID = 1
                From = $from
                To = $to
                Date = $dateStr
                Time = "10:00:00"
                Base_Price = 120.0
            }
            $trips += @{
                Trip_ID = $id++
                Train_ID = 219
                From = $from
                To = $to
                Date = $dateStr
                Time = "20:00:00"
                Base_Price = 160.0
            }
        }
    }
}

Write-Host "Total trips to upload: $($trips.Count)"
$chunkSize = 50
for ($i = 0; $i -lt $trips.Count; $i += $chunkSize) {
    $chunk = $trips[$i..($i + $chunkSize - 1)] | Where-Object { $_ -ne $null }
    $body = $chunk | ConvertTo-Json
    Invoke-RestMethod -Uri "https://xapwfwlkuhlbgvasrocv.supabase.co/rest/v1/trip" -Method Post -Headers $headers -Body $body
    Write-Host "Chunk $i uploaded"
}
Write-Host "Done!"

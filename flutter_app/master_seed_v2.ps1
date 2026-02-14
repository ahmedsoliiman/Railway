$headers = @{
    "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Content-Type" = "application/json"
}

$stations = @("001", "002", "003", "005", "008", "009", "010") 
$trips = @()
$idCounter = 2000

for ($d = 0; $d -le 6; $d++) {
    $dateStr = (Get-Date "2026-02-13").AddDays($d).ToString("yyyy-MM-dd")
    foreach ($f in $stations) {
        foreach ($t in $stations) {
            if ($f -ne $t) {
                # Morning Trip
                $trips += @{
                    Trip_ID = $idCounter++
                    Train_ID = 219
                    From = $f
                    To = $t
                    Date = $dateStr
                    Time = "08:00:00"
                    Base_Price = 120.0
                }
                # Evening Trip
                $trips += @{
                    Trip_ID = $idCounter++
                    Train_ID = 550
                    From = $f
                    To = $t
                    Date = $dateStr
                    Time = "18:00:00"
                    Base_Price = 150.0
                }
            }
        }
    }
}

$chunkSize = 25
for ($i = 0; $i -lt $trips.Count; $i += $chunkSize) {
    $chunk = $trips[$i..($i + $chunkSize - 1)] | Where-Object { $_ -ne $null }
    $body = $chunk | ConvertTo-Json
    try {
        Invoke-RestMethod -Uri "https://xapwfwlkuhlbgvasrocv.supabase.co/rest/v1/trip" -Method Post -Headers $headers -Body $body
        Write-Host "Uploaded chunk ($i)"
    } catch {
        Write-Host "Error at chunk ($i): $_"
    }
}

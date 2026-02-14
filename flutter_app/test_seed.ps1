$headers = @{
    "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Content-Type" = "application/json"
}
$body = Get-Content test_trip.json -Raw
try {
    Invoke-RestMethod -Uri "https://xapwfwlkuhlbgvasrocv.supabase.co/rest/v1/trip" -Method Post -Headers $headers -Body $body
    Write-Host "Success!"
} catch {
    Write-Host "Error: $_"
    $_.Exception.Response
}

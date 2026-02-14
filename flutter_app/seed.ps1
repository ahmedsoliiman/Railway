$headers = @{
    "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw"
    "Content-Type" = "application/json"
}

$body = @(
    @{
        Train_ID = 1
        From = "RAM"
        To = "SGB"
        Date = "2026-02-13"
        Time = "08:00:00"
        Base_Price = 100
    },
    @{
        Train_ID = 1
        From = "RAM"
        To = "SGB"
        Date = "2026-02-13"
        Time = "12:00:00"
        Base_Price = 120
    },
    @{
        Train_ID = 1
        From = "RAM"
        To = "SGB"
        Date = "2026-02-14"
        Time = "09:00:00"
        Base_Price = 100
    }
) | ConvertTo-Json

Invoke-RestMethod -Uri "https://xapwfwlkuhlbgvasrocv.supabase.co/rest/v1/trip" -Method Post -Headers $headers -Body $body
Write-Host "✅ Seeding complete!"

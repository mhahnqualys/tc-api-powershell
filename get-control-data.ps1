function Write-CsvData {
    param (
        [string]$Subject,
        [array]$CsvData,
        [datetime]$Today
    )

    $formattedDate = $Today.ToString("yyyy-MM-dd")
    $saveFilename = "${Subject}_${formattedDate}.csv"

    $CsvData | Export-Csv -Path $saveFilename -NoTypeInformation

    Write-Host "Data for $Subject saved to csv: $saveFilename"
    return $saveFilename
}

function Main {

    $currDateTime = Get-Date

    Write-Host "call"

    $qUser = $env:Q_USERNAME
    $qPass = $env:Q_PASSWORD
    $qPlat = $env:Q_PLAT

    # Create Basic Authentication header
    $authBytes = [System.Text.Encoding]::UTF8.GetBytes("$qUser`:$qPass")
    $basicAuthToken =[System.Convert]::ToBase64String($authBytes)

    $headers = @{
        "X-Requested-With" = "powershell"
        "Authorization"    = "Basic $basicAuthToken"
    }

    $qReq = "$qPlat/cloudview-api/rest/v1/controls/metadata/list?filter=provider%3AAWS&pageNo=0&pageSize=2"

    Write-Host $qReq

    try {
        $response = Invoke-RestMethod -Uri $qReq -Headers $headers -Method Get
    }
    catch {
        throw "Error in API call URL: $qReq`n$($_.Exception.Message)"
    }

    $controlList = @()

    foreach ($c in $response.control) {
        $c | ConvertTo-Json -Depth 10 | Write-Host

        $controlData = [PSCustomObject]@{
            cid         = $c.cid
            remediation = $c.manualRemediation
        }

        $controlList += $controlData
    }

    Write-CsvData -Subject "controls" -CsvData $controlList -Today $currDateTime | Out-Null
}

Main
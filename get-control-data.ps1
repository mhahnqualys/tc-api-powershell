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

    $qURL = "$qPlat/cloudview-api/rest/v1/controls/metadata/list?filter=provider%3AAWS&pageNo=0&pageSize=2"
    $qURL = "$qPlat/cloudview-api/rest/v1/controls/metadata/list?filter=provider%3AAWS%20and%20service.type:ACM"
    $qURL = "$qPlat/cloudview-api/rest/v1/controls/metadata/list?filter=provider%3AAWS"
	
	$reqPageNum = 0
	$reqPageSize = 200
	$paging = "&pageNo=$reqPageNum&pageSize=$reqPageSize"
	
    $qURLpaged = "$qURL$paging"
	
	$controlList = @()

    $moreData = $true

    while ($moreData) {

        Write-Host $qURLpaged 

        try {
           $response = Invoke-RestMethod -Uri $qURLpaged -Headers $headers -Method Get
        }
        catch {
            throw "Error in API call URL: $qURLpaged`n$($_.Exception.Message)"
        }

        foreach ($c in $response.control) {
            #$c | ConvertTo-Json -Depth 10 | Write-Host

            $controlData = [PSCustomObject]@{
                cid         = $c.cid
				name        = $c.controlName
                remediation = $c.manualRemediation
            }

			Write-Host $c.cid, $c.controlName

            $controlList += $controlData
        }

		$nextURL = $response.warning.url
		
        Write-Host $nextURL
		
		if ([string]::IsNullOrEmpty($nextURL)) {
			Write-Host "The string is null or empty."
			$moreData = $false
		} else {
			$reqPageNum = $reqPageNum + 1
			
			$paging = "&pageNo=$reqPageNum&pageSize=$reqPageSize"
	        $qURLpaged = "$qURL$paging"
	
			$moreData = $true
		}

    }

    Write-CsvData -Subject "controls" -CsvData $controlList -Today $currDateTime | Out-Null
}

Main
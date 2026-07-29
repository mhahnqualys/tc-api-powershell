# Overview 

Example of calling Qualys TotalCloud APIs in Powershell

This software and explanation is provided AS-IS with no warranty.
See the [`LICENSE`](LICENSE) file.

## Explanation

This demonstrations how PowerShell can call the Qualys TotalCloud
API to extract control information, including remediation steps, 
and write this to a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values)
file.

## References:

- https://docs.qualys.com/en/tc/api/get_started/get_started.htm
- https://docs.qualys.com/en/tc/api/control/get_control_metadata.htm
- https://docs.qualys.com/en/tc/api/get_started/get_started.htm
- https://docs.qualys.com

# Usage

## Step 1. Set environment variables for your platform.

```
$env:Q_USERNAME="quays3mh17"
$env:Q_PASSWORD="abc124"
$env:Q_PLAT="https://qualysguard.qg3.apps.qualys.com"
```

Note: the `Q_PLAT` environment variable is found the Platform URL column in the first
table on the Qualys platform identification page: https://www.qualys.com/platform-identification

## Step 2. Run the PowerShell script.

```
.\get-control-data.ps1
```

# Afterwards

This CSV file can be opened in Excel (or other spreadsheet tool). Then a CSV formatted report 
from Qualys TotalCloud can be also opened. Then the manual remediations in the third
column of the controls CSV data can be used in a `vlookup` function to add the manual 
remediation data to individual findings in the TotalCloud report file.


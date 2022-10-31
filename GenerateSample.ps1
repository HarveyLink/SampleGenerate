[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string] $ServiceDirectory
)

function Start-Generate([string]$path) {
    Push-Location $path
    $result = dotnet build /t:GenerateTest
    # Evaluate success/failure
    if($LASTEXITCODE -eq 0)
    {
        $result = dotnet build
        if($LASTEXITCODE -eq 0)
        {
        }
        else
        {
            # Failed, you can reconstruct stderr strings with:
            $ErrorString = $result -join [System.Environment]::NewLine
            $ErrorString >> $logFile        
        }

    }
    else
    {
        # Failed, you can reconstruct stderr strings with:
        $ErrorString = $result -join [System.Environment]::NewLine
        $ErrorString >> $logFile
    }
    Pop-Location
}

$currentDate = Get-Date -Format "yyyyMMdd_hhmmss"
$logFile = "D:\Azure\Script\Errorlog$currentDate.txt"
Write-Output "======== Start Code Validation ========"

Get-ChildItem $ServiceDirectory"\sdk"  | ForEach-Object -Process{
    if ($_.psiscontainer -eq $true) {
        $sdk = Get-ChildItem $_ | Where-Object {$_.Name.Contains("Azure.ResourceManager") }
        if ($null -ne $sdk) {
            Write-Output "Start generate sample for "$sdk
            $sdk
            if (-not(Join-Path $sdk "\tests\autorest.tests.md" | Test-Path)) {
                Copy-Item $ServiceDirectory"\eng\templates\Azure.ResourceManager.Template\tests\autorest.tests.md" -Destination (Join-Path $sdk "\tests")
            }
            Start-Generate (Join-Path $sdk "\tests")
        }
    }
}
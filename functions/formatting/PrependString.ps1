function PrependString
{
    [CmdletBinding()]
    param (
        [System.String]
        $Line,

        [System.String]
        $Flag
    )

    if ($null -eq $Line)
    {
        $Line = [System.String]::Empty
    }

    if ($null -eq $Flag)
    {
        $Flag = [System.String]::Empty
    }

    if ($Line.Trim() -ne '')
    {
        $prependString = "[$(Get-Date -Date ([DateTime]::UTCNow) -uformat "+%Y-%m-%dT%H:%M:%SZ")] - "
        if (-not [System.String]::IsNullOrEmpty($Flag))
        {
            $prependString += "$Flag "
        }

        Write-Output $prependString
    }
}

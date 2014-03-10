function Write-HostLog
{
    <#
    .Synopsis
       Proxy function for Write-Host.  Optionally, also directs the output to a log file.
    .DESCRIPTION
       Has the same definition as Write-Host, with the addition of a -LogFile parameter.  If this
       argument has a value, it is treated as a file path, and the function will attempt to write
       the output to that file as well (including creating the parent directory, if it doesn't
       already exist).  If the path is malformed or the user does not have permission to create or
       write to the file, New-Item and Add-Content will send errors back through the output stream.

       Non-blank lines in the log file are automatically prepended with a culture-invariant date
       and time.
    .PARAMETER LogFile
       Specifies the full path to the log file.  If this value is not specified, it will default to
       the variable $LogFilePreference, which is provided for the user's convenience in redirecting
       output from all of the Write-*Log functions to the same file.
    .NOTES
       unlike Write-Host, this function defaults the value of the -Separator parameter to
       "`r`n".  This is to make the console output consistent with what is sent to the log file,
       where array elements are always written to separate lines (regardless of the value of the
       -Separator parameter;  if that argument is specified, it just gets passed on to Write-Host).
    .LINK
       Write-Host
    #>

    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [System.Object]
        $Object,

        [Switch]
        $NoNewline,
        
        [System.Object]
        $Separator = "`r`n",

        [System.ConsoleColor]
        $ForegroundColor,

        [System.ConsoleColor]
        $BackgroundColor,

        [System.String]
        $LogFile = $null,

        [System.Management.Automation.ScriptBlock]
        $Prepend = { PrependString -Line $args[0] }
    )

	# Call the write-log function with all the parameters that have been passed
	$PSBoundParameters.Add("host", $true)
	Write-Log @PSBoundParameters
}
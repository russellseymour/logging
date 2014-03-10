function Write-VerboseLog {
    <#
    .Synopsis
       Proxy function for Write-Verbose.  Optionally, also directs the verbose output to a log file.
    .DESCRIPTION
       Has the same definition as Write-Verbose, with the addition of a -LogFile parameter.  If this
       argument has a value, it is treated as a file path, and the function will attempt to write
       the debug output to that file as well (including creating the parent directory, if it doesn't
       already exist).  If the path is malformed or the user does not have permission to create or
       write to the file, New-Item and Add-Content will send errors back through the output stream.

       Non-blank lines in the log file are automatically prepended with a culture-invariant date
       and time, and with the text [V] to indicate this output came from the verbose stream.
    .PARAMETER LogFile
       Specifies the full path to the log file.  If this value is not specified, it will default to
       the variable $LogFilePreference, which is provided for the user's convenience in redirecting
       output from all of the Write-*Log functions to the same file.
    .LINK
       Write-Verbose
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position=0, ValueFromPipeline = $true)]
        [Alias('Msg')]
        [AllowEmptyString()]
        [System.Object]
        $Message,

        [System.String]
        $LogFile = $null,

        [System.Management.Automation.ScriptBlock]
        $Prepend = { PrependString -Line $args[0] -Flag '[V]' }
    )

	# Call the write-log function with all the parameters that have been passed
	$PSBoundParameters.Add("verbose", $true)
	Write-Log @PSBoundParameters
}
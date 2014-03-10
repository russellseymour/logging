function Write-Log {


	# Ensure the function picks up all the CommonParameters and set
	# the default parameter set which will be used if none is specified
	[CmdletBinding(DefaultParameterSetName="Host")]
	param (

		# Common Parameters ----------------------------------------

		# The default prepend string to use if not specified
        $Prepend,

        [System.String]
		# Path to logfile
        $LogFile = $null,

		[System.String[]]
		# String array of targets to send the log information to
		# These relate to the providers that can be found
		$Targets,

		[System.String]
		# Event ID to extract from the resources file, if one has been specified
		$EventId = [String]::Empty,

		[int]
		# Sevrity of the message
		$severity = 0,

		[System.String]
		# Path to the resources file from which to load the messages
		# Anything specified here will overwrite what has been spcified in Set-LogParameters
		$resource = [String]::Empty,

		# variable to hold extra information to be added to the message
		# this is how default messages can be enchances
		$extra = $false,
		
#region Write-Host Parameters

		[Parameter(ParameterSetName="Host")]
		[switch]
		# State if using Host output
		$Host = [switch]::present,

        [Parameter(Position = 0, ValueFromPipeline = $true, ParameterSetName = "Host")]
        [System.Object]
        $Object,

		[Parameter(ParameterSetName="Host")]
        [Switch]
        $NoNewline,
        
		[Parameter(ParameterSetName="Host")]
        [System.Object]
        $Separator = "`r`n",

		[Parameter(ParameterSetName="Host")]
        [System.ConsoleColor]
        $ForegroundColor,

		[Parameter(ParameterSetName="Host")]
        [System.ConsoleColor]
        $BackgroundColor,

#endregion

#region Write-Verbose parameters
		[Parameter(Mandatory = $true, Position=0, ValueFromPipeline = $true, ParameterSetName="Verbose")]
        [Alias('Msg')]
        [AllowEmptyString()]
        [System.String]
        $Message
#endregion

	)

	# Configure the function
    begin
    {

		if (!($PSBoundParameters.ContainsKey("Host"))) {
			$PSBoundParameters.Add("Host", $Host)
		}

		# determine the cmdlet being used and the PS command equivalent
		# this is hierarchal so the order is Error, Warn, Info, Debug, Host
		if ($PSCmdlet.MyInvocation.BoundParameters.Verbose.IsPresent) {
			$powershellCommand = "Write-Verbose"

			# it is possible that will be in the wrong parameterset if Write-Log command has been called
			# directly without specifyin the switch for Message
			# sort out the parameters
			if ($PSCmdlet.ParameterSetName -ieq "host") {
				$PSBoundParameters.Remove("Object") | out-Null
				$PSBoundParameters.Add("Message", $object) 
			} else {
				# set the object to be the message so that it can be processed
				$Object = $Message
			}

			# if the prepend has not been set, set it here
			if ([String]::IsNullOrEmpty($Prepend)) {
				$Prepend = { PrependString -Line $args[0] -Flag '[V]' }
			}

			# set the log level
			$level = "VERBOSE"
		} elseif ($Host) {
			$powershellCommand = "Write-Host"

			# if the prepend has not been set, set it here
			if ([String]::IsNullOrEmpty($Prepend)) {
				$Prepend = { PrependString -Line $args[0] -Flag '[H]' }
			}
			$level = "INFO"
		}


		# Remove the host from the boundparameters
		$PSBoundParameters.Remove("Host") | Out-Null

        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

		# Determine the location of the log file
        if ($PSBoundParameters.ContainsKey('LogFile'))
        {
			# Log file location has come from the parameters
            $_logFile = $LogFile
            $null = $PSBoundParameters.Remove('LogFile')
        }
        elseif (![String]::IsNullOrEmpty($script:logging.directory) -and ![String]::IsNullOrEmpty($script:logging.filename))
		{
			$_logFile = "{0}\{1}" -f $script:logging.directory, $script:logging.filename
		}
		else
        {
			# has been set in the variables
            $_logFile = $PSCmdlet.GetVariableValue("LogFilePreference")
        } 
		
		# set the targets to use if it has not been spcified on the command line
		if (!($PSBoundParameters.ContainsKey("Targets"))) {
			if ([String]::IsNullOrEmpty($script:Logging.targets)) {
				$Targets = @("screen")
			} else {
				$Targets = $script:Logging.targets
			}
		}

		# if a log file has been set and not in the targets then append to the targets
		if (![String]::IsNullOrEmpty($_logFile) -and $Targets -notcontains "logfile") {
			$Targets += "logfile"
		}

		# Remove any parameters that would cause the default PowerShell functions to fail
        $null = $PSBoundParameters.Remove('Prepend')
		$null = $PSBoundParameters.Remove('Targets')
		$null = $PSBoundParameters.Remove('EventId')
		$null = $PSBoundParameters.Remove('Severity')
		$null = $PSBoundParameters.Remove('Resource')
		$null = $PSBoundParameters.Remove('Extra')

        $outBuffer = $null

        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }

		# if the Logging object does not have a messages array add it now
		if (!$script:Logging.ContainsKey("messages")) {
			$script:Logging.messages = @()
		}

		# Build up array of paths to look for providers in
		# Work out the path to the built in providers
		$module_path = Split-Path -Parent -Path (Get-Module -Name Logging).Path
		
		# if the script logging providers does not exist then build the array
		$provider_paths = @()
		if ([String]::IsNullOrEmpty($script:Logging.providers) -and $script:Logging.providers.count -gt 0) {
			$provider_paths = $provider_paths + $script:Logging.providers			
		}
		$provider_paths += "{0}\providers" -f $module_path

		# determine if a tag has been specified in the session
		if (![String]::IsNullOrEmpty($script:Logging.tag)) {
			$logtag = $script:Logging.tag
		} elseif (![String]::IsNullOrEmpty($LogTagPreference)) {
			$logtag = $LogTagPreference
		}

    }

    process
    {
		# Attempt to load the resources file
		$resource = Load-Help -Path $resource

		# Find the message from the eventid and return as a message object
		$msg, $formatting = Get-HelpMessage -EventId $EventId -Resource $resource -Message $Object -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -Prepend $Prepend -Tag $logtag

		# Get the message structure to work with
		$structure = Format-Message -Level $level -EventId $EventId -Message $msg -Severity $severity

		# add the message to the logging.messages
		$script:logging.messages += $structure

		# if in Host parameter set then format the object regarding indents
		if ($PSCmdlet.ParameterSetname -ieq "host") {
			# determine the indent
			$prefix = ""
			for ($i = 0; $i -lt $formatting.indent; $i ++) {
				$prefix += $formatting.indent_string
			}

			# now set the object to include the prefix
			$PSBoundParameters.Object = "{0}{1}" -f $prefix, $PSBoundParameters.Object
		}

		# Get the powershell built in command
        try 
        {
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($powershellCommand, [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }

		# build up parameters that are to be passed to each of the providers
		$parameters = @{
							
							# the actual message
							structure = $structure

							# set the formatting to be applied
							formatting = $formatting

							# if the message should be output without a newline
							nonewline = $nonewline
						
							# the path to the logfile
							logfile = $_logFile
						}

		# iterate around the priovider paths and find each of the providers
		$providers = @()
		foreach ($provider_path in $provider_paths) {

			# continue onto the next iteration if the path does not exist
			if (!(Test-Path -Path $provider_path)) {
				Write-Warning -Message ("Provider path does not exist: {0}" -f $provider_path)
				continue
			}

			# get items from each path
			$items = Get-ChildItem -Path $provider_paths -Include *.ps1 -Recurse

			# add to the providers
			$providers = $providers + $items
		}

		# ensue that there are only a list of unique items in the array
		$providers = $providers | Select -Unique

		# iterate around the targets that have been specified
		foreach ($Target in $Targets) {

			# if target is screen then continue to next iteration, this is because
			# this function will handle screen
			if ($Target -ieq "screen") {
				continue
			}

			# check that the provider exists
			$provider_file = $providers | Where-Object { $_.name -match ("^{0}" -f $Target) }

			# source the file if it has been found
			if (![String]::IsNullOrEmpty($provider_file)) {
				
				# source the file
				. ($provider_file.Fullname)

				# determine the parameters that the provider expects
				$splat = @{}
				foreach ($param in (Get-Command Set-Message).Parameters.Keys) {
					
					# only add parameters to the splat that are expected by the function
					if (![String]::IsNullOrEmpty($parameters.$param)) {
						$splat.$param = $parameters.$param
					}
				}
				
				# Invoke the provider by splatting the function
				"Set-Message @splat" | Invoke-Expression
			}
		}


 
		if ($Targets -contains "screen") {   
			try
			{
				$steppablePipeline.Process($_)
			}
			catch
			{
				throw
			}
		}
    }

    end
    {
		if ($Targets -contains "screen") {   
			try
			{
				$steppablePipeline.End()
			}
			catch
			{
				throw
			}
		}
    }
}
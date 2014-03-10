
function Set-LogParameters {

	<#

	.SYNOPSIS
	Sets various settings for the Write-Log function

	.DESCRIPTION
	Write-Log needs to know what resources file to use, the location of the additional providers directory,
	and the options that need to passed.  This function sets the module variable that can be read by the
	Write-Log function.  This avoids the need for global variables

	The function adds a custom hash within the logging object.  This is so that configuration data can be set
	for additional providers that Write-Log might consume

	#>

	[CmdletBinding()]
	param (

		[string[]]
		[Parameter(ParameterSetName="switches")]
		# Output targets
		# This list denotes the targets that the message for write-log should be sent to
		$targets = @("screen"),

		[string]
		[Parameter(ParameterSetName="switches")]
		# Log directory
		# The path to the directory that LogFiles should be save in
		$directory = [String]::Empty,

		[string]
		[Parameter(ParameterSetName="switches")]
		# Filename
		# The filename of the log file
		$filename = [String]::Empty,

		[string]
		[Parameter(ParameterSetName="switches")]
		[alias("helpfile")]
		# Help Resources
		# Path to the resources file that contains the messages to be used when invoking write-log
		$resource_path = [String]::Empty,

		[string[]]
		[Parameter(ParameterSetName="switches")]
		# Providers
		# Path to another directory that contains providers that Write-Log can use
		$providers = @(),

		[Parameter(ParameterSetName="switches")]
		# Custom
		# This allows extra configuration to be passed to the Write-Log function
		# Such use cases will be for custom providers that have been written
		# If not set this item will not appear in the logging object
		$custom = $false,

		[Parameter(ParameterSetName="object")]
		# Parameters
		# This is an object that contains all of the settings that need to be defined in the module
		$parameters
	)

	# Create the logging object
	$Logging = $script:Logging

	# set the logging hashtable up based on the paramater set
	switch ($PsCmdlet.ParameterSetName) {

		"switches" {

			# Set the logging variable accordingly

			# Log Targets
			if (!($Logging.ContainsKey("targets")) -and ![String]::IsNullOrEmpty($targets)) {
				$Logging.targets = $targets
			}

			# Options
			if (!($Logging.ContainsKey("options")) -and ![String]::IsNullOrEmpty($options)) {
				$Logging.options = $options
			}

			# Log directory and filename
			if (!($Logging.ContainsKey("directory")) -and ![String]::IsNullOrEmpty($directory)) {
				$Logging.directory = $directory
			}
			if (!($Logging.ContainsKey("filename")) -and ![String]::IsNullOrEmpty($filename)) {
				$Logging.filename = $filename
			}

			# Set additional providers
			if (!($Logging.ContainsKey("providers")) -and ![String]::IsNullOrEmpty($providers)) {
				$Logging.providers_path = $providers
			}

			# Attempt to load the specified resources file
			if (![String]::IsNullOrEmpty($resource_path) -and ($Logging.ContainsKey("resource")) -eq $false) {

				# If the file exists then read it in as a XML object
				if (Test-Path -Path $resource_path) {

					[xml] $Logging.resource = Get-Content -Path $resource_path -Raw

				} else {

					Write-Warning -Message ("Unable to load helpfile as it cannot be located.`n`t{0}" -f $resource_path)
				}

			}

			# Set a user attribute that can be set by parameters
			if (!($Logging.ContainsKey("custom")) -and $custom -ne $false) {
				$Logging.custom = $custom
			}

		}

		"object" {

			$Logging = $parameters

		}

	}

	# Add an array that will hold any messages that are passed to the module
	# so that they can be output as part of a pipeline at the end
	$Logging.messages = @()

	# The module variable is accessible at the script scope level
	$script:Logging = $Logging

}
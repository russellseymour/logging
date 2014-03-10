
function Get-Logs {

	<#

	.SYNOPSIS
		Returns the messages that have been stored in the logging object

	#>

	# Get the messages from the script:logging
	$messages = $script:logging.messages

	# ensure the logging messages are cleared out
	$script:logging.messages = @()

	$messages
}
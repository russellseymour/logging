
function Get-HelpMessage {

	<#

	.SYNOPSIS
		Return the help message from the help resource

	.DESCRIPTION
		Attempt to get a message from the resource and return a message object
		This will contain any formatting information and colours that need to be applied
		These extra details are for the providers and not the message itself
	#>

	[CmdletBinding()]
	param (

		[System.String]
		# EventId to look for
		$EventId,

		# Resource containing the help message
		$resource,

		[System.String]
		# Message to be put into the object if an eventid has not been set
		$message,

		[int]
		# Any indent that should be applied to the message
		$indent = 0,

		[string]
		# the string to use for the indent
		$indent_string = "    ",

		# any string that needs to be prenpdened to the output
		$prepend,

		# An extra infromation that needs to be taken into account
		$extra,

		# Ensure that the colours from the calling function are pulled in
		$ForegroundColor,
		$BackgroundColor

	)

	# build up the message object to return
	$object = @{
					text = $message
				}

	$formatting = @{
		indent = $indent
		indent_string = $indent_string
		foregroundcolor = $ForegroundColor
		backgroundcolor = $BackgroundColor
		prepend = $prepend
	}

    if ($resource -ne $false) {

		# Build up the xpath to find the message
		$xpath = "//resource[@code='{0}']" -f $eventid
		Write-Debug -Message ("Message Xpath: '{0}'" -f $xpath)

		# Get the  item from the resources file
		$item = $resource.SelectSingleNode($xpath)

		# now if item is not null then set properties of the object
		if (![String]::IsNullOrEmpty($resource)) {

			# set the various parts of the object
			if (![String]::IsNullOrEmpty($item.message)) {
				$object.text = $ExecutionContext.InvokeCommand.ExpandString($item.message)
			}

			# check for indent
			if (![String]::IsNullOrEmpty($item.indent)) {
				$formatting.indent = $item.indent
			}

			# Set the foreground and background colours
			if (![String]::IsNullOrEmpty($item.colours.foreground)) {
				$formatting.foregroundcolor = $item.colours.foreground
			}
		
			if (![String]::IsNullOrEmpty($item.colours.foreground)) {
				$formatting.foregroundcolor = $item.colours.foreground
			}

		} elseif ([String]::IsNullOrEmpty($message)) {

			# if no message has been passed then set a default one
			$object.text = "No message can be found for EventId '{0}'" -f $eventid
		}
	}

	# Now that the object has been configured, check the message to see if any placeholders are to be replaced
	if ($extra -ne $false) {

		# turn the extra information into an array, if not already one
		# this is so that is can be easily substituted inline or all the elements output on new lines beneath the main message
		if ($extra -is [String]) {
			$extra = @($extra)
		} elseif ($extra -is [Hashtable]) {
			$extra = $extra.Keys | Sort-Object $_ | ForEach-Object {"{0}:  {1}" -f $_, ($extra.$_)}
		}

		# determine if the message text has any placeholders
		$groups = [Regex]::Matches($object.text, "({[0-9]+})")
		if ($groups.count -gt 0) {

			# placeholders have been found so replace them with the extra array
			$object.text = $object.text -f $extra
		} else {

			# there are no placeholders so add the extra to the object
			$object.extra = $extra
		}
	}

	# pass the message object and the formatting that needs to be applied
	$object, $formatting
}
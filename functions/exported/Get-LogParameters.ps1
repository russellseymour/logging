function Get-LogParameters {

	<#

	.SYNOPSIS
	Returns the current logging parameters

	.DESCRIPTION
	When a module is unloaded that has links to another module, functions within that module
	can cease to be accessible.  In this case the only way to get them back is to reimport the module.
	This function will return the current logging parameters so that when a module is unlaoded, and it
	takes out Logging then the parameters can be sent back in

	#>

	$Logging
}
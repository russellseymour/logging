# Get a list of the functions that need to be sourced
$Functions = Get-ChildItem -Recurse "$PSScriptRoot\functions" -Include *.ps1

# source each of the individual scripts
foreach ($function in $functions) {
	. $function.FullName
}

# get a list of the functions that need to be expotred
$functions_to_export = $Functions | Where-Object { $_.FullName -match "Exported"} | ForEach-Object { $_.BaseName }

$functions_to_export

# Export the accessible functions
Export-ModuleMember -function ( $functions_to_export )

# Declare variable that will hold the log targets etc when other functions need
# to use Write-Log
$Logging = @{}

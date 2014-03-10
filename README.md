<<<<<<< HEAD
# Logging

One of the issues with PowerShell's built in 'Write-' commands is that it is not easy to capture the output from them and then parse that log.  So if, for example, there was the following code in a script:

    Write-Verbose "Creating new directory"

This would be seen on the screen, but it is not available to put into a log file, or sent to the Event Log or even sent to Elastic Search.

This module aims to fix that but creating a set of functions that add to the existing functionality of the standard 'Write-' commands.  The commands from the module are 'Write-VerboseLog' which mimics 'Write-Verbose' and so on.

## Credits

My thanks to David Wyatt, whose own Logging module showed me how to extend the built in functions. (http://gallery.technet.microsoft.com/scriptcenter/Write-timestamped-output-4ff1565f).  This provided me with the basis to capture the logs and then add the extra capabilities I wanted.

## Features

This is still being developed, but the main features are:

    - Capture the message from any 'Write-*Log' function and process it as required
    - Set an XML file as the resource to extract messages from using an EventId
    - Process all messages as an object by calling 'Get-Messages' - useful to send to a different location such as Elastic Search.

## To Do

The following is a list of the things that are left to do, but it is probably not exhaustive:

    - Not all the 'Write-' commands are supported yet.  Only Write-Host and Write-Verbose are
    - Add ability to add a global parameter for a log tag or prefix
    - Log levels are currently linked to the appropriate 'Write-' command, however there maybe times when the 'Write-Host' function is required but with a different level and therefore differnt colour coding.
    - Add comment based help to all the exported functions




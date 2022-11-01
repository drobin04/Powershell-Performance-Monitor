# Powershell Performance Monitor
 Powershell script that collects performance stats and saves into a sqlite database.

Useful for quickly tracking CPU, memory usage / free, GPU usage, GPU memory usage, network quality while running a video game or other app.

# Setup

Extract the contents of this repository, right click CollectPerformanceStats.ps1, and select 'Run with Powershell'. You can then watch the output there, or check the files output in the \results folder.

# Requirements

If the script fails to run, you may need to update or download the appropriate System.Data.SQLite.dll file in this directory for this script to work. One should be included, but if it doesn't work on your system, you can download them from this URL: https://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki

If script fails to run because 'running scripts is disabled on this system', right click your start menu button and launch powershell as an admin. Then run ' Set-ExecutionPolicy Unrestricted ' and try again.

# Screenshots

https://i.imgur.com/hxnQ3ql.png

https://i.imgur.com/aAXTxJM.png

https://i.imgur.com/0CQdbcR.png
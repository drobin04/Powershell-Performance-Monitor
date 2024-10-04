# Powershell Performance Monitor
Powershell script that collects performance stats, outputs them to a console and also saves into a sqlite database.

Useful for quickly troubleshooting CPU, memory usage / free, GPU usage, GPU memory usage, network quality while running another application.

# Setup

Extract the contents of this repository, right click CollectPerformanceStats.ps1, and select 'Run with Powershell'. You can then watch the output there, or check the files output in the \results folder.

Edit the script to configure it for whether it should re-use the same Results.s3db file, or whether it should always generate a new results file under a 'results' folder.

In order to display the results in a webpage, if interested, you'll need to install a webserver, including PHP. 
You can do this with Xampp - https://www.apachefriends.org/download.html

Install the app, and then place this set of files in the main directory, c:\xampp\

You can then view the monitor in a web browser by opening localhost/ or by navigating to your machine's IP address in a web browser. 

# Requirements

If the script fails to run, you may need to update or download the appropriate System.Data.SQLite.dll file in this directory for this script to work. One should be included, but if it doesn't work on your system, you can download them from this URL: https://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki

If script fails to run because 'running scripts is disabled on this system', right click your start menu button and launch powershell as an admin. Then run ' Set-ExecutionPolicy Unrestricted ' and try again.

# Screenshots

https://i.imgur.com/hxnQ3ql.png

https://i.imgur.com/aAXTxJM.png

https://i.imgur.com/0CQdbcR.png

# Useful tools

To view the results in a database format that can be queried, you will need to use an application that can view SQLite database files (s3db files). 
You can use SQLite Administrator console for this, available from this URL: http://sqliteadmin.orbmu2k.de/

Using this, you can open the results .s3db file, and run SQL queries, such as ' Select * From PerformanceStats Order By cpu desc ' to produce the following results - https://i.imgur.com/K96DXQI.png

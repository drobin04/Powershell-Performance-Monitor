# Powershell Performance Monitor
 Powershell script that collects performance stats and saves into a sqlite database.

Useful for quickly tracking CPU, memory usage / free, GPU usage, GPU memory usage while running a video game or other app.

# Requirements

You will need to edit the CollectPerformanceStats.ps1 file in a text editor and enter in your router's IP address, in order for it to properly ping your router.

If unsure of your router's IP address, you can find it by running IPConfig in command prompt or powershell and looking at the Default Gateway value. 

You may need to update or download the appropriate System.Data.SQLite.dll file in this directory for this script to work. One should be included, but if it doesn't work on your system, you can download them from this URL: https://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki

NOTE - If script fails to run because 'running scripts is disabled on this system', right click your start menu button and launch powershell as an admin. Then run ' Set-ExecutionPolicy Unrestricted ' and try again.

# Screenshots

https://i.imgur.com/hxnQ3ql.png

https://i.imgur.com/aAXTxJM.png

https://i.imgur.com/goCufiP.png
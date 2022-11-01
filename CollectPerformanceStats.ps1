cls #Clear any previous messages or script echo in powershell window....
#IMPORTANT - Configure refresh interval / frequency to record values below, in number of seconds. 
$refreshinterval = 3

# This is important to import System.Data.SQLite DLL file properly, don't remove this line - 
$pathfordll = $PSScriptRoot

# NOTE: May need to download SQLite library and install it in order for this script to work. Have included the .NET 4.0 x64 DLL with this script,if doesn't work, go download the appropriate one.
# Access from: https://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki
# You probably are looking for the section labelled 'Precompiled Binaries for 64-Bit Windows (.NET Framework 4.0)
# If unsure, run $PSVersionTable command and check what is shown on the CLR version as the .NET framework version you need.
# You can also run [IntPtr]::Size and see if the result is that you are on 32 bit (4) or 64 bit (8).

# NOTE - If script fails to run because 'running scripts is disabled on this system', right click your start menu 
# button and launch powershell as an admin. Then run ' Set-ExecutionPolicy Unrestricted ' and try again.

#Import Sqlite DLL file / assembly
Add-Type -Path "$($pathfordll)\System.Data.SQLite.dll"
$dbname = [GUID]::NewGuid().ToString()

#Create database
$dbpath = "$($pathfordll)\results\$($dbname).s3db"
[System.Data.SQLite.SQLiteConnection]::CreateFile($dbpath)
$sDatabaseConnectionString=[string]::Format("data source={0}",$dbpath)
$oSQLiteDBConnection = New-Object System.Data.SQLite.SQLiteConnection
$oSQLiteDBConnection.ConnectionString = $sDatabaseConnectionString
$oSQLiteDBConnection.open()
#Create table(s)
$oSQLiteDBCommand=$oSQLiteDBConnection.CreateCommand()
$oSQLiteDBCommand.Commandtext="create table PerformanceStats (cpu int, gpu int, memoryfree int, GPUMemoryUsed int, timestamp datetime)"
#$oSQLiteDBCommand.Commandtext
$oSQLiteDBCommand.CommandType = [System.Data.CommandType]::Text
$oSQLiteDBCommand.ExecuteNonQuery()
$oSQLiteDBConnection.Close() #Close db for now to write file to disk; unsure when script will be stopped so will repeatedly open/close file.

"Monitoring started; Control+C at any time to stop..."

while (1 -eq 1){
#Initialize db variable
$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$con.ConnectionString = "Data Source=$dbpath"
$con.Open() #DB file is open, will collect data, then write to it.

#Collect Performance stats 
$d1 = Get-Counter '\Memory\Available MBytes' #Free RAM
$d2 = Get-Counter '\Processor(_Total)\% Processor Time' #CPU Usage
$ram = $d1.CounterSamples.CookedValue #Filter ram value from larger property set
$cpu = [math]::Round($d2.CounterSamples.CookedValue) # see previous comment
$GpuMemTotal = (((Get-Counter "\GPU Process Memory(*)\Local Usage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$GpuUseTotal = (((Get-Counter "\GPU Engine(*engtype_3D)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$GpuMemTotal = $GpuMemTotal / 1024
$GpuMemTotal = [math]::Round($GpuMemTotal / 1024) #divide GPU mem value down to MB
$GpuUseTotal = [math]::Round($GpuUseTotal)
$results = "CPU: $cpu %, RAM: $ram MB Free, GPU Usage: $GpuUseTotal % , GPU Mem Usage: $GpuMemTotal MB"
$results

#Time to insert into DB. 
$sqlinsert = "INSERT INTO PerformanceStats (cpu, gpu, memoryfree, GPUMemoryUsed, timestamp) VALUES ($cpu , $GpuUseTotal , $ram , $GpuMemTotal ,CURRENT_TIMESTAMP)"
$oSQLiteDBCommand=$con.CreateCommand()
$oSQLiteDBCommand.Commandtext=$sqlinsert
#$oSQLiteDBCommand.Commandtext
$oSQLiteDBCommand.CommandType = [System.Data.CommandType]::Text
$oSQLiteDBCommand.ExecuteNonQuery()
$con.Close()

start-sleep -seconds $refreshinterval
}
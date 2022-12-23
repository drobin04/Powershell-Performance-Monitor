cls #Clear any previous messages or script echo in powershell window....
#CONFIGURE - Configure refresh interval / frequency to record values below, in number of seconds. 
$refreshinterval = 1
$UseNewDatabaseFiles = 0 # SET THIS TO 1 IF YOU WANT EACH RUN TO SET UP NEW RESULTS FILES. LEAVE AS IS IF YOU WANT THEM ALL SAVED TO THE SAME FILE.


# Automatically determine Router's IP Address by checking next 'hop' from PC to WAN / internet.
$routerIP = (Get-NetRoute "0.0.0.0/0").NextHop[0]

# This is important to import System.Data.SQLite DLL file properly, don't remove this line - 
$pathfordll = $PSScriptRoot

# NOTE: May need to download SQLite library and install it in order for this script to work. Have included the .NET 4.0 x64 DLL with this script,if doesn't work, go download the appropriate one.
# Access from: https://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki
# You probably are looking for the section labelled 'Precompiled Binaries for 64-Bit Windows (.NET Framework 4.0)
# If unsure, run $PSVersionTable command and check what is shown on the CLR version as the .NET framework version you need.
# You can also run [IntPtr]::Size and see if the result is that you are on 32 bit (4) or 64 bit (8).

# NOTE - If script fails to run because 'running scripts is disabled on this system', right click your start menu 
# button and launch powershell as an admin. Then run ' Set-ExecutionPolicy Unrestricted ' and try again.

#Get unique filename for files to be saved as
$dbname = [GUID]::NewGuid().ToString()

If ($UseNewDatabaseFiles -eq 1) {
      
      $dbpath = "$($pathfordll)\results\$($dbname).s3db"
      } else {$dbpath = "$($pathfordll)\results.s3db"}
$dbname
$dbpath


$csvpath = "$($pathfordll)\results\$($dbname).csv"

#Check if results folder exists, if not, create
If(!(test-path -PathType container "$pathfordll\results"))
{
      $suppressvariable = New-Item -ItemType Directory -Path "$pathfordll\results"
}

#Start CSV File
$csv = "date/time,CPUusage,RemainingFreeRAM,GPUusage,GPUMemoryUsed,routerping,googleping" | Out-File $csvpath

#Import Sqlite DLL file / assembly
Add-Type -Path "$($pathfordll)\System.Data.SQLite.dll"

#Create database
Try{
[System.Data.SQLite.SQLiteConnection]::CreateFile($dbpath)
$sDatabaseConnectionString=[string]::Format("data source={0}",$dbpath)
$oSQLiteDBConnection = New-Object System.Data.SQLite.SQLiteConnection
$oSQLiteDBConnection.ConnectionString = $sDatabaseConnectionString
$oSQLiteDBConnection.open()
#Create table(s)
$oSQLiteDBCommand=$oSQLiteDBConnection.CreateCommand()
$oSQLiteDBCommand.Commandtext="create table PerformanceStats (cpu int, gpu int, memoryfree int, GPUMemoryUsed int, timestamp datetime,routerping int,googleping int)"
#$oSQLiteDBCommand.Commandtext
$oSQLiteDBCommand.CommandType = [System.Data.CommandType]::Text
$suppressvariable = $oSQLiteDBCommand.ExecuteNonQuery()
$oSQLiteDBConnection.Close() #Close db for now to write file to disk; unsure when script will be stopped so will repeatedly open/close file.
}catch{}

"Monitoring started; Control+C at any time to stop..."
#Initialize db variable
$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$con.ConnectionString = "Data Source=$dbpath"
$con.Open() #DB file is open, will collect data, then write to it.
while ($true){


#Collect Performance stats 
$PerfStatTime = Measure-Command {
$d1 = Get-Counter '\Memory\Available MBytes' #Free RAM
$d2 = Get-Counter '\Processor(_Total)\% Processor Time' #CPU Usage
$ram = $d1.CounterSamples.CookedValue #Filter ram value from larger property set
$cpu = [math]::Round($d2.CounterSamples.CookedValue) # see previous comment
$GpuMemTotal = (((Get-Counter "\GPU Process Memory(*)\Local Usage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$GpuUseTotal = (((Get-Counter "\GPU Engine(*engtype_3D)\Utilization Percentage").CounterSamples | where CookedValue).CookedValue | measure -sum).sum
$GpuMemTotal = $GpuMemTotal / 1024
$GpuMemTotal = [math]::Round($GpuMemTotal / 1024) #divide GPU mem value down to MB
$GpuUseTotal = [math]::Round($GpuUseTotal)
}

$googleping = (Test-Connection -ComputerName 8.8.8.8 -Count 1).ResponseTime
$routerping = (Test-Connection -ComputerName $routerIP -Count 1).ResponseTime
If($routerping -eq $null){
    [console]::beep(500,500)
    $routerping = 999
}
If($googleping -eq $null){
    [console]::beep(500,500)
    $googleping = 999
}
$results = "CPU: $cpu %, RAM: $ram MB Free, GPU Usage: $GpuUseTotal % , GPU Mem Usage: $GpuMemTotal MB, Router Ping: $routerping ms, Google Ping: $googleping ms, PerfStatTime - " + $PerfStatTime.Milliseconds
$results


#Time to insert into DB. 
$sqlinsert = "INSERT INTO PerformanceStats (cpu, gpu, memoryfree, GPUMemoryUsed, timestamp,routerping,googleping) VALUES ($cpu , $GpuUseTotal , $ram , $GpuMemTotal ,CURRENT_TIMESTAMP,$routerping,$googleping)"
$oSQLiteDBCommand=$con.CreateCommand()
$oSQLiteDBCommand.Commandtext=$sqlinsert
#$oSQLiteDBCommand.Commandtext
$oSQLiteDBCommand.CommandType = [System.Data.CommandType]::Text
$suppressvariable = $oSQLiteDBCommand.ExecuteNonQuery()


#Time to insert new line to CSV file as well

$csv = "$(Get-Date),$cpu , $ram , $GpuUseTotal , $GpuMemTotal,$routerping,$googleping"
Add-Content $csvpath $csv
#start-sleep -Seconds $refreshinterval
}
$con.Close()
# Reference
# ' $suppressvariable = ' is placed before the SQLite ExecuteNonQuery statements, to stop it from entering lines of extra text into the powershell output.
# This was done to stop stray 0 and 1 values showing up in the result lines. For example https://imgur.com/goCufiP

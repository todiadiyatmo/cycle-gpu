$internalDisplayName = "DISPLAY\LEN4*"
$sleepTime  = 1
$waitReset = 10
$allowResetGPU = $true
$firstRun = $true
$lastReset = ""

function getExternalDisplay {
    param(
        $internalDisplayName
    )
    $status = Get-PnpDevice -Status OK | Where-Object  {$_.class -like "Monitor" -and $_.instanceid -notlike $internalDisplayName}

    return [bool]$status;
}

function getPowerStatus {
    $runtime = Get-CimInstance -ClassName Win32_Battery | Measure-Object -Property EstimatedRunTime -Average | Select-Object -ExpandProperty Average
    return $runtime -eq 71582788
}

function getPowerOrExternalDisplay {
    return (getExternalDisplay $internalDisplayName) -or (getPowerStatus)
}

function loop {
    param([scriptblock]$function,
        [string]$label)
    
    $job = Start-Job  -ScriptBlock $function -ArgumentList $internalDisplayName, $sleepTime

    $symbols = @("⣾⣿", "⣽⣿", "⣻⣿", "⢿⣿", "⡿⣿", "⣟⣿", "⣯⣿", "⣷⣿",
                 "⣿⣾", "⣿⣽", "⣿⣻", "⣿⢿", "⣿⡿", "⣿⣟", "⣿⣯", "⣿⣷")
    $i = 0;
    Write-Host $label
    while ($job.State -eq "Running") {
        $symbol =  $symbols[$i]
        Write-Host -NoNewLine "`rMonitoring $symbol " -ForegroundColor Green
        Start-Sleep -Milliseconds 100
        $i++
        if ($i -eq $symbols.Count){
            $i = 0;
        }   
    }
    Receive-Job -Job $job -Wait -AutoRemoveJob > null
    return $true 
}

$externalDisplayConnected = {
    param($internalDisplayName,$sleepTime)

    while($true) {
        $externalDisplay = Get-PnpDevice -Status OK | Where-Object  {$_.class -like "Monitor" -and $_.instanceid -notlike $internalDisplayName}
        $runtime = Get-CimInstance -ClassName Win32_Battery | Measure-Object -Property EstimatedRunTime -Average | Select-Object -ExpandProperty Average
     
        # Write-Host $internalDisplayName
        # Write-Host $runtime

        # External display not detected and not running on power, break loop     
        if(!$externalDisplay -and $runtime -ne 71582788) {
            # allow reset GPU
            return $true
        }  
        Start-Sleep -Seconds $sleepTime
    }
}

$externalDisplayDisconnected = {
    param($internalDisplayName,$sleepTime)
    
    while($true) {
        $externalDisplay = Get-PnpDevice -Status OK | Where-Object  {$_.class -like "Monitor" -and $_.instanceid -notlike $internalDisplayName}
        $runtime = Get-CimInstance -ClassName Win32_Battery | Measure-Object -Property EstimatedRunTime -Average | Select-Object -ExpandProperty Average
        
        # Write-Host $internalDisplayName
        # Write-Host $runtime

        # External display or AC power detected, break loop     
        if($externalDisplay -or $runtime -eq 71582788) {
            return $true
        }  
        Start-Sleep -Seconds $sleepTime
    }
}

# & $externalDisplayDisconnected $internalDisplayName 5
# Write-Host (getPowerOrExternalDisplay)
# exit

while($true) {
    if( (getPowerOrExternalDisplay) ) {
        Clear-Host
        $allowResetGPU = loop -function $externalDisplayConnected -Label "External display Or AC Power connected`n$lastReset"
    }

    # Protect from multiple GPU reset between one disconnect event
    if( $firstRun -or $allowResetGPU ) {
        Clear-Host
        Write-Host "External display and AC Power disconected, reset GPU in $waitReset second"
        Start-Sleep $waitReset
        
        # Make sure display is disconnected when GPU reset is done
        if( (getPowerOrExternalDisplay) ) {
            Clear-Host
            Write-Host "External display or AC Power detected, abandon reset gpu..."
            continue
        }
    
        $d = Get-PnpDevice | Where-Object  {$_.friendlyname -like "*NVIDIA GeForce*"} 
        $d | Disable-PnpDevice -Confirm:$false -verbose
        $d | Enable-PnpDevice -Confirm:$false -verbose
        
        $lastReset = "Last Reset " + (Get-Date -Format "dd/MMM/yyyy HH:mm:ss") +"`n"

        $firstRun = $false
        $allowResetGPU = $false
    }
    Clear-Host
    loop -function $externalDisplayDisconnected -Label "External display Or AC Power disconnected`n$lastReset"
}


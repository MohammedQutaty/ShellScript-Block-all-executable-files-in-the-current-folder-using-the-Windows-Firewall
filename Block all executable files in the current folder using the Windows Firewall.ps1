Write-Host -NoNewLine "
==================================================================================
    Mohammed Qutaty - Block every execute file on current folder and subfoldrs
==================================================================================" -ForegroundColor Green
Write-Host -NoNewLine "


Certainly! Below is a PowerShell script that will block all executable files in the current folder using the
Windows Firewall. This script also provides progress updates as it processes each file.
==================================================================================


" -ForegroundColor Red

# Get the current directory
$currentDir = Get-Location


[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null


function BlockFiles($selectDir) {
    # Get all executable files in the current directory
    $exeFiles = Get-ChildItem -Path $selectDir -Filter *.exe

    # Total number of files to process
    $totalFiles = $exeFiles.Count
    $currentFileIndex = 0

    # Loop through each executable file and block it in the firewall
    foreach ($file in $exeFiles) {
        $currentFileIndex++
        $filePath = $file.FullName

        # Add a firewall rule to block the executable file
        New-NetFirewallRule -DisplayName "Block $($file.Name)" -Direction Outbound -Program $filePath -Action Block
        Write-Host -NoNewLine "Block : " -ForegroundColor Red
        Write-Host $filePath
        # Display progress
        Write-Progress -Activity "Blocking executable files" -Status "Processing $($file.Name)" -PercentComplete (($currentFileIndex / $totalFiles) * 100)
    }
}

function SubFolders($selectDir) {
    $folderList = Get-ChildItem -Path $selectDir -Directory 

    $totalFolder = $folderList.Count
    $currentFolderIndex = 0

    foreach($folder in $folderList){
        $currentFolderIndex ++
        $folderPath = $folder.FullName

        Write-Progress -Activity "Blocking subfolders" -Status "Processing $($folder.Name)" -PercentComplete (($currentFolderIndex / $totalFolder) * 100)
        BlockFiles $folderPath
        SubFolders $folderPath
    }
}

function WaitFor10OrAnyKey($seconds)
{
    $a=0;
    Do
    {
        $b=[math]::Round($a/$seconds*100)
        Write-progress -activity “waiting..” -Status “$($b) about to finish::” -SecondsRemaining ($seconds - $a) -PercentComplete $b
        $a++
        Start-Sleep -Seconds 1
    } until ($a -eq $seconds)

}

$foldername = New-Object System.Windows.Forms.FolderBrowserDialog
$foldername.rootfolder = "Desktop"
$foldername.Description = "Select a folder"
$foldername.SelectedPath = (Get-Location).Path

if($foldername.ShowDialog() -eq "OK")
{
    $currentDir = $foldername.SelectedPath
    BlockFiles $currentDir
    SubFolders $currentDir

    Write-Output "Blocking of executable files completed."
    
} else {
    Write-Warning "Operation is canceled."
}

WaitFor10OrAnyKey(10)
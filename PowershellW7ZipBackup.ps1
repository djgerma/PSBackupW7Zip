$timestamp = (Get-Date -Format yyy-MM-dd-hh-mm)
$FileName = "_Some_FileName"

#REQUIRED: set the directory you want to compress.
$dirToArchive = "C:\SomeDirectory"

#leave blank in order to automatically use directory name as archive name, otherwise enter the filename of the archive to create
$archiveName = $timestamp + "_Some_FileName.7z"
$archiveName2 = $timestamp + "_Some_FileName.7z"
#$archiveName = "Data.7z"

#path to 7z.exe
$exec = "C:\Program Files\7-Zip\7z.exe"

if ([string]::IsNullOrWhiteSpace($archiveName) )
{
    $archiveName = (split-path -leaf $dirToArchive)+".7z"
}
$papadir = (Get-Item $dirToArchive ).Parent.FullName
#archive is automatically put into parent directory of $dirToArchive 
$archiveName = "\\server\share\folder\$archiveName2" #Join-Path $papadir $archiveName

echo "Archive Path: $archiveName"

if (Test-Path "$archiveName")
{  
    echo "archive already exists"
    exit
    #del "$archiveName"
}

$pw = "password_for_archive"

$extList = get-childitem -r "$dirToArchive" | where Attributes -NotMatch "Directory" | %{$_.Extension.ToLower()} | select -unique | sort
#loop through set of unique file extensions found in dir and add each one to archive (compressing or not compressing based on the extesnsion)
Foreach ($i in $extList)
{
    $str = $i.ToString()
    #change default compression level here (5=normal)
    $m = 5
    #for following extensions, Store but do not compress
    #if ($str -in (".zip", ".7z", ".rar", ".gz", ".bz2", ".pdf", ".docx", ".accdb", ".xlsx", ".png", ".jpg", ".avi", ".mpg", ".mp3", ".m4v", ".m4a"))
    #{
    #    $m = 0
    #}

    echo "Ext: $str m = $m" 
    
    $strWithExt = join-path "$dirToArchive" "*$str"
    $AllArgs = @('a', "-mx=$m", """$archiveName""", """$strWithExt""", "-r")
    #only add password param if user actually specified a password
    if ($pw -And $pw.Trim().Length -gt 0)
    {
        $AllArgs += "-p$pw"
    }

    & "$exec"  $AllArgs 
}

#remove archives older than 7 days
gci \\server\share\folder\*.7z -Recurse| where{-not $_.PsIsContainer}| sort CreationTime -desc| 
    select -Skip 7 | Remove-Item -Force

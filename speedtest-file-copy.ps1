# Can test copy speeds between different drives.  
# Attmpts to create enough large enough files cancel out disk cache
# Can run with defaults , edit the file or overwrite with the -parameter options
# Defaults are equivalent too
# speedtest-file-copy.ps1 -Dir1 c:\tmp -Dir2 d:\tmp -FileChars 200000 -NumFiles 10000
#

param (
    [string]$Dir1 = "c:\tmp",
    [string]$Dir2 = "d:\tmp",
    [int]$FileChars = 200000,
    [int]$NumFiles = 10000
)

$NumBytes = $FileChars * $NumFiles
# Formatted strings for pretty output
$FNumFiles = '{0:N}' -F $NumFiles
$FFileChars = '{0:N}' -F $FileChars
$FNumBytes = '{0:N}' -F $NumBytes

Function Create-Clean-Dirs {
    param (
        $TargetDir
    )
    New-Item -ItemType Directory -Force -Path $TargetDir\copy-test-source | Out-Null
    Remove-Item $TargetDir\copy-test-source\*
    
    New-Item -ItemType Directory -Force -Path $TargetDir\copy-test-dest | Out-Null
    Remove-Item $TargetDir\copy-test-dest\*    
}

# This takes two directories because data creation is the expensive part
# This way only have to do it once.
Function Create-Test-Files {
    Param(
        $Dir1, $Dir2
    )
    Write-Output "Creating test data  : length $FFileChars"
    # should run Measure-command here and capture results
    $Chunk = -join (
        (1..$FileChars) | % { 
            get-random -minimum 33 -maximum 127 | % {
                [char]$_ } 
        }
    )
    Write-Output "Creating test files in $Dir1 : $FNumFiles files of length $FFileChars"
    (1..$NumFiles) | % { 
        set-content "$Dir1\dummy_$_.bin" $Chunk
    }
    Write-Output "Creating test files in $Dir2 : $FNumFiles files of length $FFileChars"
    (1..$NumFiles) | % { 
        set-content "$Dir2\dummy_$_.bin" $Chunk
    }
} 

# -SourceDir -DestDir -FileChars -NumFiles
Function Copy-and-Measure {
    param (
        $SourceDir, $DestDir
    )
    Remove-Item $DestDir\copy-test-dest\*    
    Write-Output "Copying $FNumBytes bytes across $NumFiles files from $SourceDir to $DestDir"
    $RunTime = Measure-Command { Copy-Item $SourceDir\copy-test-source\* $DestDir\copy-test-dest }
    $TotalSeconds = $RunTime.TotalSeconds
    $FTotalSeconds = '{0:N}' -f $TotalSeconds
    $Rate = $NumBytes / $TotalSeconds
    $FRate = '{0:N}' -f $Rate
    Write-Output "     $FTotalSeconds sec - $FRate characters per second"
}


Write-Output "_______________________________________________"
Write-Output "Creating and cleaning directories"
Create-Clean-Dirs -TargetDir $Dir1
Create-Clean-Dirs -TargetDir $Dir2

Write-Output "_______________________________________________"
Write-Output "Creating test data"
Create-Test-Files -Dir1 $Dir1\copy-test-source -Dir2 $Dir2\copy-test-source

Write-Output "_______________________________________________"
Write-Output "Running Test"
Copy-and-Measure -SourceDir $Dir2 -DestDir $Dir2
Copy-and-Measure -SourceDir $Dir1 -DestDir $Dir2
Copy-and-Measure -SourceDir $Dir2 -DestDir $Dir1
Copy-and-Measure -SourceDir $Dir1 -DestDir $Dir1


Write-Output "_______________________________________________"
Write-Output "Removing test files"
Remove-Item $Dir1\copy-test-source\*
Remove-Item $Dir1\copy-test-dest\*
Remove-Item $Dir2\copy-test-source\*
Remove-Item $Dir2\copy-test-dest\*

    #  Script name:    EmptyAllRecycleBins.ps1
    #  Created on:     2015-05-23
    #  Modified By:    Jerry Linnihan
    #  Purpose:        Script to empty all recycle bins on Windows   

    :: This empties all recycle bins on Windows 7 and up
    rmdir /s /q %SystemDrive%\$Recycle.Bin 2>NUL
     
    :: This empties all recycle bins on Windows XP and Server 2003
    rmdir /s /q %SystemDrive%\RECYCLER 2>NUL


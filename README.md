# Back up, restore and migrate Microsoft Edge browser profiles between PCs PowerShellScripts

You can either use the [PowerShell script available on GitHub](https://github.com/RakhithJK/PowerShellScripts/blob/main/Backup-EdgeProfile.ps1) or install the [PowerShell module](https://www.powershellgallery.com/packages/EdgeBackupandRestore) directly into Windows.

Operation of the script / module is straight forward:

Specify the Edge channel you want to use (i.e. Stable, Beta, Dev, Canary)
Specify the output folder for the exported file

NOTE: You can’t have Edge running while you use the script as it will fail.

Once that’s done, simply pop it into your OneDrive or on a USB drive to get it over to your other machine.

This effectively takes a copy of all of the Edge profile folders, cache, images and all. So, if you’ve been going for a while you can end up with a large zip file.

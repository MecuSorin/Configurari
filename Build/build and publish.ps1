function UserWantsToStop([string]$question)
{
	$yesOption = New-Object System.Management.Automation.Host.ChoiceDescription "&Da",""
	$noOption = New-Object System.Management.Automation.Host.ChoiceDescription "&Nu",""
	$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yesOption, $noOption)
	$caption = "Warning!"
	$message = "Do you want to proceed with " + $question
	$result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
	if($result -eq 0) 
	{ 
		Write-Host -fore Green "You answered DA" 
		return $FALSE
	}
	if($result -eq 1) 
	{ 
		Write-Host -fore Red "You answered NU" 
		return $TRUE
	}
}

$currentDataDownloadSolutionDir = "c:\Users\smecu\Documents\Visual Studio 2010\Projects\SASCurrentDataDownload"
$gitRepoDir = "e:\t\Downloader"
$gitDir = "e:/t/Downloader"

#BUILD SOLUTION
& "$env:SystemRoot\Microsoft.Net\Framework\v3.5\MsBuild.exe" $($currentDataDownloadSolutionDir+"\SASCurrentDataDownload.sln") /m /t:ReBuild "/p:Configuration=Debug"
Write-Host -Fore Cyan "Solution build terminated"

#COPY FILES TO GIT REPO Dir
if( UserWantsToStop "Copy to git repo" ) { exit }
Get-ChildItem $($currentDataDownloadSolutionDir + "\SASCurrentDataDownload.Service\Bin\Debug") | ? { !($_ -match "^(.*config|.*log|.*\.vshost\..*)$") } | foreach { Copy-Item $_.FullName -Destination $gitRepoDir }
Write-Host -Fore Cyan "Done files copy"

#COMMIT CHANGES
if( UserWantsToStop "Commit changes to remote" ) { exit }
$messageFromSourceGitRepo = & git --git-dir="$($currentDataDownloadSolutionDir + "\.git")" --work-tree=$currentDataDownloadSolutionDir log -1 --pretty=%B
& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir add -A
& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir commit -am $messageFromSourceGitRepo
Write-Host -Fore Cyan "Commited the files"

#PUBLISH CHANGES TO REMOTE
& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir push origin master
Write-Host -Fore Cyan "Published the files"
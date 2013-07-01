function Git-CommitAll
{
	param([string]$message)
	if($message)
	{
		$svnVersionReply = svnversion.exe
		$version = Select-String -InputObject $svnVersionReply -Pattern "\d+:(\d+).*" | %{ $_.Matches[0].Groups[1].Value }
		if($version)
		{
			git add -A
			git commit -am "SVN $version : $message"
		}
		else
		{
			git add -A
			git commit -am "$message"	
		}		
	}
	else
	{
		Write-Host "You must supply a message for the commit" -ForegroundColor Red	
	}	
}

function Git-CommitAllWithSVNVersionMessage
{
	$svnVersionReply = svnversion.exe
	$version = Select-String -InputObject $svnVersionReply -Pattern "\d+:(\d+).*" | %{ $_.Matches[0].Groups[1].Value }
	if($version)
	{
		git add -A
		git commit -am "SVN $version"
	}
	else
	{
		Write-Host "Unable to get the SVN version for the commit" -ForegroundColor Red	
	}	
}

function Git-MergeInMaster
{
	$status = Get-GitStatus
	$currentBranch = $status.Branch
	if((-not $status.HasWorking) -and (-not $status.HasUntracked) -and ( $currentBranch  -ne "master" ))
	{
		git checkout master
		git merge $currentBranch
		git checkout $currentBranch
		Write-Host "Done" -ForegroundColor DarkGreen
	}
}

function panic 
{ 
    &"c:\Program Files\7-Zip\7z.exe" a -t7z $("d:\Backup\git panic "+(get-date).ToString("yyyyMMdd-HHmm")+".7z") *
}

function StartWithLower
{
     $input | ? { $_-cmatch '^[a-z].*$'}
}

function Substring_2
{
     $input | ForEach-Object{ $_.Substring(2)}
}

function git-list-skip
{
	git ls-files -v | StartWithLower | Substring_2
}

function git-skip-list
{
	git ls-files -v | StartWithLower | Substring_2
}

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

function Publish-Downloader_Test()
{
	XPublish-DownloaderProductie "Test" "c:\Users\smecu\AppData\Roaming\SASG\SASFleetPro\"
}

function Publish-Downloader_Productie()
{
	XPublish-DownloaderProductie "master" "e:\Programare\SAS\SASGDesktop\Productie\2013 02 14\SASFleetPro\"
}

function XPublish-DownloaderProductie() 
{
	param([string]$branch, [string]$resourcesDir)
	$currentDataDownloadSolutionDir = "c:\Users\smecu\Documents\Visual Studio 2010\Projects\SASCurrentDataDownload"
	$gitRepoDir = "e:\t\Downloader"
	$gitDir = "e:/t/Downloader"
	$resourcesNames = @("Core.DLL", "SASGWcf.DLL", "SASGWcfProxy.DLL", "SASGZipLib.DLL", "sasgsrv.ini")

	#BUILD SOLUTION
	$resourcesNames | foreach { Copy-Item $($resourcesDir + $_) -Force -Destination $($currentDataDownloadSolutionDir + "\Resources\SASGrup") }
	& "$env:SystemRoot\Microsoft.Net\Framework\v3.5\MsBuild.exe" $($currentDataDownloadSolutionDir+"\SASCurrentDataDownload.sln") /maxcpucount /verbosity:minimal /t:ReBuild "/p:Configuration=Debug"
	Write-Host -Fore Cyan "Solution build terminated"

	#COPY FILES TO GIT REPO Dir
	if( UserWantsToStop "Copy to git repository" ) { return }
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir checkout $branch
	Get-ChildItem $($currentDataDownloadSolutionDir + "\SASCurrentDataDownload.Service\Bin\Debug") | ? { !($_ -match "^(sasgsrv\.ini|.*config|.*log|.*\.vshost\..*)$") } | foreach { Copy-Item $_.FullName -Destination $gitRepoDir }
	Write-Host -Fore Cyan "Done files copy"

	#COMMIT CHANGES
	if( UserWantsToStop "Commit changes to local repository" ) { return }
	$messageFromSourceGitRepo = & git --git-dir="$($currentDataDownloadSolutionDir + "\.git")" --work-tree=$currentDataDownloadSolutionDir log -1 --pretty=%B
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir add -A
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir commit -am $messageFromSourceGitRepo
	Write-Host -Fore Cyan "Commited the files"

	#PUBLISH CHANGES TO REMOTE
	if( UserWantsToStop "Publish changes to remote" ) { return }
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir push sas $branch:$branch
	Write-Host -Fore Cyan "Published the files"
}

function Publish-Site()
{
	$solutionDir = "c:\Users\smecu\Documents\Visual Studio 2010\Projects\Web Sandbox\SASFleetSite"
	$gitRepoDir = "e:\t\SiteAuto"
	#http://www.digitallycreated.net/Blog/59/locally-publishing-a-vs2010-asp.net-web-application-using-msbuild
	#BUILD SOLUTION
	& "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" $($solutionDir+"\SASFleetSite.sln") /m /v:minimal /t:ReBuild /p:Configuration=Debug
	Write-Host -Fore Cyan "Solution build terminated"

	#COPY FILES TO GIT REPO Dir
	if( UserWantsToStop "Copy to git repo" ) { return }
	& "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" /m /v:minimal $($solutionDir+"\SASFleetSite\SASFleetSite.csproj") $("/p:Platform=AnyCPU;Configuration=Debug;PublishDestination="+$gitRepoDir) /t:PublishToFileSystem
	Write-Host -Fore Cyan "Done files copy"

	#COMMIT CHANGES
	if( UserWantsToStop "Commit changes to repository" ) { return }
	$messageFromSourceGitRepo = & git --git-dir="$($solutionDir + "\.git")" --work-tree=$solutionDir log -1 --pretty=%B
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir add -A
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir checkout HEAD Web.config
	#"$($gitRepoDir+"\Web.config")"
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir commit -am $messageFromSourceGitRepo
	Write-Host -Fore Cyan "Commited the files"

	#PUBLISH CHANGES TO REMOTE
	if( UserWantsToStop "Publish changes to remote" ) { return }
	& git --git-dir="$($gitRepoDir + "\.git")" --work-tree=$gitRepoDir push sas master
	Write-Host -Fore Cyan "Published the files"
}


function x_gitM-status()
{
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusStatus_Dir $MariusDir "SASGBusinessUIControls"
    gitHelper-MariusStatus_Dir $MariusDir "SASGDesktop"
    gitHelper-MariusStatus_Dir $MariusDir "SASGSilverlightMapControl"
    gitHelper-MariusStatus_Dir $MariusDir "SASGUIControls"
    gitHelper-MariusStatus_Dir $MariusDir "SASGWinformsMapControl"
    gitHelper-MariusStatus_Dir $MariusDir "SDKSample"
    gitHelper-MariusStatus_Dir $MariusDir ""
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitM-log()
{
    param([string]$numberOfLogMessages = "-4")
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusLog_Dir $MariusDir "SASGBusinessUIControls" $numberOfLogMessages
    gitHelper-MariusLog_Dir $MariusDir "SASGDesktop" $numberOfLogMessages
    gitHelper-MariusLog_Dir $MariusDir "SASGSilverlightMapControl" $numberOfLogMessages
    gitHelper-MariusLog_Dir $MariusDir "SASGUIControls" $numberOfLogMessages
    gitHelper-MariusLog_Dir $MariusDir "SASGWinformsMapControl" $numberOfLogMessages
    gitHelper-MariusLog_Dir $MariusDir "SDKSample" $numberOfLogMessages
    gitHelper-MariusLog_Dir $MariusDir "" $numberOfLogMessages
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitM-NextDir()
{
    $MariusDir = "d:\Programare\_Work\Marius\"
    $MariusDirWithoutSeparator = "d:\Programare\_Work\Marius"
    $currentDir = get-location
    switch ($currentDir.Path){
	$($MariusDir+"SASGBusinessUIControls") { cd $($MariusDir+"SASGDesktop") }
	$($MariusDir+"SASGDesktop") { cd $($MariusDir+"SASGSilverlightMapControl") }
	$($MariusDir+"SASGSilverlightMapControl") { cd $($MariusDir+"SASGUIControls")  }
	$($MariusDir+"SASGUIControls" ) { cd $($MariusDir+"SASGWinformsMapControl") }
	$($MariusDir+"SASGWinformsMapControl") { cd $($MariusDir+"SDKSample") }
	$($MariusDir+"SDKSample") { cd $MariusDirWithoutSeparator }
	$MariusDirWithoutSeparator { cd $($MariusDir+"SASGBusinessUIControls") }
	default {Write-Host "Unsupported location" -fore Red}
    }
}

function x_gitM-Checkout([string]$branchName)
{
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusCheckout_Dir $MariusDir "SASGBusinessUIControls" $branchName
    gitHelper-MariusCheckout_Dir $MariusDir "SASGDesktop" $branchName
    gitHelper-MariusCheckout_Dir $MariusDir "SASGSilverlightMapControl" $branchName
    gitHelper-MariusCheckout_Dir $MariusDir "SASGUIControls" $branchName
    gitHelper-MariusCheckout_Dir $MariusDir "SASGWinformsMapControl" $branchName
    gitHelper-MariusCheckout_Dir $MariusDir "SDKSample" $branchName
    gitHelper-MariusCheckout_Dir $MariusDir "" $branchName
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitM-CheckoutNew([string]$branchName)
{
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusCheckoutNew_Dir $MariusDir "SASGBusinessUIControls" $branchName
    gitHelper-MariusCheckoutNew_Dir $MariusDir "SASGDesktop" $branchName
    gitHelper-MariusCheckoutNew_Dir $MariusDir "SASGSilverlightMapControl" $branchName
    gitHelper-MariusCheckoutNew_Dir $MariusDir "SASGUIControls" $branchName
    gitHelper-MariusCheckoutNew_Dir $MariusDir "SASGWinformsMapControl" $branchName
    gitHelper-MariusCheckoutNew_Dir $MariusDir "SDKSample" $branchName
    gitHelper-MariusCheckoutNew_Dir $MariusDir "" $branchName
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitM-CommitChangesToCurrentBranch([string]$commitStatement)
{
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusCommitChangesToCurrentBranch_Dir $MariusDir "SASGBusinessUIControls" $commitStatement
    gitHelper-MariusCommitChangesToCurrentBranch_Dir $MariusDir "SASGDesktop" $commitStatement
    gitHelper-MariusCommitChangesToCurrentBranch_Dir $MariusDir "SASGSilverlightMapControl" $commitStatement
    gitHelper-MariusCommitChangesToCurrentBranch_Dir $MariusDir "SASGUIControls" $commitStatement
    gitHelper-MariusCommitChangesToCurrentBranch_Dir $MariusDir "SASGWinformsMapControl" $commitStatement
    gitHelper-MariusCommitChangesToCurrentBranch_Dir $MariusDir "SDKSample" $commitStatement
    gitHelper-MariusCommitChangesToCurrentBranch_Dir $MariusDir "" $commitStatement
   
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitM-MergeMasterWithBranch([string]$branchName)
{
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusMergeMasterWithBranch_Dir $MariusDir "SASGBusinessUIControls" $branchName
    gitHelper-MariusMergeMasterWithBranch_Dir $MariusDir "SASGDesktop" $branchName
    gitHelper-MariusMergeMasterWithBranch_Dir $MariusDir "SASGSilverlightMapControl" $branchName
    gitHelper-MariusMergeMasterWithBranch_Dir $MariusDir "SASGUIControls" $branchName
    gitHelper-MariusMergeMasterWithBranch_Dir $MariusDir "SASGWinformsMapControl" $branchName
    gitHelper-MariusMergeMasterWithBranch_Dir $MariusDir "SDKSample" $branchName
    gitHelper-MariusMergeMasterWithBranch_Dir $MariusDir "" $branchName
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitM-BranchShow()
{
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusBranchShow_Dir $MariusDir "SASGBusinessUIControls"
    gitHelper-MariusBranchShow_Dir $MariusDir "SASGDesktop"
    gitHelper-MariusBranchShow_Dir $MariusDir "SASGSilverlightMapControl"
    gitHelper-MariusBranchShow_Dir $MariusDir "SASGUIControls"
    gitHelper-MariusBranchShow_Dir $MariusDir "SASGWinformsMapControl"
    gitHelper-MariusBranchShow_Dir $MariusDir "SDKSample"
    gitHelper-MariusBranchShow_Dir $MariusDir ""
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitM-BranchDelete([string]$branchName)
{
    $MariusDir = "d:\Programare\_Work\Marius"
    d:
    gitHelper-MariusBranchDelete_Dir $MariusDir "SASGBusinessUIControls" $branchName
    gitHelper-MariusBranchDelete_Dir $MariusDir "SASGDesktop" $branchName
    gitHelper-MariusBranchDelete_Dir $MariusDir "SASGSilverlightMapControl" $branchName
    gitHelper-MariusBranchDelete_Dir $MariusDir "SASGUIControls" $branchName
    gitHelper-MariusBranchDelete_Dir $MariusDir "SASGWinformsMapControl" $branchName
    gitHelper-MariusBranchDelete_Dir $MariusDir "SDKSample" $branchName
    gitHelper-MariusBranchDelete_Dir $MariusDir "" $branchName
    Write-Host "Done" -ForegroundColor DarkGreen
}

function x_gitHelper-MariusStatus_Dir ()
{
    param([string]$MariusDir, [string]$dirName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git status
}


function x_gitHelper-MariusLog_Dir ()
{
    param([string]$MariusDir, [string]$dirName, [string]$numberOfLogMessages = "-4")
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git lg $numberOfLogMessages
}


function x_gitHelper-MariusBranchShow_Dir ()
{
    param([string]$MariusDir, [string]$dirName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git branch
}

function x_gitHelper-MariusBranchDelete_Dir ()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git branch -D $branchName
}
  

function x_gitHelper-MariusCheckout_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git checkout $branchName
}

function x_gitHelper-MariusCheckoutNew_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git checkout -b $branchName
}

function x_gitHelper-MariusMergeMasterWithBranch_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git checkout master
    git merge $branchName
}

function x_gitHelper-MariusCommitChangesToCurrentBranch_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$commitStatement)
    
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git add -A
    git commit -am "$commitStatement"
}

function x_gitM-UpdateSASResources()
{
    $sourceDir = "c:\Users\smecu\Documents\Visual Studio 2010\Projects\SASGDesktop Trunk\SASGDesktop\bin\Debug"
    $destinationDir = "d:\Programare\_Work\Marius\_DllResources\SAS"
    copy-item $sourceDir\Core.dll -destination $destinationDir
    copy-item $sourceDir\Core.pdb -destination $destinationDir
    copy-item $sourceDir\SASGFlatMenu.dll -destination $destinationDir
    copy-item $sourceDir\SASGFlatMenu.pdb -destination $destinationDir
    copy-item $sourceDir\SASGFlatUIControls.dll -destination $destinationDir
    copy-item $sourceDir\SASGFlatUIControls.pdb -destination $destinationDir
    copy-item $sourceDir\SASGWcf.dll -destination $destinationDir
    copy-item $sourceDir\SASGWcf.pdb -destination $destinationDir
    copy-item $sourceDir\SASGWcfProxy.dll -destination $destinationDir
    copy-item $sourceDir\SASGWcfProxy.pdb -destination $destinationDir
    copy-item $sourceDir\SASGZipLib.dll -destination $destinationDir
    copy-item $sourceDir\SASGZipLib.pdb -destination $destinationDir
    Write-Host "Done" -ForegroundColor DarkGreen
}


$env:Path += ";C:\bin"
# Load posh-git example profile
. 'D:\Programare\Git Powershell integration\posh-git\profile.example.ps1'




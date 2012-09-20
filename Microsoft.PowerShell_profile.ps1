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
	if(!$version)
	{
		git add -A
		git commit -am "SVN $svnVersion"
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

function git-luiau
{
     git luiau | StartWithLower | Substring_2
}

function gitM-status()
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

function gitM-log()
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

function gitM-NextDir()
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

function gitM-Checkout([string]$branchName)
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

function gitM-CheckoutNew([string]$branchName)
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

function gitM-CommitChangesToCurrentBranch([string]$commitStatement)
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

function gitM-MergeMasterWithBranch([string]$branchName)
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

function gitM-BranchShow()
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

function gitM-BranchDelete([string]$branchName)
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

function gitHelper-MariusStatus_Dir ()
{
    param([string]$MariusDir, [string]$dirName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git status
}


function gitHelper-MariusLog_Dir ()
{
    param([string]$MariusDir, [string]$dirName, [string]$numberOfLogMessages = "-4")
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git lg $numberOfLogMessages
}


function gitHelper-MariusBranchShow_Dir ()
{
    param([string]$MariusDir, [string]$dirName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git branch
}

function gitHelper-MariusBranchDelete_Dir ()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git branch -D $branchName
}
  

function gitHelper-MariusCheckout_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git checkout $branchName
}

function gitHelper-MariusCheckoutNew_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git checkout -b $branchName
}

function gitHelper-MariusMergeMasterWithBranch_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$branchName)
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git checkout master
    git merge $branchName
}

function gitHelper-MariusCommitChangesToCurrentBranch_Dir()
{
    param([string]$MariusDir, [string]$dirName, [string]$commitStatement)
    
    Write-Host $($MariusDir+"\"+$dirName) -Fore DarkBlue
    cd $($MariusDir+"\"+$dirName)
    git add -A
    git commit -am "$commitStatement"
}

function gitM-UpdateSASResources()
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




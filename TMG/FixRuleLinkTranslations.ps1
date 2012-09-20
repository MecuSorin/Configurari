# Fix the link translations of the provided rule
function Fix-LinkTranslations ($rule)
{
    if($null -eq $rule)
    {
        throw "Cannot fix link translations for a null rule."
    }
    #FpcPolicyRuleTypes.fpcPolicyRuleWebPublishing == 2
    if( $rule.Type -ne 2)
    {
        throw "The rule specified is not a Web publishing rule."
    }
    
    $publicNames = $rule.WebPublishingProperties.PublicNames
    if( 0 -eq $publicNames.Length)
    {
        throw "The rule specified have no Public Names defined."    }
    [bool]$shouldSave = $false
    $vpSet = $rule.VendorParametersSets.Item("{3563FFF5-DF93-40eb-ABC3-D24B5F14D8AA}")
    # add link translations
    foreach($publicName in $publicNames)
    {
        $httpAddress = "http://$publicName"
        try
        {
            $httpAddressValue = $vpSet.Value($httpAddress)
            if($httpAddressValue -ne $httpAddress)
            {
                Write-Host "Invalid link translation $httpAddress > $httpAddressValue" -fore red
            }
        }
        catch
        {
            $vpSet.Value($httpAddress) = $httpAddress
            Write-Host "Added link translation $httpAddress > $httpAddress" -fore green
            $shouldSave = $true
        }
        
        $httpsAddress = "https://$publicName"
        try
        {
            $httpsAddressValue = $vpSet.Value($httpsAddress)
            if($httpsAddressValue -ne $httpsAddress)
            {
                Write-Host "Invalid link translation $httpsAddress > $httpsAddressValue" -fore red
            }
        }
        catch
        {
            $vpSet.Value($httpsAddress) = $httpsAddress
            Write-Host "Added link translation $httpsAddress > $httpsAddress" -fore green
            $shouldSave = $true
        }
    }
    $linksToRemove=@()
    #remove link translations without associated public name
    foreach($link in $vpSet.Names)
    {
        [string] $associatedNameForCurrentLink = $publicNames | % { if($link -match "^https{0,1}://$_$") { $_ } } | select -first 1
        if(!$associatedNameForCurrentLink)
        {
	    $linksToRemove = $linksToRemove + $link
	}
    }
    foreach($link in $linksToRemove)
    {
        Write-Host "Removed link translation $link > $vpSet.Value($link)" -fore yellow
        #$vpSet.RemoveValue($link)
        $shouldSave = $true
    }
    
    if( $true -eq $shouldSave)
    {
        $rule.Save()
        Write-Host "Saved the changes. Restart the TMG !!!" -fore yellow
    }
    else
    {
        Write-Host "Nothing to save" -fore yellow
    }
    $vpSet = $null
    $rule = $null
}



# Gets the rule from name or index(numbering starting from 1)
function  Get-TMGFirewallRule ([string]$ruleID)
{
    [int]$outInt = 0
    [bool]$isNumber = [System.Int32]::TryParse($ruleID, [ref]$outInt)
    $root = New-Object -ComObject FPC.root
    if($true -eq $isNumber)
    {
        $rule = $root.GetContainingArray().ArrayPolicy.PolicyRules.Item($outInt)
    }
    else
    {
        $rule = $root.GetContainingArray().ArrayPolicy.PolicyRules.Item($ruleID)
    }
    $root = $null
    return $rule
}





#script body
if ($args[0] -eq $null)
{
      Write-Host "Insufficient parameters"
      Write-Host "Usage: FixRuleLinkTranslations rule_identifier"
      Write-Host "         Where the rule_identifier is the rule number(numerotation starts at 1)"
      exit
}
else
{
    $ruleID=$args[0]
}

try
{

    Write-Host "Search for rule $ruleID" -fore white
    $rule = Get-TMGFirewallRule $ruleID
    if($rule -eq $null)
    {
        Write-Host "Failed to identify the rule by the provided id"  -fore red
    }
    else
    {
        Write-Host "Fixing the rule $($rule.Name)" -fore white
        Fix-LinkTranslations $rule
    }
}
catch
{
    Write-Host "SCRIPT FAILED !!!" -fore red
    $_
    exit
}

 
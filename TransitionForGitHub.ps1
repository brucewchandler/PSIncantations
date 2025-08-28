#########################################################
# Restores Source agency Azure account                  #
# Updates ImmutableID to link with HHSC AD Account      #
#                                                       #
# Bruce.Chandler@hhsc.state.tx.us                       #
# V 1.2 9/13/2016                                       #
# V 2.0 11/20/2018                                      #
# V 3.0 8/5/2020                                        #
#########################################################



#Connect to AzureAD and MSOLService - Added 8/5/2020
#$path = Get-Location
#$O365Cred = New-Object System.Management.Automation.PSCredential("admin.bruce@txhhs.onmicrosoft.com",(Get-Content -Path "$path\o365.txt" | ConvertTo-SecureString))
#Connect-AzureAD -Credential $O365Cred
#Connect-MsolService -Credential $O365Cred

# Set Global Variables
$date = Get-Date -Format "MM/dd/yyyy HH:mm K"
$hhscdc = "[Enter DC]"
$tenant = "[Enter Tenant]"
$hhsc = "[Enter target domain]"
$notfed = "[Enter NotFed domain]"
$runlog = "$path\log.txt"
$errorlog = "$path\errorlog.txt"
$AzureGroup = "[Enter Azure Group ObjectID]"

#Start Transcript
#Start-Transcript -Path "$path\11042020.txt"

# Import User accounts
$users = Import-Csv -Path "$path\users.csv"

# ForEach loop for Immutable ID Process
ForEach ($user in $users){

# Loop Variables
    $HHSCObjectGuid = $user.HHSCObjectGUID
    $ObjectID = $user.ObjectID
    $upn = $user.UniqueUPN
    $agency = "[Enter agency identifier]"
    $newupn = $upn.Replace($hhsc,$notfed)
    $arr = $newupn.Split("@") # Split into an array of strings based on the @symbol
    $TEMPACCOUNT = $agency.Trim() +  "." + $arr[0] + "@[Enter tenant identifier].onmicrosoft.com"
    $immutableID = $user.ImmutableID
        
    # Restore source Azure AD account and update UserPrincipal name to @[tenant identifier].onmicrosoft.com
    Write-Host "Restoring $upn" -ForegroundColor Magenta
    Restore-MsolUser -ObjectId $ObjectID
    try{
    Do
    {$RestoredMSOLUser = Get-AzureADUser -ObjectID $objectID -ErrorAction SilentlyContinue
    Write-Host "Verifying $ObjectID restored" -ForegroundColor Yellow
    }Until ($RestoredMSOLUser.ObjectID -eq $ObjectID)
    Write-Host "$ObjectID Restored" -ForegroundColor Green
    Set-MsolUserPrincipalName -ObjectID $ObjectID -newuserprincipalname $TEMPACCOUNT
    Write-Host "$upn updated to $TEMPACCOUNT" -ForegroundColor Green
    }Catch{}

    # Update ImmutableID
    Do
    {$Restored = Get-AzureADUser -ObjectID $ObjectID -ErrorAction SilentlyContinue
    Write-Host "Verifying $ObjectID updated" -ForegroundColor Yellow
    }Until($Restored.ObjectID -eq $ObjectID)
    Write-Host "$ObjectID found. Continuing." -ForegroundColor Green
    Write-Host "Updating ImmutableID of $TEMPACCOUNT to $immutableID" -ForegroundColor Green
    Set-MSOLUser -ObjectId $ObjectID -immutableID $immutableID
    Write-Host "$TEMPACCOUNT ImmutableID updated to $immutableID" -ForegroundColor Yellow

    # Add to licensing Azure Group
    Write-Host  "Adding $upn to [Licenseing Azure Group Name]" -ForegroundColor Green
    Add-MsolGroupMember -GroupObjectId $AzureGroup -GroupMemberType User -GroupMemberObjectId $ObjectID -ErrorAction SilentlyContinue
    Write-Host "$ObjectID added to $AzureGroup" -ForegroundColor Yellow
    
    # Change UPN to @[new domain]
    Write-Host "Changing $TEMPACCOUNT to $upn" -ForegroundColor Green
    Set-MsolUserPrincipalName -ObjectId $ObjectID -newuserprincipalname $upn
    Write-Host "$TEMPACCOUNT changed to $upn" -ForegroundColor Yellow

    }
    Disconnect-AzureAD -Confirm:$false
    #Stop-Transcript
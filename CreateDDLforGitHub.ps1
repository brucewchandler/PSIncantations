# CreateDDL.ps1
# Author: Bruce Chandler brucewchandler@gmail.com
# V1 08/28/2025
# V1.1 08/29/2025 - Moved the calls to ShowAgency-Menu under the DeptID and BusID elseif sections because the Building section does not need to identifiy Agency ([agency2] has no Building DDLs)

# Connect to Exchange Online for the creation code
# Un-comment the line below if you want the script to connect. Leave it commented out if you connect manually.
# Connect-ExchangeOnline

# Function to select which DDL type is needed
function ShowType-Menu
{
    param (
        [string]$Title = 'DDL Type Selection'
    )
    Write-Host "$Title" -ForegroundColor Yellow
    
    Write-Host "1: Press '1' for DeptID" -ForegroundColor Yellow
    Write-Host "2: Press '2' for BusID" -ForegroundColor Yellow
    Write-Host "3: Press '3' for Building" -ForegroundColor Yellow
}

# function to pick agency
function ShowAgency-Menu
{
    param (
        [string]$Title = 'Agency Selection'
    )
    Write-Host "$Title" -ForegroundColor Yellow
    
    Write-Host "1: Press '1' for [Agency1]" -ForegroundColor Yellow
    Write-Host "2: Press '2' for [Agency2]" -ForegroundColor Yellow
}

#Pick the DDL type and set the $ddlType variable
ShowType-Menu
Write-Host "Make a DDL Type selection." -ForegroundColor Yellow
$type = Read-Host 
switch ($type)
{
     '1' {$ddlType="DeptID"} 
     '2' {$ddlType="BusID"}
     '3' {$ddlType="Building"} 
 }

  # if-else to set $city and $fID if $ddlType -eq Building and set $DeptID or $BusID, $agency, and $domain if $ddlType -eq DeptID or BusID
 if ($ddlType -eq "Building") {
    Write-Host "Enter the City for the Building DLL" -ForegroundColor Yellow
    $city = Read-Host
    Write-Host "Enter the Facility Code for the Building DDL" -ForegroundColor Yellow
    $fID = Read-Host 
    # These variables are relevant to how my workplace handles DDGs for buildings/locations
    $sender = "[PSMTP of MESG for approved senders]"
    $domain = "@[tenant designator].onmicrosoft.com"
    $agency = "[agency1]"
    $alias = "BLDG" + "$fID"
 } elseif ($ddlType -eq "DeptID" -or $ddlType -eq "BusID") { 
    # pick agency to set $agency and $domain variables
    ShowAgency-Menu
    Write-Host "Make an Agency selection." -ForegroundColor Yellow
    $type = Read-Host 
    switch ($type)
    {
     '1' {($agency = "[agency1]"),($domain = "@[agency1 domain]")} 
     '2' {($agency = "[agency2]"),($domain = "@[agency2 domain]")}
    }
}

# if-else to set $DeptID or $BusID
if ($ddlType -eq "DeptID") { 
    Write-Host "Enter the DeptID in ALL CAPS" -ForegroundColor Yellow 
    $DeptID = Read-Host
}
elseif ($ddlType -eq "BusID") {
    Write-Host "Enter the BusID in ALL CAPS" -ForegroundColor Yellow
    $BusID = Read-Host
 }

# if-elseif to set $name and $psmtp based on the user input
if ($agency -eq "[agency1]" -and $ddlType -eq "Building") {
    ($name = "DDL " + "$agency " + "Building " + "$fID " + "$city"),($psmtp = "BLDG" + "$fID" + "$tenant")
} elseif ($agency -eq "[agency1]" -and $ddlType -eq "DeptID") {
    ($name = "DDL " + "$agency " + "$ddlType " + "$DeptID"),($psmtp = "$DeptID" + "$domain")
} elseif ($agency -eq "[agency1]" -and $ddlType -eq "BusID") {
    ($name = "DDL " + "$agency " + "$ddlType " + "$BusID"),($psmtp = "$BusID" + "$domain")
} elseif ($agency -eq "[agency2]" -and $ddlType -eq "DeptID") {
    ($name = "DDL " + "$agency " + "$ddlType " + "$DeptID"),($psmtp = "$DeptID" + "$domain")
} else {
    ($name = "DDL " + "$agency " + "$ddlType " + "$BusID"),($psmtp = "$BusID" + "$domain")
}

# check name. Exit if name or psmtp is wrong. Continue if correct (based on user input)
Write-Host "Here is the name and email address that will be used. Does it look correct? Answer Y/N." -ForegroundColor Yellow
Write-Host "$name" -ForegroundColor Green
Write-Host "$psmtp" -ForegroundColor Green
$answer = Read-Host "Enter Y or N"
if ($answer -eq "N") {
    Write-Host "Let's try this again. Exiting script so you can start over." -ForegroundColor Red
} else {
    Write-Host "Looks good. Let's create the DDL." -ForegroundColor Green
# create the DDL
    Write-Host "Creating $name $psmtp" -ForegroundColor Yellow
    if ($ddlType -eq "Building") {
        New-DynamicDistributionGroup -Name $name -DisplayName $name -PrimarySmtpAddress $psmtp -ConditionalCustomAttribute7 $fID  -Alias $Alias -IncludedRecipients MailUsers
        Start-Sleep -Seconds 10
        Set-DynamicDistributionGroup -Identity $psmtp -AcceptMessagesOnlyFromDLMembers $sender
        Write-Host "$name $psmtp has been created." -ForegroundColor Green
    } elseif ($ddlType -eq "DeptID") {
        New-DynamicDistributionGroup -Name $name -DisplayName $name -PrimarySmtpAddress $psmtp -ConditionalCustomAttribute5 $DeptID  -Alias "$DeptID" -IncludedRecipients MailUsers
        Start-Sleep -Seconds 10
        Set-DynamicDistributionGroup -Identity $psmtp -HiddenFromAddressListsEnabled $true
        Write-Host "$name $psmtp has been created." -ForegroundColor Green
    } elseif ($ddlType -eq "BusID") {
        New-DynamicDistributionGroup -Name $name -DisplayName $name -PrimarySmtpAddress $psmtp -ConditionalCustomAttribute6 $BusID  -Alias "$BusID" -IncludedRecipients MailUsers
        Start-Sleep -Seconds 10
        Set-DynamicDistributionGroup -Identity $psmtp -HiddenFromAddressListsEnabled $true
        Write-Host "$name $psmtp has been created." -ForegroundColor Green
    } else {exit}
}   
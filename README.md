# PSIncantations
A few samples of my PowerShell work

TransitionForGitHub.ps1

The challenge: Multiple agencies were on a single M365 tenant, but each agency had their own AD domain hosting their AD user accounts. A legislative mandate obsorbing some of the agencies into the "parent" agency was enacted. The Active Directory team created new AD accounts in the "parent" AD and disabled the AD accounts in the obsored agency's AD, and I came up with a plan to "attach" the new AD accounts to the already-existing M365 accounts.

The plan:
• Create a script to gather needed attributes for the transitioning accounts and dump the data into a .csv file
• After the "obsorbed" domain accounts were disabled, restore the associated Azure AD accounts and update the UserPrincipalName to the tenant domain (unfederated.)
• Update the ImutableID (AAD Connect sync anchor) on the Azure AD accounts so that they now sync with the "parent" AD domain accounts
• Update the UserPrincipalName to the "parent" domain (federated.)

Although outdated now due to newer AD tools for moving accounts across domains and retired PowerShell commandlets, this plan worked to complete the challenge.

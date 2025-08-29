# PSIncantations
A few samples of my PowerShell work

**********
TransitionForGitHub.ps1

The challenge:
Multiple agencies were on a single M365 tenant, but each agency had their own AD domain hosting their AD user accounts. A legislative mandate obsorbing some of the agencies into the "parent" agency was enacted. The Active Directory team created new AD accounts in the "parent" AD and disabled the AD accounts in the obsored agency's AD, and I came up with a plan to "attach" the new AD accounts to the already-existing M365 accounts.

The plan:
• Create a script to gather needed attributes for the transitioning accounts and dump the data into a .csv file
• After the "obsorbed" domain accounts are disabled, restore the associated Azure AD accounts and update the UserPrincipalName to the tenant domain (unfederated.)
• Update the ImutableID (AAD Connect sync anchor) on the Azure AD accounts so that they now sync with the "parent" AD domain accounts
• Update the UserPrincipalName to the "parent" domain (federated.)

Although outdated now due to newer AD tools for moving accounts across domains and retired PowerShell commandlets, this plan worked to complete the challenge.

**********
CreateDDLforGitHub.ps1

The challenge:
My current workplace primarly uses 3 types of Dynamic Distribution Groups, where the membership queury is based on Department ID, Business Unit, or Facility ID. If there is a re-org, or changes in facilites, old DDGs need to be retired and new ones created. Other admins weren't always following the standards for DDG creation, so I wrote this script to handle one-offs. I also wanted to imporove my Function skills, so I utilized a couple of Functions in the script. Eventually, I'll update the script to automate the process based on monthly reports I receive which contain the active Department IDs and Business Units, as well as another report that includes active Facility IDs, but I needed something more immediate that the admins could use now.

The plan:
• Limit admin input to reduce errors in naming and configuring DDGs
• Give options for the 3 types of DDGs so that as many attributes and configuration items as possible are automatically populated
• Ensure no Building DDGs are created with "Agency2" names or configuration, as only "Agency1" uses Building DDGs.

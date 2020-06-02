$my_account = whoami
$acl = Get-Acl key_pair.pem

# remove inheritance
$acl.SetAccessRuleProtection($true,$false)

# remove all privileges
$acl.Access | ForEach-Object {
   $identity = $_.IdentityReference
   $privs = $_.FileSystemRights
   $access_type = $_.AccessControlType
   $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $privs, $access_type)
   $acl.RemoveAccessRule($AccessRule)
}

# add full control for current user only
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($my_account, "FullControl", "Allow")
$acl.SetAccessRule($AccessRule)

$acl | Set-Acl key_pair.pem

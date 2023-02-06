##################################################################
##################################################################
####################     github.com/TomMedn/    ##################
#Find Local Administrators in your domain by running the Function#
#Edit line 20 if used elsewhere than in french locale domain     #
##################################################################
##################################################################
Function Get-LocalAdmins {
  Param(
          [Parameter(Mandatory)]
          [string[]]$FilePath,
          [string]$OutPath
          )
         $Computernateurs = Get-Content -Path $FilePath
         $list = new-object -TypeName System.Collections.ArrayList
      foreach ($Computer in $Computernateurs) {
          if (Test-Connection -ComputerName $Computer -Quiet -count 1)
                                 {
                                       Write-Verbose -Message ('Ping reussi sur {0}, verification des comptes admins...' -f $Computer) -Verbose
                                          $admins = Get-WmiObject -Class win32_groupuser -ComputerName $Computer | Where-Object {$_.groupcomponent -like '*"Administrateur"' -or '*"Administrator"'} 
                                  {
                                            $obj = New-Object -TypeName PSObject -Property @{
                                              Computer = $Computer
                                              AdminAcc = $null
                                          foreach ($admin in $admins) {
                                              $null = $admin.partcomponent -match '.+Domain\=(.+)\,Name\=(.+)$' 
                                              $null = $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
                                              $obj.AdminAcc += $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
                                          }
                                          $null = $list.add($obj) )
          else {
              Write-Verbose -Message ('Can''t reach {0}' -f $Computer) -Verbose
              $echec = ('{0}' -f $Computer)
              $echec | Out-file "$OutPath\Failed.txt" -Append
$list | Export-Csv "$OutPath\LocalAdmins.csv"| Format-Table -AutoSize -Wrap  
$list | Out-File "$OutPath\LocalAdmins.txt"| Format-Table -AutoSize -Wrap 
}
} 
Get-LocalAdmins -FilePath ".csv" -OutPath "C:\Users\you\Desktop\Get-LocalAdmins" 


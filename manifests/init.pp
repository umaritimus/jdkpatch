# @summary Install JDK Patch
#
# Install JDK Patch
#
# @example
#   include jdkpatch
class jdkpatch (
  Optional[Hash[Integer,String]] $jdk_patches = lookup('jdk_patches',undef,undef,undef)
){
  if ($facts['operatingsystem'] == 'windows') {
    if (!empty($jdk_patches)) {
      debug ("Running on Windows OS with the following jdk_patches set: ${jdk_patches}")
      $jdk_patches.each | Integer $patch_index, String $patch_path | {
        if (!empty($patch_path)) {
          $jdk_path = regsubst("${lookup('jdk_location')}", '(/|\\\\)', '\\', 'G')
          $pkgtemp = regsubst("${jdk_path}-${patch_index}", '(/|\\\\)', '\\', 'G')

          exec { "Check ${patch_path}" :
            command   => Sensitive(@("EOT")),
                Test-Path -Path ${regsubst("\'${patch_path}\'", '(/|\\\\)', '\\', 'G')} -ErrorAction Stop
              |-EOT
            provider  => powershell,
            logoutput => true,
          }

          exec { "Expand ${patch_path} to ${pkgtemp}" :
            command   => Sensitive(@("EOT")),
                Try {
                  Expand-Archive `
                    -Path ${regsubst("\'${patch_path}\'", '(/|\\\\)', '\\', 'G')} `
                    -DestinationPath ${regsubst("\'${pkgtemp}\'", '(/|\\\\)', '\\', 'G')} `
                    -Force `
                    -ErrorAction Stop
                } Catch {
                  Exit 1
                }
              |-EOT
            provider  => powershell,
            logoutput => true,
            require   => [ Exec["Check ${patch_path}"] ],
          }

          exec { "Deploy ${pkgtemp}" :
            command   => Sensitive(@("EOT")),
                Try {
                  Set-Location -Path ${pkgtemp}
                  Start-Process `
                    -FilePath "$((Resolve-Path -Path 'jdk*_windows-x64_bin.exe').Path)" `
                    -ArgumentList @( `
                      '/s', `
                      'INSTALLDIR="${jdk_path}"' `
                    ) `
                    -Wait `
                    -ErrorAction Stop `
                    -NoNewWindow | Out-Null
                } Catch {
                  Exit 1
                }
              |-EOT
            provider  => powershell,
            logoutput => true,
            require   => [ Exec["Expand ${patch_path} to ${pkgtemp}"] ],
          }

          exec { "Delete ${pkgtemp} Directory" :
            command   =>  Sensitive(@("EOT")),
                New-Item -Path ${regsubst("\'${jdk_path}-empty\'", '(/|\\\\)', '\\', 'G')} -Type Directory -Force

                Start-Process `
                  -FilePath "C:\\windows\\system32\\Robocopy.exe" `
                  -ArgumentList @( `
                    ${regsubst("\'${jdk_path}-empty\'", '(/|\\\\)', '\\', 'G')}, `
                    ${regsubst("\'${pkgtemp}\'" ,'/', '\\\\', 'G')}, `
                    "/E /PURGE /NOCOPY /MOVE /NFL /NDL /NJH /NJS > nul" `
                  ) `
                  -Wait `
                  -NoNewWindow | Out-Null

                Get-Item -Path ${regsubst("\'${pkgtemp}\'" ,'/', '\\\\', 'G')} -ErrorAction SilentlyContinue `
                | Remove-Item -Force -Recurse
              |-EOT
            provider  => powershell,
            logoutput => true,
            require   => [ Exec["Deploy ${pkgtemp}"] ],
          }

        }
      }

    }
  }
}

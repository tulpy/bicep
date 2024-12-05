
#Documentation: https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/Cmdlets/Invoke-ScriptAnalyzer.md#-settings
@{
  Severity            = @(
    'Error'
  )
  IncludeDefaultRules = ${true}
  ExcludeRules        = @(
    'PSAvoidUsingWriteHost'
    'PSAvoidTrailingWhitespace'
    'PSAvoidUsingConvertToSecureStringWithPlainText'
  )
}

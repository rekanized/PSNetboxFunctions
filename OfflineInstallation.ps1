$PSModulePath = "$HOME\Documents\WindowsPowerShell\Modules"
$Files = Get-ChildItem -Path ".\" -Include ("*.psm1","*.psd1") -recurse
$ModuleName = "PSNetboxFunctions"
$NewModulePath = $PSModulePath+"\"+$ModuleName
if (!(Test-Path -Path "$PSModulePath")){
    New-Item -Path $NewModulePath -ItemType Directory -Force
}
$Files | Copy-Item -Destination $NewModulePath -Force -Confirm:$false
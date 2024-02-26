#
# Module manifest for module 'PSNetboxFunctions'
#
# Generated by: rekan
#
# Generated on: 2024-01-21
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'PSNetboxFunctions'

    # Version number of this module.
    ModuleVersion = '1.2.6'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = 'be42d4cf-f289-41f5-9c2b-790761da0a24'

    # Author of this module
    Author = 'rekan'

    # Company or vendor of this module
    CompanyName = 'MangesBasementIT'

    # Copyright statement for this module
    Copyright = 'Copy all you want'

    # Description of the functionality provided by this module
    Description = 'Connect to Netbox API with Token and manage its resources.'

    # Minimum version of the Windows PowerShell engine required by this module
    # PowerShellVersion = ''

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        "Get-NetboxObjects",
        "Find-NetboxConnection",
        "Connect-NetboxAPI",
        "New-NetboxTenant",
        "New-NetboxSite",
        "Remove-NetboxObject",
        "ConvertTo-ValidSlug",
        "Update-NetboxTenant"
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Required modules
    RequiredModules = @(
        @{
            ModuleName = "PSLoggingFunctions"
            RequiredVersion = "1.0.4"
            GUID = "23f92642-4216-4889-84c7-8bd1352e2a0b"
        },
        @{
            ModuleName = "PSHelpFunctions"
            RequiredVersion = "1.0.9"
            GUID = "772922b2-b239-49fd-b8fa-b9f60481d6b8"
        }
    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Netbox','API')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/rakelord/PSNetboxFunctions'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}


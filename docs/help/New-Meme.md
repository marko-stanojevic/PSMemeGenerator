---
document type: cmdlet
external help file: PSMemeGenerator-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSMemeGenerator
ms.date: 02/24/2026
PlatyPS schema version: 2024-05-01
title: New-Meme
---

# New-Meme

## SYNOPSIS

Creates a new meme by applying text to an image template.

## SYNTAX

### ByName (Default)

```
New-Meme -Name <string> [-OutputPath <string>] [-TopText <string>] [-BottomText <string>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### ById

```
New-Meme -Id <string> [-OutputPath <string>] [-TopText <string>] [-BottomText <string>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### ByUrl

```
New-Meme -Url <string> [-OutputPath <string>] [-TopText <string>] [-BottomText <string>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Downloads a meme template from a URL and applies top and bottom text using System.Drawing.
Requires Windows OS due to System.Drawing dependencies in modern .NET.

## EXAMPLES

### EXAMPLE 1

New-Meme -Name "Drake" -TopText "WHEN YOU WRITE" -BottomText "A POWERSHELL MODULE" -OutputPath ".\meme.jpg"
Creates a meme using the first template matching "Drake" and saves it to meme.jpg.

### EXAMPLE 2

New-Meme -Id "181913649" -TopText "WHEN YOU WRITE" -BottomText "A POWERSHELL MODULE" -OutputPath ".\meme.jpg"
Creates a meme using the template with ID "181913649" and saves it to meme.jpg.

## PARAMETERS

### -BottomText

The text to display at the bottom of the meme.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Id

The ID of the source meme template from Imgflip.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ById
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Name

The name of the source meme template from Imgflip.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByName
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputPath

The path where the generated meme image will be saved.
Defaults to the current user's Desktop.
The filename is derived from BottomText (or TopText
if BottomText is not provided), with spaces replaced by underscores (e.g.
meme_like_a_boss.jpg).
Falls back to meme.jpg if neither text is provided.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TopText

The text to display at the top of the meme.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Url

The URL of the source meme image.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByUrl
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

{{ Fill in the Description }}

## OUTPUTS

### System.IO.FileInfo

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}


---
document type: cmdlet
external help file: PSMemeGenerator-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSMemeGenerator
ms.date: 02/23/2026
PlatyPS schema version: 2024-05-01
title: Get-MemeTemplate
---

# Get-MemeTemplate

## SYNOPSIS

Gets a list of popular meme templates from Imgflip.

## SYNTAX

### __AllParameterSets

```
Get-MemeTemplate [[-Name] <string>] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Retrieves the top 100 most popular meme templates from the Imgflip API.
Returns objects containing the meme ID, name, URL, width, and height.

## EXAMPLES

### EXAMPLE 1

Get-MemeTemplate
Returns all available meme templates.

### EXAMPLE 2

Get-MemeTemplate -Name 'Drake'
Finds meme templates with 'Drake' in the name.

## PARAMETERS

### -Name

{{ Fill Name Description }}

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
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

## OUTPUTS

### PSCustomObject

{{ Fill in the Description }}

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}


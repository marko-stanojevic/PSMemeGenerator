# PSMemeGenerator — Getting Started

## Overview

PSMemeGenerator is a PowerShell module that generates memes straight from the terminal. It fetches templates from the [Imgflip API](https://imgflip.com/api), overlays top and bottom text using `System.Drawing` (GDI+), and saves the result as a JPEG.

> **Requires Windows OS.** Text rendering depends on `System.Drawing`, which is only available on Windows.

---

## Prerequisites

- PowerShell 7.0+
- Windows OS

---

## Installation

```powershell
Install-Module -Name PSMemeGenerator -Scope CurrentUser
Import-Module PSMemeGenerator
```

Verify it loaded correctly:

```powershell
Get-Command -Module PSMemeGenerator
```

---

## Key Features

- Browse the top 100 meme templates from Imgflip with `Get-MemeTemplate`
- Filter templates by name using regex patterns
- Create memes by template name, ID, or direct URL with `New-Meme`
- Supports top and bottom text overlay
- Text is horizontally centered using precise GDI+ measurement
- Pipeline-friendly — compose commands naturally
- Outputs a `System.IO.FileInfo` object for further pipeline use

---

## Core Functions

### `Get-MemeTemplate`

Fetches the top 100 most popular meme templates from the Imgflip API.

| Parameter | Type   | Required | Description                          |
|-----------|--------|----------|--------------------------------------|
| `-Name`   | String | No       | Filter by name. Supports regex.      |

Returns objects with: `Id`, `Name`, `Url`, `Width`, `Height`, `BoxCount`.

### `New-Meme`

Downloads a meme template and overlays text onto it.

| Parameter      | Type   | Required | Description                                      |
|----------------|--------|----------|--------------------------------------------------|
| `-Name`        | String | Yes*     | Template name to look up (regex match on top 100)|
| `-Id`          | String | Yes*     | Exact Imgflip template ID                        |
| `-Url`         | String | Yes*     | Direct image URL                                 |
| `-TopText`     | String | No       | Text rendered at the top of the image            |
| `-BottomText`  | String | No       | Text rendered at the bottom of the image         |
| `-OutputPath`  | String | Yes      | File path to save the output JPEG                |

\* One of `-Name`, `-Id`, or `-Url` is required.

Returns a `System.IO.FileInfo` for the saved meme.

---

## Complete Workflow Example

```powershell
# 1. Find a template
Get-MemeTemplate -Name 'Drake Hotline Bling'

# 2. Create the meme
New-Meme -Id '181913649' `
         -TopText 'Reading the error message' `
         -BottomText 'Googling the error message' `
         -OutputPath '.\drake.jpg'

# 3. Open the result
Invoke-Item '.\drake.jpg'
```

---

## Pipeline Examples

#### Pipe a template directly into New-Meme

```powershell
Get-MemeTemplate -Name 'Two Buttons' |
    Select-Object -First 1 |
    New-Meme -TopText 'Fix the bug' -BottomText 'Close as by design' -OutputPath '.\buttons.jpg'
```

#### Generate a meme for every matching template

```powershell
Get-MemeTemplate -Name 'cat' | ForEach-Object {
    New-Meme -Id $_.Id `
             -TopText 'Monday morning' `
             -BottomText 'After the weekend deploy' `
             -OutputPath ".\meme_$($_.Id).jpg"
}
```

#### Chain with downstream commands

```powershell
New-Meme -Name 'Distracted Boyfriend' `
         -TopText 'The new shiny framework' `
         -BottomText 'The production codebase' `
         -OutputPath '.\meme.jpg' |
    Select-Object FullName, Length
```

---

## Error Handling

`New-Meme` throws if no matching template is found:

```powershell
try {
    New-Meme -Name 'NonExistentMeme' -TopText 'Hello' -OutputPath '.\out.jpg'
} catch {
    Write-Host "Failed: $_"
}
```

Use `-Verbose` for detailed diagnostic output:

```powershell
New-Meme -Id '181913649' -TopText 'Test' -OutputPath '.\out.jpg' -Verbose
```

Use `-WhatIf` to preview without writing a file:

```powershell
New-Meme -Id '181913649' -TopText 'Test' -OutputPath '.\out.jpg' -WhatIf
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `This function requires Windows OS` | Running on Linux/macOS | Use a Windows machine or Windows container |
| `Could not find a meme template matching Name ...` | Name not in top 100 | Try a broader or different search term |
| Text appears off-center | Old cached build loaded | Re-import with `Import-Module PSMemeGenerator -Force` |
| Output file is blank/corrupt | Disk permissions or invalid path | Ensure `-OutputPath` directory exists and is writable |

---

## Resources

- [Imgflip API](https://imgflip.com/api) — Template source
- [Module source](../src/) — Public and private functions
- [CONTRIBUTING.md](../CONTRIBUTING.md) — How to contribute

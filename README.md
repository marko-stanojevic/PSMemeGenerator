# PSMemeGenerator

A PowerShell-powered meme generator for engineers who prefer pipelines over Photoshop. Generate, customize, and automate memes straight from the terminal. Perfect for CI jokes, release sarcasm, and infrastructure humor. Because if the build breaks, at least the meme deploys successfully.

[![Build Status](https://img.shields.io/github/actions/workflow/status/marko-stanojevic/PSMemeGenerator/ci.yml?branch=main&logo=github&style=flat-square)](https://github.com/marko-stanojevic/PSMemeGenerator/actions/workflows/ci.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PSMemeGenerator.svg)](https://www.powershellgallery.com/packages/PSMemeGenerator)
[![Downloads](https://img.shields.io/powershellgallery/dt/PSMemeGenerator.svg)](https://www.powershellgallery.com/packages/PSMemeGenerator)
[![License](https://img.shields.io/github/license/marko-stanojevic/PSMemeGenerator)](LICENSE)

## About

PSMemeGenerator is a PowerShell module that generates memes straight from the terminal. It fetches templates from the [Imgflip API](https://imgflip.com/api), overlays top/bottom text using `System.Drawing`, and saves the result as a JPEG — no browser or image editor required.

## Why PSMemeGenerator?

PSMemeGenerator is designed for engineers who live in the terminal. It simplifies meme creation by integrating directly into PowerShell pipelines, so you can automate, script, and compose memes the same way you do everything else. Perfect for CI jokes, release notes, incident post-mortems, and general infrastructure sarcasm.

> **Note:** Requires **Windows OS** — text rendering depends on `System.Drawing` (GDI+).

## 🚀 Getting Started

### Prerequisites

**Required:**

- **PowerShell 7.0+**
- **Windows OS** (for `System.Drawing` / GDI+ support)

### Installation

Install the module from the PowerShell Gallery:

```powershell
Install-Module -Name PSMemeGenerator -Scope CurrentUser
```

### Usage

Import the module and use its commands:

```powershell
Import-Module PSMemeGenerator
Get-Command -Module PSMemeGenerator
```

#### Find a template

```powershell
Get-MemeTemplate -Name 'Distracted Boyfriend' 
```

#### Generate a meme for every matching template

```powershell
Get-MemeTemplate | ForEach-Object {
    New-Meme -Id $_.Id -TopText 'Pull requests' -BottomText 'Pushing directly to main' -OutputPath ".\drake_$($_.Id).jpg"
}
```

#### Quick one-liner with a known template name

```powershell
New-Meme -Name 'Two Buttons' -TopText 'Fix the bug' -BottomText 'Close the ticket as "by design"' -OutputPath '.\buttons.jpg'
```

## 📘 Documentation

Comprehensive documentation is available in the [`docs/`](docs/) directory:

- 🚀 **[Getting Started](docs/getting-started.md)** - Practical examples and usage scenarios
- 📘 **[Module Help](docs/)** - Help files for cmdlets and functions

## 🤝 Contributing

Contributions are welcome! Whether it’s bug fixes, improvements, or ideas for new features, your input helps make this template better for everyone. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on:

- Pull request workflow
- Code style and conventions
- Testing and quality requirements

## ⭐ Support This Project

If this template saves you time or helps your projects succeed, consider supporting it:

- ⭐ Star the repository to show your support
- 🔁 Share it with other PowerShell developers
- 💬 Provide feedback via issues or discussions
- ❤️ Sponsor ongoing development via GitHub Sponsors

---

Built with ❤️ by [marko-stanojevic](https://github.com/marko-stanojevic)

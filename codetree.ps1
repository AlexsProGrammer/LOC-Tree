[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [string]$Path = ".",

    [Parameter(Position = 1)]
    [int]$MinLines = 200,

    [switch]$IncludeHidden
)

function Get-LineCount([string]$FilePath) {
    try {
        $count = 0
        $reader = [System.IO.File]::OpenText($FilePath)
        while ($reader.ReadLine() -ne $null) { $count++ }
        $reader.Close()
        return $count
    } catch {
        return 0
    }
}

function Build-Node([System.IO.DirectoryInfo]$Dir) {
    $matchingFiles = @()
    $subNodes = @()

    $fileList = Get-ChildItem -LiteralPath $Dir.FullName -File -Force:$IncludeHidden.IsPresent -ErrorAction SilentlyContinue
    foreach ($file in $fileList) {
        if (-not $IncludeHidden -and $file.Name.StartsWith('.')) { continue }
        $lines = Get-LineCount -FilePath $file.FullName
        if ($lines -gt $MinLines) {
            $matchingFiles += [PSCustomObject]@{
                Name  = $file.Name
                Lines = $lines
            }
        }
    }

    $dirList = Get-ChildItem -LiteralPath $Dir.FullName -Directory -Force:$IncludeHidden.IsPresent -ErrorAction SilentlyContinue
    foreach ($subDir in $dirList) {
        if (-not $IncludeHidden -and $subDir.Name.StartsWith('.')) { continue }
        $childNode = Build-Node -Dir $subDir
        if ($childNode.Files.Count -gt 0 -or $childNode.SubDirs.Count -gt 0) {
            $subNodes += $childNode
        }
    }

    return [PSCustomObject]@{
        Name    = $Dir.Name
        Files   = $matchingFiles
        SubDirs = $subNodes
    }
}

function Print-Tree($node, [string]$prefix = "", [bool]$isRoot = $true) {
    if ($isRoot) {
        Write-Host "📁 $($node.Name)\" -ForegroundColor Cyan
    }

    $entries = @()
    foreach ($d in $node.SubDirs) { $entries += @{ Type = 'Dir'; Item = $d } }
    foreach ($f in $node.Files)   { $entries += @{ Type = 'File'; Item = $f } }

    for ($i = 0; $i -lt $entries.Count; $i++) {
        $isLast = ($i -eq ($entries.Count - 1))
        $connector = if ($isLast) { "└── " } else { "├── " }
        $subPrefix = if ($isLast) { "    " } else { "│   " }

        if ($entries[$i].Type -eq 'Dir') {
            Write-Host "$prefix$connector📁 $($entries[$i].Item.Name)\" -ForegroundColor Cyan
            Print-Tree $entries[$i].Item ($prefix + $subPrefix) $false
        } else {
            $f = $entries[$i].Item
            Write-Host "$prefix$connector📄 $($f.Name) " -NoNewline -ForegroundColor Green
            Write-Host "($($f.Lines) lines)" -ForegroundColor Yellow
        }
    }
}

$target = Get-Item -LiteralPath $Path -ErrorAction Stop
if (-not $target.PSIsContainer) {
    Write-Error "'$Path' is not a valid directory."
    exit 1
}

Write-Host "Scanning '$($target.FullName)' for files with > $MinLines lines...`n" -ForegroundColor Gray
$tree = Build-Node -Dir $target

if ($tree.Files.Count -eq 0 -and $tree.SubDirs.Count -eq 0) {
    Write-Host "No files found exceeding $MinLines lines." -ForegroundColor DarkYellow
} else {
    Print-Tree $tree
}

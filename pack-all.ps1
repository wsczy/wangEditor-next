# 打包所有 packages 下的子包并重命名 tgz 文件
# 适用于 Windows PowerShell

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$packagesDir = Join-Path $root 'packages'
$targetDir = Join-Path $root 'all-packed-tgz'

if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

Get-ChildItem -Path $packagesDir -Directory | ForEach-Object {
    $pkgPath = $_.FullName
    $pkgJson = Join-Path $pkgPath 'package.json'
    if (Test-Path $pkgJson) {
        Write-Host "Packing $($_.Name) ..."
        Push-Location $pkgPath
        yarn pack | Out-Null
        $tgz = Get-ChildItem -Filter '*.tgz' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($tgz) {
            $newName = "wangeditor-next-$($_.Name).tgz"
            $dest = Join-Path $targetDir $newName
            Move-Item $tgz.FullName $dest -Force
            Write-Host "Packed and moved: $newName"
        }
        Pop-Location
    }
}
Write-Host ""


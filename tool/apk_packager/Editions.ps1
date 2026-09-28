function Get-InfiboEditions {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Edition configuration not found: $Path"
    }
    $parsed = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    $items = @($parsed)
    if ($items.Count -eq 0) { throw 'Edition configuration is empty.' }

    $seen = @{}
    foreach ($item in $items) {
        foreach ($field in @('id', 'label', 'flavor', 'target', 'apiBaseUrl')) {
            $property = $item.PSObject.Properties[$field]
            if (-not $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
                throw "Edition configuration has a missing $field value."
            }
        }
        $id = [string]$item.id
        if ($id -cnotmatch '^[a-z][a-z0-9_]*$') {
            throw "Edition id must use lowercase letters, numbers or underscores: $id"
        }
        if ($seen.ContainsKey($id)) { throw "Duplicate edition id: $id" }
        $seen[$id] = $true
    }
    return $items
}

# Gera um ID no formato macMachineId
function New-MacMachineId {
    $template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    $result = ""
    $random = [Random]::new()
    
    foreach ($char in $template.ToCharArray()) {
        if ($char -eq 'x' -or $char -eq 'y') {
            $r = $random.Next(16)
            $v = if ($char -eq "x") { $r } else { ($r -band 0x3) -bor 0x8 }
            $result += $v.ToString("x")
        } else {
            $result += $char
        }
    }
    return $result
}

# Gera um ID aleatório de 64 bits
function New-RandomId {
    $uuid1 = [guid]::NewGuid().ToString("N")
    $uuid2 = [guid]::NewGuid().ToString("N")
    return $uuid1 + $uuid2
}

# Aguarda o processo Cursor encerrar
$cursorProcesses = Get-Process "cursor" -ErrorAction SilentlyContinue
if ($cursorProcesses) {
    Write-Host "Cursor está em execução. Por favor, feche o Cursor para continuar..."
    Write-Host "Aguardando o processo Cursor encerrar..."
    
    while ($true) {
        $cursorProcesses = Get-Process "cursor" -ErrorAction SilentlyContinue
        if (-not $cursorProcesses) {
            Write-Host "Cursor foi fechado, continuando..."
            break
        }
        Start-Sleep -Seconds 1
    }
}

# Faz backup do MachineGuid
$backupDir = Join-Path $HOME "MachineGuid_Backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}

$currentValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name MachineGuid
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "MachineGuid_$timestamp.txt"
$counter = 0

while (Test-Path $backupFile) {
    $counter++
    $backupFile = Join-Path $backupDir "MachineGuid_${timestamp}_$counter.txt"
}

$currentValue.MachineGuid | Out-File $backupFile

# Constrói o caminho do storage.json usando variáveis de ambiente
$storageJsonPath = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
$newMachineId = New-RandomId
$newMacMachineId = New-MacMachineId
$newDevDeviceId = [guid]::NewGuid().ToString()
$newSqmId = "{$([guid]::NewGuid().ToString().ToUpper())}"

if (Test-Path $storageJsonPath) {
    # Salva os atributos originais do arquivo
    $originalAttributes = (Get-ItemProperty $storageJsonPath).Attributes
    
    # Remove o atributo somente leitura
    Set-ItemProperty $storageJsonPath -Name IsReadOnly -Value $false
    
    # Atualiza o conteúdo do arquivo
    $jsonContent = Get-Content $storageJsonPath -Raw -Encoding UTF8
    $data = $jsonContent | ConvertFrom-Json
    
    # Verifica e atualiza ou adiciona propriedades
    $properties = @{
        "telemetry.machineId" = $newMachineId
        "telemetry.macMachineId" = $newMacMachineId
        "telemetry.devDeviceId" = $newDevDeviceId
        "telemetry.sqmId" = $newSqmId
    }

    foreach ($prop in $properties.Keys) {
        if (-not (Get-Member -InputObject $data -Name $prop -MemberType Properties)) {
            $data | Add-Member -NotePropertyName $prop -NotePropertyValue $properties[$prop]
        } else {
            $data.$prop = $properties[$prop]
        }
    }
    
    $newJson = $data | ConvertTo-Json -Depth 100
    
    # Salva o arquivo usando StreamWriter, garantindo UTF-8 sem BOM e quebras de linha LF
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($storageJsonPath, $newJson.Replace("`r`n", "`n"), $utf8NoBom)
    
    # Restaura os atributos originais do arquivo
    Set-ItemProperty $storageJsonPath -Name Attributes -Value $originalAttributes
}

# Atualiza o MachineGuid no registro
$newMachineGuid = [guid]::NewGuid().ToString()
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -Value $newMachineGuid

Write-Host "Todos os IDs foram atualizados com sucesso:"
Write-Host "Arquivo de backup criado em: $backupFile"
Write-Host "Novo MachineGuid: $newMachineGuid"
Write-Host "Novo telemetry.machineId: $newMachineId"
Write-Host "Novo telemetry.macMachineId: $newMacMachineId"
Write-Host "Novo telemetry.devDeviceId: $newDevDeviceId"
Write-Host "Novo telemetry.sqmId: $newSqmId"

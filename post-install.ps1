#Set-ExecutionPolicy RemoteSigned
#Set-ExecutionPolicy Default

# Überprüfen, ob das Skript mit Administratorrechten ausgeführt wird
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Dieses Skript erfordert Administratorrechte. Bitte führen Sie es als Administrator aus."
    Exit
}

# Überprüfen, ob Chocolatey installiert ist
$chocoInstalled = Get-Command -Name choco -ErrorAction SilentlyContinue

if ($chocoInstalled) {
    Write-Host "Chocolatey ist bereits installiert."
} else {
    Write-Host "Chocolatey ist nicht installiert. Die Installation wird gestartet..."

    # Führen Sie die Chocolatey-Installationsbefehle aus
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # Überprüfen, ob die Installation erfolgreich war
    $chocoInstalled = Get-Command -Name choco -ErrorAction SilentlyContinue

    if ($chocoInstalled) {
        Write-Host "Chocolatey wurde erfolgreich installiert."
    } else {
        Write-Host "Fehler bei der Installation von Chocolatey."
    }
}

# Kategorisierte Liste der Programme
$programCategories = @{
    "Web Browser Programs" = @(
        @{ Name = "Firefox"; DisplayName = "Mozilla Firefox"; Description = "Schneller, sicherer Open-Source-Webbrowser" },
        @{ Name = "Vivaldi"; DisplayName = "Vivaldi"; Description = "Stark anpassbarer Webbrowser" }
    );
    "Graphics Programs" = @(
        @{ Name = "GIMP"; DisplayName = "GIMP"; Description = "Ein leistungsstarkes Bildbearbeitungsprogramm" },
        @{ Name = "Inkscape"; DisplayName = "Inkscape"; Description = "Kostenlose Vektorgrafiksoftware für Illustrationen und Logos" },
        @{ Name = "Paint.NET"; DisplayName = "Paint.NET"; Description = "Benutzerfreundliche Bildbearbeitung für Windows" },
        @{ Name = "Greenshot"; DisplayName = "Greenshot"; Description = "Screenshot-Tool mit Anmerkungsfunktion" }
        { Name = "irfanview irfanview-languages irfanviewplugins"; DisplayName = "IrfanView"; Description = "Schneller Bildbetrachter und Konverter" }
        # Weitere Grafikprogramme mit Anzeigenamen und Beschreibung hier hinzufügen
    );
    "Office Programs" = @(
        @{ Name = "AdobeReader"; DisplayName = "Adobe Reader"; Description = "Kostenloser PDF-Betrachter von Adobe" },
        @{ Name = "FoxitReader"; DisplayName = "Foxit Reader"; Description = "Schneller und benutzerfreundlicher PDF-Betrachter" }
        @{ Name = "libreoffice-fresh"; DisplayName = "LibreOffice Fresh"; Description = "aktuelle und regelmäßig aktualisierte Version der kostenlosen LibreOffice-Office-Suite" },
        @{ Name = "onlyoffice"; DisplayName = "OnlyOffice"; Description = "Office-Suite für Teamarbeit und Echtzeit-Dokumentenbearbeitung" },
        @{ Name = "naps2.install"; DisplayName = "NAPS2"; Description = "Dokumentenerfassung und PDF-Erstellung." }
        # Weitere Büroprogramme mit Anzeigenamen und Beschreibung hier hinzufügen
    );
    "Development Programs" = @(
        @{ Name = "python"; DisplayName = "Python"; Description = "Eine Programmiersprache." },
        @{ Name = "vs code"; DisplayName = "Visual Studio Code"; Description = "Ein leichtgewichtiger Code-Editor von Microsoft." },
        @{ Name = "git"; DisplayName = "Git"; Description = "Ein Versionskontrollsystem." },
        @{ Name = "pycharm-community"; DisplayName = "PyCharm Community Edition"; Description = "Eine Python-IDE." },
        @{ Name = "postman"; DisplayName = "Postman"; Description = "Ein Tool für API-Tests und Entwicklung." },
        @{ Name = "notepadplusplus.install"; DisplayName = "Notepad++"; Description = "Mächtiger Texteditor mit erweiterten Funktionen." }
        # Weitere Entwicklungswerkzeuge mit Anzeigenamen und Beschreibung hier hinzufügen
    );
    "Communication Programs" = @(
        @{ Name = "microsoft-teams.install"; DisplayName = "MS Teams"; Description = "Plattform für Teamkommunikation und Zusammenarbeit" },
        #@{ Name = "zoom"; DisplayName = "Zoom"; Description = "Eine Videokonferenzsoftware" },
        @{ Name = "telegram"; DisplayName = "Telegram"; Description = "Eine Instant-Messaging-App" },
        @{ Name = "signal"; DisplayName = "Signal"; Description = "Eine sichere Messaging-App" },
        @{ Name = "betterbird"; DisplayName = "Betterbird"; Description = "verbesserter Thunderbird E-Mail-Client" },
        @{ Name = "thunderbird"; DisplayName = "Mozilla Thunderbird"; Description = "E-Mail-Client mit umfassenden Funktionen für die Verwaltung von E-Mails, Kontakten und Kalendern" }
        # Weitere Kommunikationsprogramme mit Anzeigenamen und Beschreibung hier hinzufügen
    );
    "Multimedia Programs" = @(
        @{ Name = "vlc"; DisplayName = "VLC media player"; Description = "Ein vielseitiger Multimedia-Player" },
        @{ Name = "spotify"; DisplayName = "Spotify"; Description = "Eine Musik-Streaming-Plattform." },
        @{ Name = "audacity"; DisplayName = "Audacity"; Description = "Eine freie, quelloffene Audio-Editor-Software" },
        @{ Name = "itunes"; DisplayName = "iTunes"; Description = "Apples Multimedia-Software" },
        @{ Name = "mp3tag"; DisplayName = "mp3Tag"; Description = "Bearbeitung von Musik-Metadaten in MP3-Dateien" },
        @{ Name = "makemkv"; DisplayName = "MakeMKV"; Description = "Konvertiert DVDs und Blu-rays in das MKV-Format" },
        @{ Name = "handbrake.install"; DisplayName = "HandBrake"; Description = "Konvertiert Videos in verschiedene Dateiformate" },
        @{ Name = "obs"; DisplayName = "OBS (Open Broadcaster Software)"; Description = "Aufnehmen und Streamen von Audio- und Videoinhalten." }
        # Weitere Multimedia-Programme mit Anzeigenamen und Beschreibung hier hinzufügen
    );
    "System Utilities" = @(
        @{ Name = "ventoy"; DisplayName = "Ventoy"; Description = "Erstellung von Multi-bootfähigen USB-Laufwerken" },
        @{ Name = "rufus"; DisplayName = "Rufus"; Description = "Erstellung von bootfähigen USB-Laufwerken" },
        @{ Name = "etcher"; DisplayName = "Balena Etcher"; Description = "Erstellung von bootfähigen USB-Laufwerken" }
        @{ Name = "teamviewer"; DisplayName = "TeamViewer"; Description = "Eine Software für Fernzugriff und Fernwartung" },
        @{ Name = "ccleaner"; DisplayName = "CCleaner"; Description = "Ein Tool zur Systembereinigung und -optimierung" },
        @{ Name = "7zip"; DisplayName = "7zip"; Description = "Open-Source-Komprimierungsprogramm für Dateien" },
        @{ Name = "winrar"; DisplayName = "WinRAR"; Description = "Kommerzielles Archivierungsprogramm für Windows" },
        @{ Name = "treesizefree"; DisplayName = "TreeSizeFree"; Description = "Analyse der Speichernutzung" },
        @{ Name = "advanced-ip-scanner"; DisplayName = "Advanced IP Scanner"; Description = "Tool zur Erkennung von Geräten und IP-Adressen in einem lokalen Netzwerk" },
        @{ Name = "cpu-z"; DisplayName = "Cpu-Z"; Description = "Hardwareinformationen über CPU" },
        @{ Name = "gpu-z"; DisplayName = "Gpu-Z"; Description = "Hardwareinformationen über GPU" },
        @{ Name = "OpenHardwareMonitor"; DisplayName = "Open Hardware Monitor"; Description = "Detaillierte Hardwareinformationen über System" },
        @{ Name = "furmark"; DisplayName = "FurMark"; Description = "Überprüfung und Benchmarking von Grafikkartenleistung." },
        @{ Name = "steam"; DisplayName = "Steam"; Description = "Spiele Plattform" }
        
        # Weitere Systemdienstprogramme mit Anzeigenamen und Beschreibung hier hinzufügen
    );
}

# Funktion zur Auswahl von Programmen
function Select-Programs {
    param (
        [Hashtable]$categories
    )

    $selectedPrograms = @()

    foreach ($category in $categories.Keys) {
        $categoryPrograms = $categories[$category]
        Write-Host "Category: $category"
        
        foreach ($programInfo in $categoryPrograms) {
            $programName = $programInfo.Name
            $programDisplayName = $programInfo.DisplayName
            $programDescription = $programInfo.Description

            # Anzeigenamen und Beschreibung anzeigen
            Write-Host "Install $programDisplayName ($programDescription)"

            $choice = Read-Host "Install $programDisplayName? (y/n)"
            if ($choice -eq "y") {
                $selectedPrograms += $programName
            }
        }
    }

    return $selectedPrograms
}

# Benutzer wählt Programme aus
$selectedPrograms = Select-Programs -categories $programCategories

# Installationsbefehl erstellen und ausführen
if ($selectedPrograms.Count -gt 0) {
    $installCommand = "choco install -y " + ($selectedPrograms -join " ")
    Write-Host "Installing selected programs..."
    Invoke-Expression $installCommand
} else {
    Write-Host "No programs selected for installation."
}

$Manufacturer = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer

if ($Manufacturer -like "*Dell*") {
    Write-Host "Das System ist ein Dell-System."
    $installDellCommandUpdate = Read-Host "Möchten Sie Dell Command Update installieren? (y/n)"
    if ($installDellCommandUpdate -eq "y") {
        Write-Host "Dell Command Update wird installiert..."
        choco install -y -q dellcommandupdate
    } else {
        Write-Host "Dell Command Update wird nicht installiert."
    }
} else {
    Write-Host "Das System ist kein Dell-System."
}

$gpuInfo = Get-WmiObject -Class Win32_VideoController | Select-Object -ExpandProperty Description

if ($gpuInfo -like "*NVIDIA*") {
    Write-Host "Eine NVIDIA-Grafikkarte ist im System installiert."
    $installGameReadyDriver = Read-Host "Möchten Sie den GeForce Game Ready Driver installieren? (y/n)"
    if ($installGameReadyDriver -eq "y") {
        Write-Host "Der GeForce Game Ready Driver wird installiert..."
        choco install -y geforce-game-ready-driver
    } else {
        Write-Host "Der GeForce Game Ready Driver wird nicht installiert."
    }
} else {
    Write-Host "Es ist keine NVIDIA-Grafikkarte im System installiert."
}

$diskInfo = Get-PhysicalDisk | Where-Object { $_.FriendlyName -like "*Samsung*" }

if ($diskInfo) {
    Write-Host "Eine Samsung SSD wurde im Friendly Name erkannt."
    $installSamsungMagician = Read-Host "Möchten Sie Samsung Magician installieren? (y/n)"
    if ($installSamsungMagician -eq "y") {
        Write-Host "Samsung Magician wird installiert..."
        choco install -y samsung-magician
    } else {
        Write-Host "Samsung Magician wird nicht installiert."
    }
} else {
    Write-Host "Es wurde keine Samsung SSD im Friendly Name erkannt."
}

Write-Host "All done!"
Pause
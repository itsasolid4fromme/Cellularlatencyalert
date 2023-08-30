# Defines target IP address, .wav, and email settings
$targetIP = "8.8.8.8"
$emailTo = "To Email"
$emailFrom = "From Email"
$smtpServer = "SMTP Server"
$smtpPort = Port Number
$smtpUsername = "Username"
$smtpPassword = "hackmeharderdaddy"
$securePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
$smtpCreds = New-Object System.Management.Automation.PSCredential ($smtpUsername, $securePassword)
$soundFilePath = "C:\FUCK.wav"

# Function to play a sound
function Invoke-Sound {

# Create a SoundPlayer object
$player = New-Object System.Media.SoundPlayer

# Set the sound file location
$player.SoundLocation = $soundFilePath

# Play the sound
$player.Play()
}

# Function to send an email
function Send-Email {
    param (
        [string]$to,
        [string]$subject,
        [string]$body
    )

    $securePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
    $smtpCreds = New-Object System.Management.Automation.PSCredential ($smtpUsername, $securePassword)

    $message = @{
        Subject = $subject
        Body = $body
        From = $emailFrom
        To = $to
        SmtpServer = $smtpServer
        Port = $smtpPort
        Credential = $smtpCreds
        UseSsl = $true
    }

    Send-MailMessage @message
}

# Function to log verbose information
function update-Verbose {
    param (
        [string]$message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $message"
}

# Initialize variables for tracking consecutive high response times
$consecutiveHighResponseTimes = 0

# Main loop to continuously check ping response
while ($true) {
    $pingResult = Test-Connection -ComputerName $targetIP -Count 1 -ErrorAction SilentlyContinue

    if ($pingResult -ne $DebugPreference) {
        $responseTime = $pingResult.ResponseTime

        if ($responseTime -ge 250) {
            $consecutiveHighResponseTimes++

            if ($consecutiveHighResponseTimes -ge 5) {
                $message = "Ping to $targetIP exceeded 250ms for 10 consecutive replies, fix your shit. Response time: ${responseTime}ms"
                Send-Email -to $emailTo -subject "The Invisagig is fucked" -body $message
                Write-Host "ALERT: $message" -ForegroundColor Red
                Invoke-Sound -soundFilePath $soundFilePath
                $consecutiveHighResponseTimes = 0  # Reset counter
            }
        } else {
            $consecutiveHighResponseTimes = 0  # Reset counter
        }

        Update-Verbose "Ping to the internet response time = ${responseTime}ms"
    } else {
        $consecutiveHighResponseTimes = 0  # Reset counter
        Log-Verbose "Ping to $targetIP No reply received"
    }

    Start-Sleep -Seconds 1  
}

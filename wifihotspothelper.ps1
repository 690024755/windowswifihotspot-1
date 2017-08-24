$currentPrinciple = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent();
$administratorRole = [Security.Principal.WindowsBuiltInRole]::Administrator;
if(-not $currentPrinciple.IsInRole($administratorRole))
{
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments
}
else
{
  function error($msg)
  {
    Write-Host $msg
    Write-Host "Press ENTER to exit...";
    Read-Host;
    exit 1;
  }

  $ssid = "";
  $psk = "";
  while($ssid.length -le 0)
  {
    Write-Host "Please enter a non-empty SSID (the hotspot name):";
    $ssid = Read-Host;
    $ssid = $ssid.Trim();
  }

  while($psk.length -lt 8)
  {
    Write-Host "Please enter a PSK with at least 8 characters in it (the hotspot password):";
    $psk = Read-Host;
  }

  Clear-Host;

  # Create the hotspot.
  netsh wlan set hostednetwork mode=allow ssid="$ssid" key="$psk";
  if(-Not $?)
  {
    error "Could not set up hosted network :-(";
  }

  # Start the hotspot.
  netsh wlan start hostednetwork;
  if(-not $?)
  {
    error "Could not start hosted network :-(";
  }

  netsh wlan show hostednetwork;

  Write-Host
  Write-Host

  Write-Host "Your SSID (hotspot name) is:";
  Write-Host $ssid;
  Write-Host
  Write-Host "Your PSK (hotspot password) is:";
  Write-Host $psk;
  Write-Host
  Write-Host "You can now try to connect.";
  Write-Host
  Write-Host "===========================";
  Write-Host
  Write-Host "Press ENTER to shut down your hotspot!";
  Read-Host
  netsh wlan stop hostednetwork
  if(-not $?)
  {
    error "Hosted network could not be shut down. It will be killed next time you shut down your PC."
  }
  Write-Host
  Write-Host "===========================";
  Write-Host
  Write-Host "Press ENTER to exit...";
  Read-Host
  exit 0
}
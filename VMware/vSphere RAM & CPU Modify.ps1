### MUST RUN IN ISE x86!??? ###

$vCenter = "mag1vcenter.mktalliance.com"
$credential = Import-Clixml -Path "$PSScriptRoot\vsphere.cred"

param(
    [parameter(Mandatory = $false)]
    [string[]]$vCenter,
    [parameter(Mandatory = $true)]
    [string]$vmName,
    [int]$MemoryGB,
    [int]$CPUCount
)    

function PowerOff-VM{
    param([string] $vm)

    Shutdown-VMGuest -VM (Get-VM $vm) -Confirm:$false | Out-Null
    Write-Host "Shutdown $vm"
    do {
        $status = (get-VM $vm).PowerState
    }until($status -eq "PoweredOff")
    return "OK"
}

function PowerOn-VM{
    param( [string] $vm)

    if($vm -eq ""){    Write-Host "Please enter a valild VM name"}

    if((Get-VM $vm).powerstate -eq "PoweredOn"){
        Write-Host "$vm is already powered on"}

    else{
        Start-VM -VM (Get-VM $vm) -Confirm:$false | Out-Null
        Write-Host "Starting $vm"
        do {
            $status = (Get-vm $vm | Get-View).Guest.ToolsRunningStatus
        }until($status -eq "guestToolsRunning")
        return "OK"
    }
}

function Change-VMMemory{
    param([string]$vmName, [int]$MemoryGB)
    if($vmName -eq ""){
        Write-Host "Please enter a VM Name"
        return
    }
    if($MemoryGB -eq ""){
        Write-Host "Please enter an amount of Memory in MB"
        return
    }

    $vm = Get-VM $vmName    
    $CurMemoryGB = ($vm).MemoryGB

    if($vm.Powerstate -eq "PoweredOn"){
        Write-Host "The VM must be Powered Off to continue"
        return
    }

    $vm | Set-VM -MemoryGB $MemoryGB -Confirm:$false
    Write-Host "The new configured amount of memory is"(Get-VM $VM).MemoryGB
}

function Change-VMCPUCount{
    param([string]$vmName, [int]$NumCPU)
    if($vmName -eq ""){
        Write-Host "Please enter a VM Name"
        return
    }
    if($NumCPU -eq ""){
        Write-Host "Please enter the number of vCPU's you want to add"
        return
    }

    $vm = Get-VM $vmName    
    $CurCPUCount = ($vm).NumCPU

    if($vm.Powerstate -eq "PoweredOn"){
        Write-Host "The VM must be Powered Off to continue"
        return
    }

    $vm | Set-VM -NumCPU $CPUCount -Confirm:$false
    Write-Host "The new configured number of vCPU's is"(Get-VM $VM).NumCPU
}

#######################################################################################
# Main script
#######################################################################################

if ($Connected -ne 1) {
    Connect-VIServer $vCenter -Credential $credential
    $Connected = 1}

If ($VIServer.IsConnected -ne $true){
    Write-Host "error connecting to $vCenter" -ForegroundColor Red
    exit
}

if($MemoryGB -or $CPUCount -ne "0"){
    $poweroff = PowerOff-VM $vmName
    if($poweroff -eq "Ok"){
    Write-Host "PowerOff OK"

        if($MemoryGB -ne "0"){
            Change-VMMemory $vmName $MemoryGB $MemoryOption
        }

        if($CPUCount -ne "0"){
            Change-VMCPUCount $vmName $CPUCount $CPUOption
        }

        $poweron = PowerOn-VM $vmName
        if($poweron -eq "Ok"){
            Write-Host "PowerOn OK"}
    }
}

Disconnect-VIServer -Confirm:$false
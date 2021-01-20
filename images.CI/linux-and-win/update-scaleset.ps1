param(
    [String] [Parameter (Mandatory)] $ImageName,
    [String] [Parameter (Mandatory)] $ResourceGroupName,
    [String] [Parameter (Mandatory)] $VmssName
)


Write-Host "Build Image Name: $ImageName"
Write-Host "Updating VMSS: $VmssName in resource group: $ResourceGroupName"

$vmss = Get-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName

if (!$vmss) {
  Write-Error "Could not find $VmssName in resource group: $ResourceGroupName" -ErrorAction Stop
}

Write-Host "Found scale set, checking for image..."

$image = Get-AzImage -ResourceGroupName $ResourceGroupName -ImageName $ImageName

if (!$image) {
  Write-Error "Could not find image $ImageName in resource group: $ResourceGroupName" -ErrorAction Stop
}

Write-Host "Located Image: $($image.Name)"
Write-Host "Updating VMSS with new image..."
Update-AzVmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName -ImageReferenceId $image.Id
Write-Host "VMSS reference Updated"

$instances = Get-AzVmssVM  -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName
Write-Host "Upgrading $($instances.Length) existing instances..."
foreach ($instance in $instances) {
  $id = $instance.InstanceId
  Write-Host "Upgrading VMSS instance: $id"
  Update-AzVmssInstance -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName -InstanceId $id
}
Write-Host "VMSS Update Complete"

# Remove old images as to not clutter
$oldImages = Get-AzImage -ResourceGroupName $ResourceGroupName 
              | Where-Object { $_.Name.StartsWith("agent-") -and $_.Name -ine $ImageName }

foreach ($oldImage in $oldImages) {
  Write-Host "Removing old image: $($oldImage.Name)"
  $oldImage | Remove-AzImage
}
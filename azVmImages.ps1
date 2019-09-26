#import
. .\azConnect.ps1

#connect
if ($connected) {
}
else{    #runs once per session
    azConnect
    $connected = $true
}

#list publishers
    $os_location = "East Us 2"
    Get-AzureRmVMImagePublisher -Location $os_location
    Get-AzureRmVMImageOffer -Location $os_location -PublisherName "Canonical"
    Get-AzureRmVMImageSku -Location $os_location -PublisherName "Canonical" -Offer "UbuntuServer"

#list publishers
    $os_location = "East Us 2"
    Get-AzureRmVMImagePublisher -Location $os_location
    Get-AzureRmVMImageOffer -Location $os_location -PublisherName "westernoceansoftwaresprivatelimited"
    Get-AzureRmVMImageSku -Location $os_location -PublisherName "westernoceansoftwaresprivatelimited" -Offer "centos-7-6"

#list publishers
    $os_location = "East Us 2"
    Get-AzureRmVMImagePublisher -Location $os_location
    Get-AzureRmVMImageOffer -Location $os_location -PublisherName "RedHat"
    Get-AzureRmVMImageSku -Location $os_location -PublisherName "RedHat" -Offer "RHEL"
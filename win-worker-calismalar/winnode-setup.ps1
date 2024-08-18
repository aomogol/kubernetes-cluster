# Windows-K8s-Worker-Setup.ps1

# Hata durumunda scripti durdur
$ErrorActionPreference = "Stop"

# Gerekli fonksiyonları tanımla
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
    Add-Content -Path "C:\k8s-setup.log" -Value "[$timestamp] $Message"
}

# Windows güncellemelerini kontrol et ve kur
Write-Log "Windows güncellemeleri kontrol ediliyor..."
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

# Containerd kurulumu
Write-Log "Containerd kuruluyor..."
$ContainerdVersion = "1.7.13"
$ContainerdArch = "amd64"
Invoke-WebRequest -Uri "https://github.com/containerd/containerd/releases/download/v$ContainerdVersion/containerd-$ContainerdVersion-windows-$ContainerdArch.tar.gz" -OutFile containerd.tar.gz
tar.exe xvf .\containerd.tar.gz
Copy-Item -Path ".\bin\*" -Destination "$Env:ProgramFiles\containerd" -Recurse -Force
containerd.exe --register-service
Start-Service containerd

# Kubernetes bileşenlerini kur
Write-Log "Kubernetes bileşenleri kuruluyor..."
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
#Install-Package -Name kubernetes-cli -ProviderName DockerMsftProvider -Force

# Kubernetes bileşenlerini kur
Write-Log "Kubernetes bileşenleri kuruluyor..."

# Geçici bir dizin oluştur
$tempDir = "C:\temp\k8s"
New-Item -ItemType Directory -Force -Path $tempDir

# Kubernetes sürümünü belirle
$kubernetesVersion = "v1.29.7"  # Bu sürümü güncel tutun

# Kubelet, kubeadm ve kubectl'i indir
$urls = @(
    "https://dl.k8s.io/$kubernetesVersion/bin/windows/amd64/kubelet.exe",
    "https://dl.k8s.io/$kubernetesVersion/bin/windows/amd64/kubeadm.exe",
    "https://dl.k8s.io/$kubernetesVersion/bin/windows/amd64/kubectl.exe"
)

foreach ($url in $urls) {
    $fileName = Split-Path $url -Leaf
    Invoke-WebRequest -Uri $url -OutFile "$tempDir\$fileName"
}

# Dosyaları C:\k dizinine taşı
New-Item -ItemType Directory -Force -Path "C:\k"
Move-Item -Path "$tempDir\*" -Destination "C:\k" -Force

# PATH'e C:\k ekle
$env:Path += ";C:\k"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

Write-Log "Kubernetes bileşenleri başarıyla kuruldu."



# Calico CNI kurulumu
Write-Log "Calico CNI kuruluyor..."
kubectl.exe --kubeconfig=C:\k\config apply -f https://docs.projectcalico.org/manifests/calico-windows.yaml

# Güvenlik yapılandırmaları
Write-Log "Güvenlik ayarları yapılandırılıyor..."
Set-MpPreference -DisableRealtimeMonitoring $false
New-NetFirewallRule -Name "Kubernetes" -DisplayName "Kubernetes" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 10250,30000-32767

# Samba ve NFS istemcilerini kur
Write-Log "Samba ve NFS istemcileri kuruluyor..."
Install-WindowsFeature -Name FS-SMB1
Install-WindowsFeature -Name NFS-Client

# Prometheus Windows Exporter kurulumu (izleme için)
Write-Log "Prometheus Windows Exporter kuruluyor..."
Invoke-WebRequest -Uri "https://github.com/prometheus-community/windows_exporter/releases/download/v0.22.0/windows_exporter-0.22.0-amd64.msi" -OutFile windows_exporter.msi
Start-Process msiexec.exe -ArgumentList '/i windows_exporter.msi ENABLED_COLLECTORS="cpu,memory,disk,netstat,service,os,system" /qn' -Wait

# Windows event loglarını Kubernetes log sistemine entegre et
Write-Log "Log entegrasyonu yapılandırılıyor..."
New-Item -Path "C:\k" -ItemType Directory -Force
$logConfig = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: kube-system
data:
  fluent.conf: |
    <source>
      type windows_eventlog
      channels application,system,security
      <storage>
        @type local
        path C:\k\fluentd
      </storage>
    </source>
    <match **>
      @type kubernetes
      @id out_kube_events
      include_tag_key true
    </match>
"@
$logConfig | Out-File -FilePath "C:\k\fluentd-config.yaml" -Encoding ascii

# Windows container özel ayarları
Write-Log "Windows container ayarları yapılandırılıyor..."
[Environment]::SetEnvironmentVariable("CONTAINER_ISOLATION", "hyperv", "Machine")

# Hybrid cluster için ek ayarlar
Write-Log "Hybrid cluster ayarları yapılandırılıyor..."
$hybridConfig = @"
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
featureGates:
  WindowsGMSA: true
  WindowsDSC: true
"@
$hybridConfig | Out-File -FilePath "C:\k\kubelet-config.yaml" -Encoding ascii

# Kubelet servisini oluştur ve başlat
Write-Log "Kubelet servisi oluşturuluyor ve başlatılıyor..."
kubectl.exe --kubeconfig=C:\k\config apply -f C:\k\kubelet-config.yaml
New-Service -Name "kubelet" -BinaryPathName "C:\k\kubelet.exe --config=C:\k\kubelet-config.yaml"
Start-Service kubelet

Write-Log "Kurulum tamamlandı. Lütfen 'kubeadm join' komutunu çalıştırarak cluster'a katılın."
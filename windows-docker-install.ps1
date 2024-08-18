# NuGet paket sağlayıcısını yükle
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# DockerMsftProvider modülünü yükle
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

# Docker'ı yükle
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# Kubernetes CLI'yi yükle
Install-Package -Name kubernetes-cli -ProviderName DockerMsftProvider -Force
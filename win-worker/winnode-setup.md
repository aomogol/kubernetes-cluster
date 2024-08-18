Bu script şunları yapar:
1. Windows güncellemelerini kontrol eder ve kurar.
Containerd'yi kurar ve yapılandırır.
Kubernetes bileşenlerini (kubelet, kubectl) kurar.
Calico CNI'yı kurar.
5. Temel güvenlik ayarlarını yapar (Windows Defender, Firewall).
Samba ve NFS istemcilerini kurar.
Prometheus Windows Exporter'ı izleme için kurar.
Windows event loglarını Kubernetes log sistemine entegre etmek için Fluentd yapılandırması oluşturur.
Windows container'lar için özel ayarlar yapar.
Hybrid cluster için ek ayarlar yapar.
Kubelet servisini oluşturur ve başlatır.
Bu scripti çalıştırmadan önce:
1. Test ortamında deneyin.
Ağ ayarlarınızı ve güvenlik politikalarınızı gözden geçirin.
Kubernetes master node'unuzun IP adresini ve join token'ını hazır bulundurun.
Windows Server 2019'un en son güncellemelerini yükleyin.
Yeterli disk alanı ve RAM olduğundan emin olun.
Son olarak, bu script bir başlangıç noktasıdır ve ortamınıza özgü ek yapılandırmalar gerekebilir. Kubernetes'in resmi Windows dokümantasyonunu incelemenizi ve gerekirse bir Kubernetes uzmanına danışmanızı öneririm.
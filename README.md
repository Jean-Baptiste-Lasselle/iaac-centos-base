# iaac-centos-base
Un repo qui documente la recette "pre-ssh", à appliquer sur un hôte CentOS fournit par le niveau IAAS, avant d'exécuter des recttes de cuisine Kytes 


# Procédure complète de provision "pre-SSH"

Ce document décrit la procédure complète de provision d'une VM avant exécution des recettes:

* https://github.com/Jean-Baptiste-Lasselle/provision-hote-docker-centos-7
* https://github.com/Jean-Baptiste-Lasselle/provision-k8s


### Si vous utilisez LVM pour os disques durs virtuel de VMs

Extension de capacité de disque LVM (afin d'attribuer donner "assez" d'espace disque libre sous `/var`, pour le moteur de conteneurs):

```
# On suppose que la VM fournie au niveau IAAS a été créée avec
# un disque dur virtuel d'une capacité supérieure ou égale à 30Go
sudo lvextend -rn /dev/mapper/vg00-lv_var -L 20G
```

### Si vous utilisez un proxy

Configuration du package manager:

```
# - pour configurer le proxy pour le package manager CentOS 7:
sudo -s
# il faut être "root", sudo ne fonctionnera pas.

export PROXY_SRV_HOST_OR_IP
export PROXY_SRV_IP_PORT_NUMBER
echo "proxy=http://$PROXY_SRV_HOST_OR_IP:$PROXY_SRV_IP_PORT_NUMBER/">> /etc/yum.conf

```

### Installation / Configuration de Git

```
sudo yum install -y git
git config --global user.email "jb.lasselle@bosstek.net" 
git config --global user.name "jb.lasselle" 
# Enfin, depuis Git 2.0 :
git config --global push.default matching
```


### Authentifcation GIT ssh avec paire de clés

Paire de clés asymétriques RSA:

```
ssh-keygen -t rsa -b 4096 && cat $HOME/.ssh/id_rsa.pub
# à copier pour ajouter la clé aux clefs SSH de votre utilisateur Gitlab / Bosstek
```

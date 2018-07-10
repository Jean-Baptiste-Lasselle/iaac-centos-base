# iaac-centos-base
Un repo qui documente la recette "pre-ssh", à appliquer sur un hôte CentOS fournit par le niveau IAAS, avant d'exécuter des recttes de cuisine Kytes 


# Procédure complète de provision "pre-SSH"

Ce document décrit la procédure complète de provision d'une VM avant exécution des recettes:

* https://github.com/Jean-Baptiste-Lasselle/provision-hote-docker-sur-centos
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
git config --global user.email "jean.baptiste.lasselle.it@gmail.com" 
git config --global user.name "Jean-Baptiste-Lasselle" 
# Enfin, depuis Git 2.0 :
git config --global push.default matching
```


### Authentifcation GIT ssh avec paire de clés

Paire de clés asymétriques RSA:

```
ssh-keygen -t rsa -b 4096 && cat $HOME/.ssh/id_rsa.pub
# à copier pour ajouter la clé aux clefs SSH de votre utilisateur Gitlab
```

# Cycles IAAC

### Vocabulaire
IAAS: Infrastructure As A Service (ex.: OpenStack)

## Description du cycle Infrastructure As Code

### Cycle élémentaire (sans mémoire des opérations)

Le but de ce petit paragraphe, est de décrire un cycle élémentaire complet respectant Infrastructure As Code, applicable tel quel, dans l'infrastructure dans laquelle vos machines vivent.

Le niveau IAAS créée une Machine Virtuelle `uneVM` sur laquelle est installé et configuré CentOS, avec 2 interfaces réseaux, connectée à des réseaux distincts (modèle OSI, niveau L2).

On fait usage d'un nom d'utilisateur linux désigné par `$UTILISATEUR`, fournit par l'administrateur du niveau IAAS, 
pour ouvrir une session ssh vers la machine `uneVM`.

On configure le package manager pour le proxy de l'infrastructure:


```
# -
# Pour CentOS, le package manager est yum, et il suffit, en tant que
# root, d'exécuter les commandes ci-dessous pour appliquer la configuration.
# -
$ sudo -i
# echo "proxy=http://proxy:8080">> /etc/yum.conf
# su $**UTILISATEUR**
# -
```
Pour les Ubuntu / Debian, le package manager est apt, et il suffit, en tant que root, d'exécuter les instructions ci-dessous pour appliquer la configuration:
```
$ sudo -i
# echo "Acquire::http::proxy \"http://proxy:8080/\";">> /etc/apt/apt.conf
# echo "Acquire::https::proxy \"http://proxy:8080/\";">> /etc/apt/apt.conf
# su $**UTILISATEUR**
```
On installe git dans la machine uneVM :

CentOS:
```
$ sudo yum install -y git
```
Debian / Ubuntu:
```
$ sudo apt-get install -y git
```
On génère une paire de clés asymétriques, sur uneVM , pour l'utilisateur $UTILISATEUR :
```
$ ssh-keygen -t rsa -b 4096
$ cat $HOME/.ssh/id_rsa.pub
```
On utilisera un repository Git dans l'instance Gitlab, afin de versionner une recette que l'on va concevoir.
Connectez-vous au Gitlab  (https://votre-serveur-gitlab/) , créez-vous un compte, puis:

Dans le coin haut-droit de la page web gitlab, vous trouverez le menu permettant de gérer votre compte utilsiateur Gitlab. Lorsque vous cliquez sur celui-ci, un menu déroulant aappraît, cliquez sur le sous-menu “Settings”. Pour indication, dans ce même menu, on trouve: le bouton “sign out”, les sous-menus “Profile” et “Help”.
    Sur la gauche vous voyez maintenant un menu vertical , comportant un sous menu “SSH Keys”, cliquez sur ce sous-menu. Vous êtes maintenant dans une page, comportant un formulaire, et dans ce formulaire, collez la valeur de la clé publique que vous avez générée. Vous pouvez afficher (et copier) la valeur de cette clé publique avec l'instruction:
```
$ cat $HOME/.ssh/id_rsa.pub
```
Désormais, il est possible, dans la machine uneVM , pour l'utilisateur linux $UTILISATEUR, de cloner un repo auquel votre utilisateur Gitlab a accès (soit parce qu'on lui a donné accès à celui-ci, soit parce qu'il l'a créé), avec le protocole SSH, et en s'authentifiant 'silencieusement'. Vérifiez-le en exécutant:

```
$ cd $HOME
$ export MAISON_OPERATIONS=$(pwd)/ma-meilleure-recette
$ mkdir -p $MAISON_OPERATIONS
$ cd $MAISON_OPERATIONS
$ export NOM_DU_REPO_QUE_VOUS_AVEZ_CREE="cycle-iaac"
$ export VOTRE_USERNAME_GITLAB="the-devops-guy"
$ export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=2222
$ export NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB=gitlab.mon-entreprise.io
$ export URI_SSH_GIT_REMOTE="ssh://git@$NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB:$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB"
$ export GIT_SSH_COMMAND="ssh -p2222 -i ~/.ssh/id_rsa" && git clone "$URI_SSH_GIT_REMOTE/$VOTRE_USERNAME_GITLAB/$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE" .
$ echo "et pour vérifier...:"
$ ls -all
```

Enfin, si vous avez exécuté exactement la procédure de clonage git précédente, vous pourrez entrer dans le cycle suivant:

* exécutez la recette
* exécutez vos tests
* interprétez vos tests
* préparez votre message de commit, en suivant la boucle exacte (utilsiez putty ou un terminal shell classique):

```
$ export MESSAGE_COMMIT=""
$ # Pressez la tocue flèche haute, double cliquez sur "MESSAGE_COMMIT" (ce qui copiera la chaîne de caractère "MESSAGE_COMMIT")
$ export MESSAGE_COMMIT="$MESSAGE_COMMIT "
$ # Pressez une deuxième fois la flèche haute, et complétez le message de commit:
$ # export MESSAGE_COMMIT="$MESSAGE_COMMIT Vous compléterez ici le message de commit qui vous chante "
```
apportez un changement au code source de la recette (avec vi)
faîtes le commit and push:

```
$ export MESSAGE_COMMIT=""
$ # Pressez la touche flèche haute, double cliquez sur "MESSAGE_COMMIT" (ce qui copiera la chaîne de caractère "MESSAGE_COMMIT")
$ export MESSAGE_COMMIT="$MESSAGE_COMMIT "
$ # Pressez une deuxième fois la flèche haute, et complétez le message de commit: 
$ export MESSAGE_COMMIT="$MESSAGE_COMMIT Modification de la fonction [ synchroniserAuSrvNTP () ] "
$ # Et seulement alors, commit && push
$ export GIT_SSH_COMMAND="ssh -p2222 -i ~/.ssh/id_rsa"
$ git add * *.* **/* && git commit -m "$MESSAGE_COMMIT" && git push
```

# iaac-centos-base

Un repo qui documente la recette "pre-ssh", à appliquer sur un hôte CentOS fournit par le niveau IAAS, avant d'exécuter des recettes de cuisine Kytes 


# Procédure complète de provision "pre-SSH"

À l'issue de la procédure, on pourra exécuter des recettes telles que:

* https://github.com/Jean-Baptiste-Lasselle/provision-hote-docker-sur-centos
* https://github.com/Jean-Baptiste-Lasselle/provision-k8s


### Si vous utilisez LVM pour vos disques durs virtuel de VMs

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

### Installation de Git

```
sudo yum install -y git
```


### Authentifcation GIT ssh avec paire de clés

Paire de clés asymétriques RSA:

```
ssh-keygen -t rsa -b 4096 && cat $HOME/.ssh/id_rsa.pub
# à copier pour ajouter la clé aux clefs SSH de votre utilisateur Gitlab
```

# Cycles IAAC

### Vocabulaire

* IAAS: Infrastructure As A Service (ex.: OpenStack)
* IAAC: Infrastructure Adressed As Code

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
# su $UTILISATEUR
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
On génère une paire de clés asymétriques, sur `uneVM` , pour l'utilisateur `$UTILISATEUR` :
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
$ export NOM_DU_REPO_QUE_VOUS_AVEZ_CREE="iaac-centos-base"
$ export VOTRE_USERNAME_GITLAB="Jean-Baptiste-Lasselle"
$ # export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=2222
$ export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=22
$ export NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB=gitlab.mon-entreprise.io
$ export URI_SSH_GIT_REMOTE="ssh://git@$NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB:$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB"
$ export GIT_SSH_COMMAND="ssh -p$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB -i ~/.ssh/id_rsa" && git clone "$URI_SSH_GIT_REMOTE/$VOTRE_USERNAME_GITLAB/$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE" .
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
$ # Pressez la touche clavier "flèche haute", double cliquez sur "MESSAGE_COMMIT" (ce qui 
# # copiera la chaîne de caractères  "MESSAGE_COMMIT" dans le presse-papier)
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
$ # export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=2222
$ export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=22
$ export GIT_SSH_COMMAND="ssh -p$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB -i ~/.ssh/id_rsa"
$ git add * *.* **/* && git commit -m "$MESSAGE_COMMIT" && git push
```

## Recette initialisation du cycle Infrastructure As Code

```


# Création du fichier de script
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- ENV.
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
export MAISON_OPERATIONS

# export NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB=gitlab.mon-entreprise.io
export NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB=github.com
# export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=2222
export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=22

export URI_SSH_GIT_REMOTE_FOR_GITLAB="ssh://git@$NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB"
export URI_SSH_GIT_REMOTE_FOR_GITHUB="git@$NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB"
# Valeur par défaut
export URI_SSH_GIT_REMOTE=$URI_SSH_GIT_REMOTE_FOR_GITLAB


export VOTRE_USERNAME_GITLAB="Jean-Baptiste-Lasselle"
export GIT_SSH_COMMAND="ssh -p$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB -i ~/.ssh/id_rsa"

# -
# Pour initialiser un cycle IAAC, on commmence par créer
# le repository de versionning du code source de la recette IAAC
# On pourra aller jusqu'à créer un archetype Maven"
# -
# L'utilisateur a fournit la chaîne de caractères vide, pour
# nom du repository Git surl lequel il souhaite travailler. 
# Aucun nom de repository ne peut être fournit par défaut.
export NOM_DU_REPO_QUE_VOUS_AVEZ_CREE


# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- FONCTIONS
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel est le nom du repo git sur lequel il souhaite travailler
# ERREURS: si le nom du repo choisit est vide.
demander_NomRepoGit () {

        echo "Quel est le nom du repository Git sur lequel vous souhaitez travailler?"
        echo " "
        echo " "
        read NOM_REPO_CHOISIT
        # Vérifier l'existence du repo avec CURL ?
        if [ "x$NOM_REPO_CHOISIT" = "x" ]
        then
          export MESSAGE_ERREUR=""
          export MESSAGE_ERREUR="$MESSAGE_ERREUR L'utilisateur a fournit la chaîne de caractères vide, pour"
          export MESSAGE_ERREUR="$MESSAGE_ERREUR nom du repository Git surl lequel il souhaite travailler. "
          export MESSAGE_ERREUR="$MESSAGE_ERREUR Aucun nom de repository ne peut être fournit par défaut."
		  # un arrêt total des opérations, avec message d'erreur envoyé sur le canal standard d'erreur OS.
          $(>&2 echo "$MESSAGE_ERREUR") && exit 1
        else
          NOM_DU_REPO_QUE_VOUS_AVEZ_CREE=$NOM_REPO_CHOISIT
        fi
}




# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- OPERATIONS
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

demander_NomRepoGit
echo " DEBUG 1 - PWD= [$(pwd)]"
echo " DEBUG 1 - NOM_DU_REPO_QUE_VOUS_AVEZ_CREE= [$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE]"
read
export MAISON_OPERATIONS=$(pwd)/$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE
rm -rf $MAISON_OPERATIONS
mkdir -p $MAISON_OPERATIONS
cd $MAISON_OPERATIONS
echo " DEBUG 2 - PWD= [$(pwd)]"

# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- Configuration Git pour mon environnement de travail IAAC "Infrastructure Code Management Environnement"
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

git config --global user.email "jean.baptiste.lasselle.it@gmail.com" 
git config --global user.name "Jean-Baptiste-Lasselle" 
# Enfin, depuis Git 2.0 :
git config --global push.default matching

# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- PREMIER GIT CLONE DU REPO VIDE
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

# - On détermine s'il s'agit de Github ou d'un Gitlab
echo "$NOM_D_HOTE_OU_IP_DE_VOTRE_SRV_GITLAB" > ./es-ce-github.kytes
export ES_CE_GITHUB=$(cat ./es-ce-github.kytes | grep github)

if [ "x$ES_CE_GITHUB" = "x" ]
then
    echo "[$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE] : Il s'agit d'un repository dans un serveur Gitlab privé"
	export URI_SSH_GIT_REMOTE=$URI_SSH_GIT_REMOTE_FOR_GITLAB 
else
    echo "[$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE] : Il s'agit d'un repository https://github.com"
    export URI_SSH_GIT_REMOTE=$URI_SSH_GIT_REMOTE_FOR_GITHUB
fi
rm -f ./es-ce-github.kytes

# - On fait le git clone
git clone "$URI_SSH_GIT_REMOTE:$VOTRE_USERNAME_GITLAB/$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE" .


# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- copiez collez dans le répertoire contenant le ".git", tous les fichiers et répertoires
#     que vous souhaitez versionner
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- initialisation du cycle iaac
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

export MESSAGE_COMMIT=""
# Pressez la touche flèche haute, double cliquez sur "MESSAGE_COMMIT" (ce qui copiera la chaîne de caractère "MESSAGE_COMMIT")
export MESSAGE_COMMIT="$MESSAGE_COMMIT "
# Pressez une deuxième fois la flèche haute, et complétez le message de commit: 
export MESSAGE_COMMIT="$MESSAGE_COMMIT commit initial "
# Et seulement alors, ajout de tous les fichiers commit && push

export GIT_SSH_COMMAND="ssh -p$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB -i ~/.ssh/id_rsa"
git add * *.* **/* && git commit -m "$MESSAGE_COMMIT" && git push --set-upstream origin master


```

## Recette reprise du cycle Infrastructure As Code

```
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- ENV.
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=2222
export NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB=22
export GIT_SSH_COMMAND="ssh -p$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB -i ~/.ssh/id_rsa"
# --- EDITEZ LE CODE SOURCE DE VOTRE RECETTE IAAC


# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- reprise du cycle iaac
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
export MESSAGE_COMMIT=""
# Pressez la touche flèche haute, double cliquez sur "MESSAGE_COMMIT" (ce qui copiera la chaîne de caractère "MESSAGE_COMMIT")
export MESSAGE_COMMIT="$MESSAGE_COMMIT "
# Pressez une deuxième fois la flèche haute, et complétez le message de commit: 
export MESSAGE_COMMIT="$MESSAGE_COMMIT commit initial "
# Et seulement alors, commit && push
export GIT_SSH_COMMAND="ssh -p$NUMERO_PORT_IP_DE_VOTRE_SRV_GITLAB -i ~/.ssh/id_rsa"
git add * *.* **/* && git commit -m "$MESSAGE_COMMIT" && git push
```

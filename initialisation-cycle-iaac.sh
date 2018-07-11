#!/bin/bash
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
# 
export NOM_DU_REPO_QUE_VOUS_AVEZ_CREE

# - 
#   Le chemin du répertoire contenant les fichiers à versionner
# - 
# 
export REPERTOIRE_FICHIERS_A_VERSIONNER



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
demander_NomRepoGit
export MAISON_OPERATIONS=$(pwd)/$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE-$RANDOM
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel est le chemin du répertoire contenant les fichiers à récupérer.
# Le contenu de ce répertoire sera copié tel quel et récursivement, à la racine
# du repo local Git.
# - 
#  Dépendances: [demander_NomRepoGit ()] doit être exécutée avant
# 
# - 
# 
demander_CheminRepertoireFichiersAversionner () {

        echo "Quel est le chemin du répertoire contenant les fichiers à versionner?"
        echo " "
        echo " (ATTENTION: Si vous donnez un chein relatif, donnez-le relativement au )"
        echo " ( répertoire [$MAISON_OPERATIONS] )"
        echo " "
        read NOM_REPERTOIRE_CHOISIT
        echo " "
        # Vérifier l'existence du repo avec CURL ?
        if [ "x$NOM_REPERTOIRE_CHOISIT" = "x" ]
        then
          export MESSAGE_ERREUR=""
          export MESSAGE_ERREUR="$MESSAGE_ERREUR L'utilisateur a fournit un chaîne de caractères vide, pour"
          export MESSAGE_ERREUR="$MESSAGE_ERREUR le chemin du réperoire dans lequel sont les fichiers à versionner. "
          export MESSAGE_ERREUR="$MESSAGE_ERREUR Aucun chemin ne peut être fournit par défaut."
		  # un arrêt total des opérations, avec message d'erreur envoyé sur le canal standard d'erreur OS.
          $(>&2 echo "$MESSAGE_ERREUR") && exit 1
        else
          REPERTOIRE_FICHIERS_A_VERSIONNER=$NOM_REPERTOIRE_CHOISIT
        fi
	if [ -d "$REPERTOIRE_FICHIERS_A_VERSIONNER" ]
        then
          export MESSAGE_INFO=""
          export MESSAGE_INFO="$MESSAGE_INFO Le répertoire "
	      export MESSAGE_INFO="$MESSAGE_INFO    [$REPERTOIRE_FICHIERS_A_VERSIONNER]   "
          export MESSAGE_INFO="$MESSAGE_INFO existe et va être copié dans [ $(pwd) ]"
		  echo "$MESSAGE_INFO"
        else
          export MESSAGE_ERREUR3=""
          export MESSAGE_ERREUR3="$MESSAGE_ERREUR3 Le répertoire "
	      export MESSAGE_ERREUR3="$MESSAGE_ERREUR3    [$REPERTOIRE_FICHIERS_A_VERSIONNER]   "
          export MESSAGE_ERREUR3="$MESSAGE_ERREUR3 n'existe pas. Quels Fichiers souahitez-vous versionner?"
          # un arrêt total des opérations, avec message d'erreur envoyé sur le canal standard d'erreur OS.
          $(>&2 echo "$MESSAGE_ERREUR3") && exit 1
        fi
}




# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
# --- OPERATIONS
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 




echo " DEBUG 1 - PWD= [$(pwd)]"
echo " DEBUG 1 - NOM_DU_REPO_QUE_VOUS_AVEZ_CREE= [$NOM_DU_REPO_QUE_VOUS_AVEZ_CREE]"
read

rm -rf $MAISON_OPERATIONS
mkdir -p $MAISON_OPERATIONS
cd $MAISON_OPERATIONS
echo " DEBUG 2 - PWD= [$(pwd)]"


demander_CheminRepertoireFichiersAversionner

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
# --- copie, dans le répertoire contenant le ".git", de tous les fichiers et répertoires
#     que vous souhaitez versionner
# --- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
echo " DEBUG 3 - PWD= [$(pwd)]"
cp -rf $REPERTOIRE_FICHIERS_A_VERSIONNER/* .
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

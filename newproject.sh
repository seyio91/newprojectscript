#!/bin/bash
# Script is used to automate the process of creating new project and push to new github repo
# New Project Script Requires a GITHUB_USERNAME, GITHUB_TOKEN for using the GITHUB API to create a new repo
# Link for Creating Personal Access Tokens  https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
# GITHUB_USERNAME and GITHUB_TOKEN can be passed as variables on commandline or by exporting the variables in the bash shell before running the script

# see https://www.seyiobaweya.tech/articles/2020-01-17/new-project-script/

# script has a jq dependency for reading json. this is only used to check if the repo currently exists in your github acct. 
# Refinements are welcome

normal="\033[0m"
greentext="\033[32m"
danger="\e[91m"
warning="\e[93m"
INTERACTIVE=
REPO_NAME=
REGEX="0-9a-zA-Z_-"
DEFAULT_DIR="$HOME/projects"
PROJECT_DIR=${PROJECT_DIR:-$DEFAULT_DIR}
REPO_FOLDER=
HELP=



error (){
    local msg=$1
    echo -e $danger"$msg"$normal
}

warning (){
    local msg=$1
    echo -e $warning"$msg"$normal
}

success (){
    local msg=$1
    echo -e $greentext"$msg"$normal    
}


usage(){
    warning "__________________________________________________________________"
    warning "\nNewproject script to create github repo on start of new project"
    warning "------------------------------------------------------------------"
    warning "Usage: newproject [ -i | -d | -f | -u | -t | -h ] repo_name\n"
    echo " -i : Interactive Prompt (No Arg)"
    echo " -d : Default Projects Directory"
    echo " -f : Folder for Storing Repo"
    echo " -u : Github Username"
    echo " -t : Github Personal Access Token"
    echo -e " -h : Help (No Arg)\n"
    warning " Sample: newproject -i reponame: To Get Interactive prompt"
    warning " Sample: newproject -f project folder  reponame: To Specify a different Project folder from Repo name\n"
    exit 1
}


# regex check
nameCheck(){
    local repo_name=$1
    if [[ $repo_name =~ [^$REGEX] ]]; then
        error "Repo Naming Convention Error !!!"
        error "Repo can only Contain letters, Numbers and an Underscore ... EXITING !!! \n"
        usage
    fi
}

currentgitdir(){
    local folder=$1
    if [[ -e "$folder/.git" ]]; then
        error "Repo Folder: $REPO_FOLDER includes an Existing Repository ... EXITING"
        usage
    fi
}

clean_up (){
    warning "cleaning up Repo folder $REPO_FOLDER"
    sleep 1
}

while getopts "d:u:t:f:ih" option; do
    case "$option" in

    i ) INTERACTIVE=1;;
    d ) PROJECT_DIR=$OPTARG;;
    f ) REPO_FOLDER=$OPTARG;;
    u ) GITHUB_USERNAME=$OPTARG;;
    t ) GITHUB_TOKEN=$OPTARG;;
    h ) HELP=1;;
    \? ) usage
        ;;
    esac
done
shift $((OPTIND -1))

if [[ $HELP = 1 ]]; then
    usage
fi


if [ "$#" -ne 1 ]; then
    error "Illegal number of parameters\n"
    usage
fi

PROJECT_DIR=$(realpath $PROJECT_DIR)
REPO_NAME=$1


# check if Reponame is set here
if [[ ! -n $REPO_NAME ]]; then
    error "invalid Argument, Pass Repo Name\n ...EXITING"
    usage
else
    nameCheck $REPO_NAME
fi


# PROJECT DIRECTORY SESSION
if [[ $INTERACTIVE = 1 ]]; then
    echo -n "Enter project Default Folder: ($PROJECT_DIR) "
    read answer
    [[ -n $answer ]] && PROJECT_DIR=$(realpath $answer)
fi 


#check if project file exists
if [[ ! -d $PROJECT_DIR ]]; then
    echo "Projects Default Directory Does not exist"
    echo -n "CREATE AT $PROJECT_DIR (Press y|Y for Yes, any other key for No) Default - n: "
    
    read reply

    if [[ $reply = "Y" || $reply = "y" ]]; then
        mkdir -p "$PROJECT_DIR"
    else
        echo "Exiting Script. Project directory $PROJECT_DIR does not Exist"
        exit 1
    fi
fi
# PROJECT DIRECTORY SESSION END

# PROJECT FOLDER SECTION
if [[ $INTERACTIVE = 1 ]]; then
    echo -n "Enter project Folder- Repo name will be used if no default:  ($REPO_FOLDER) "
    read answer
    REPO_FOLDER=$answer
fi 

# check for repo name in command
if [[ ! -n $REPO_FOLDER ]]; then
    REPO_FOLDER="$PROJECT_DIR/$REPO_NAME"
else
    REPO_FOLDER="$PROJECT_DIR/$REPO_FOLDER"
fi

# Checking if Folder is already a repository
currentgitdir $REPO_FOLDER

if [[ ! -d $REPO_FOLDER ]]; then
    warning "$REPO_FOLDER DOES NOT EXIST"
    echo "creating Folder $REPO_FOLDER"
    # mkdir -p $REPO_FOLDER
    sleep 1
fi
# END PPROJECT FOLDER


# GIT CRENDENTIALS CHECK
if [[ $INTERACTIVE = 1 ]]; then
    echo -n "ENTER GITUSERNAME:  ($GITHUB_USERNAME) "
    read answer
    [[ -n $answer ]] && GITHUB_USERNAME=$answer

    echo -n "ENTER GIT TOKEN: "
    read -s answer
    [[ -n $answer ]] && GITHUB_TOKEN=$answer
fi

if [[ ! -n $GITHUB_TOKEN ||  ! -n $GITHUB_USERNAME ]]; then
    error "GIT Crendentials not set"
    clean_up
    exit 1
fi

# GIT CONFIG
GITHUB_URL="https://api.github.com/users/${GITHUB_USERNAME}/repos"
GITHUB_ORIGIN_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

# Check if GITREPO ALREADY EXISTS
for row in $(curl -s "$GITHUB_URL" | jq -r '.[] | .name'); do
    if [[ $row == "$REPO_NAME" ]]; then
        error "Repo Name Already Exists"
        exit 1
    fi
done


echo -n "Creating GITHUB Repository $REPO_NAME ...\n"
curl -u "${GITHUB_USERNAME}:${GITHUB_TOKEN}" https://api.github.com/user/repos -d '{"name":"'$REPO_NAME'"}' 1> /dev/null
success " done.\n"


# Navigation to project dir
cd $REPO_FOLDER

# Initializing Git
echo -n "Initializing GIT REPO at $REPO_FOLDER ..."
git init > /dev/null 2>&1
success " done.\n"

# Creating README File
echo -n "Creating PROJECT README ..."
echo "### $REPO_NAME" > README.md
success " done.\n"

# Add .gitignore File
echo -n "Creating Gitignore file ..."
echo ".env" > .gitignore
success " done. \n"

# ADD Git Origin
echo -n "Adding Remote Origin  ..."
git remote add origin $GITHUB_ORIGIN_URL > /dev/null 2>&1
success " done.\n"

# Stage Readme
git add .

# First Commit
echo -n "Creating First Commit ..."
git commit -m "Initial $REPO_NAME commit" > /dev/null 2>&1
success " done.\n"

# Push First Commit
echo -n "Pushing First commit to Remote ..."
git push -u origin master > /dev/null 2>&1
success " done."
echo "Repo Created"
echo "Repo can be accessed at https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"

## New Project Script
Script to Automate Creating a new project and Pushing to GitHub from Command Line.    
  
## Dependencies  
 **Github personal access token** is required to create repo as well as making commits. Link on Creating your Personal Access Token is [https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line).  
**JQ Program** for parsing responses from the git api. This checks if there is an existing repo with the same name on users github page    

## Installation  
**Make Script Executable**  
`chmod +x newproject`  
  
**Add Script to User/Global Path**  
Add Script Directory to Path to make available all through user profile by adding to .bashrc  
`echo "export PATH=$PATH/scriptdir" >> ~/.bashrc`  
Note: Please add manually than using echo to avoid overwriting .basrc file    
  
**Installing JQ Dependency**  
for debian  
`sudo apt-get install jq`  
  
for redhat  
`sudo yum install jq`  
  
**Script Variables**  
Github Personal Access Token and Github Username should not be Hardcoded on the script. The Variables can be Passed in by Exporting github Username as $GITHUB_USERNAME or using the -u flag and Token as $GITHUB_TOKEN or the -t flag  
`export GITHUB_TOKEN="dummy_token"`  
`export GITHUB_USERNAME="seyio91"`  

**Optional Variables**  
export PROJECT_DIR where your projects will be saved. this can also be specified when running the program or hardcoded using the DEFAULT_DIR variable  
`export PROJECT_DIR="/home/seyi/projects"`

## Usage  
`Usage: newproject [ -i | -d | -f | -u | -t | -h ] repo_name`  
 `-i : Interactive Prompt`   
 `-d : Projects Directory` 
 `-f : Folder for Storing Repo`  
 `-u : Github Username`  
 `-t : Github Personal Access Token`  
 `-h : Help`  

**Basic Usage**  
`newproject reponame`  
newproject script will create folder with the reponame in the directory set in the DEFAULT_DIR variable.  
  
`newproject -d /home/system/opt -f newfolder reponame`  
Project folder "newfolder" will be created in the directory passed to -d flag.  
  
`newproject -u seyio91 -t dummy_token reponame`  
username and token will overwrite the variables exported to shell environment during setup  
  
`newproject -i reponame`  
Starts the interactive session

`newproject -i reponame`
`Enter project Default Folder: (/home/seyi/projects)`  
`Enter project Folder- Repo name will be used if no default:  ()`  
`ENTER GITUSERNAME:  (seyio91)`  
`ENTER GIT TOKEN:  (dummy_token)`  
  
`newproject -h`   
to view help option  
  
### Other Script Features  
- rRegex variable which helps restrict the permitted symbols that can be used in the repo name. This can be changed to permit other symbols  
- Check for existing Repo in project folder.   
- Duplicate Repo Check.

### Planned Improvements.  
- Specific Project Types. Ability to specify the type of project and create directory structure by project e.g creating virtual env for python or dockerfiles for docker projects  
- Add Testing
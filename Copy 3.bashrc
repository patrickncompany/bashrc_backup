alias gcod='git checkout develop'
# cmpro
alias cdcmpro='cd $HOME/Sites/cmpro/src'
# cmpro-coldbox
alias cdcoldbox='cd $HOME/Sites/cmpro-coldbox'
alias cdbox='cd $HOME/Sites/cmpro-coldbox'
# cmpro-devtools
alias cddevtools='cd $HOME/Sites/devtools'
alias cddt='cd $HOME/Sites/devtools'
# cmpro-extjs
alias cdextjs='cd $HOME/Sites/cmpro-extjs/src'
alias cdx='cd $HOME/Sites/cmpro-extjs/src'
# -z x = true if length of x is zero
# -n x = true if length of n is not zero
# git switch [develop|feature/x]
function gf() {
    if [ -z "$1" ]; then
        git switch develop;
    else
        uc1=$(echo $1 | tr '[:lower:]' '[:upper:]')
        git switch feature/$uc1;
    fi;
};
# git flow feature start x
function gffs() {
    if [ -z "$1" ]; then
        echo "need AI number";
    else
        uc1=$(echo $1 | tr '[:lower:]' '[:upper:]')
        git flow feature start $uc1;
    fi;
};
## ########################################################################### ##
## vscode open ai files                                                        ##
## this is written to execute from the .bashrc                                 ##
## type vsopen at git bash cli in cmpro directory on a certain branch          ##
## and expects to find AIxxxxxxxx-files.txt in the AI workspace                ##
## /c/Users/KenOwens/Sites/NOTES/AIxxxxxxxx/AIxxxxxxxx-files.txt               ##
## ########################################################################### ##
function vsopen() {
    if [ -z "$1" ]; then
        pai=$(git rev-parse --abbrev-ref HEAD | xargs);
        pai=${pai:8:10}
        read -p "Need AI Number : [ $pai ] " ai;
        echo $ai;
        if [ -z "$ai" ]; then
            ai=$pai;
        fi;
    else
        ai=$1;
    fi;
    #readarray -t cArray < "/c/Users/KenOwens/Sites/NOTES/$ai/$ai-files.txt";
    # Must use this method to filter linefeed / carriage returns
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'cArray=($(cat "/c/Users/KenOwens/Sites/NOTES/$ai/$ai-files.txt"))'
    # first line is open all
    openAll="${cArray[0]}";
    # second line is open cfm
    openCFM="${cArray[1]}";
    # third line is open sql
    openSQL="${cArray[2]}";
    # third line is open sql
    openSPEC="${cArray[3]}";

    read -p "Open : [ none ] (1=all, 2=cfm, 3=sql, 4=spec) " openPick;
    if [ -z "$openPick" ]; then
        openPick=4;
    fi;
    if [ $openPick -eq 1 ]; then
        eval $openAll;
    elif [ $openPick -eq 2 ]; then
        eval $openCFM;
    elif [ $openPick -eq 3 ]; then
        eval $openSQL;
    elif [ $openPick -eq 4 ]; then
        eval $openSPEC;
    else
        # eval $openAll;
        echo "No files opened."
    fi;

};
## ########################################################################### ##
##                                                                             ##
##    primarily to clear the server list and start 2021 fresh                  ##
##    also lets user pick starting git branch                                  ##
##      stash support added                                                    ##
##                                                                             ##
## ########################################################################### ##
function devstart() {
    if [ -z "$1" ]; then
        # parse ai from git
        pai=$(git rev-parse --abbrev-ref HEAD | xargs);
        pai=${pai:8:10}
        read -p "Startup AI : [ $pai ] " ai;
        if [ -z "$ai" ]; then
            ai=$pai;
            # no need to switch
        else
            # switch to entered ai
            git switch feature/$ai;
        fi;
    else
        # ai passed in as arg
        ai=$1;
        # force switch
        git switch feature/$ai;
    fi;
    # parse stash list for auto wip
    # stash@{0}: On AI20220447: auto stash - AI20220447 WIP
    stpath="/c/Users/KenOwens/Sites/NOTES/$ai";
    stfile1="$ai-wip.txt";
    git stash list > $stpath/$stfile1;
    # Must use this method to filter linefeed / carriage returns
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'cArray=($(cat "/c/Users/KenOwens/Sites/NOTES/$ai/$ai-wip.txt"))'
    for thisWIP in "${cArray[@]}"
    do
        thisAuto=${thisWIP:26:23};
        thisPOP=${thisWIP:0:9};
        thisAI=${thisWIP:14:10};
        if [ "$thisAuto" == "auto stash - $thisAI" ]; then
            echo "Found stash.";
            git stash pop $thisPOP;
        fi;
    done;
    # update cmpro-alt.xml to this schema
    upsdefault="Y";
    #timestamp=`date +%Y%m%d%H%M%S`;
    read -p "Update cmpro-alt with schema? : [ $upsdefault ] " ups;
    if [ -z "$ups" ]; then
        ups=$upsdefault;
    fi;

    if [ $ups == "Y" ]; then
        # update schema
        #echo "Backing up cmpro-alt.xml to $ai workspace.";
        #cp "/c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" "$stpath/cmpro-alt-$timestamp.xml";
        echo "Updating schema."
        sed -i "s/.*<datasource>\(.*\)<\/datasource>.*/            <datasource>$ai<\/datasource>/" "/c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml";
    fi;

    #restart server
    rstdefault="Y";
    read -p "Restart Server? : [ $rstdefault ] " rst;
    if [ -z "$rst" ]; then
        rst=$rstdefault;
    fi;
    if [ $rst == "Y" ]; then
        echo "Stopping all servers."
        pida=$(box server stop --all) &
        wait $!
        echo "Starting server 2021."
        pidb=$(box server start 2021) &
        wait $!
    elif [ $rst == "N" ]; then
        echo "Server state ignored."
    fi;

    #open ai files
    vsopen $ai;

};
## ########################################################################### ##
##                                                                             ##
##    stash work in progress                                                   ##
##    shut down server                                                         ##
##                                                                             ##
## ########################################################################### ##
function devstop() {
    if [ -z "$1" ]; then
        # parse ai from git
        pai=$(git rev-parse --abbrev-ref HEAD | xargs);
        pai=${pai:8:10}
        read -p "Stash AI WIP: [ $pai ] " ai;
        if [ -z "$ai" ]; then
            ai=$pai;
            # no need to switch
        else
            # switch to entered ai
            git switch feature/$ai;
        fi;
    else
        # ai passed in as arg
        ai=$1;
    fi;
    # stash to ai wip
    echo "Stashing WIP for $ai";
    pida=$(git stash -u -m "auto stash - $ai WIP") &
    wait $!

    # revert cmpro-alt.xml to cmpro_develop_view schema
    rvtdefault="Y";
    dfschema="cmpro_develop_view";
    #timestamp=`date +%Y%m%d%H%M%S`;
    read -p "Revert cmpro-alt to $dfschema schema? : [ $rvtdefault ] " rvt;
    if [ -z "$rvt" ]; then
        rvt=$rvtdefault;
    fi;

    if [ $rvt == "Y" ]; then
        # revert schema
        #echo "Backing up cmpro-alt.xml to $ai workspace.";
        #cp "/c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" "$stpath/cmpro-alt-$timestamp.xml";
        echo "Reverting schema."
        sed -i "s/.*<datasource>\(.*\)<\/datasource>.*/            <datasource>$dfschema<\/datasource>/" "/c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml";
    fi;

    #stop server
    stsdefault="Y";
    read -p "Stop Server? : [ Y ] " sts;
    if [ -z "$sts" ]; then
        sts=$stsdefault;
    fi;
    if [ $sts == "Y" ]; then
        echo "Stopping all servers."
        pida=$(box server stop --all) &
        wait $!
    fi;
};
## ################### ##
## Create AI Workspace ##
## ################### ##
function cw() {
    if [ -z "$1" ]; then
        pai=$(git rev-parse --abbrev-ref HEAD | xargs);
        pai=${pai:8:10}
        read -p "Need AI Number : [ $pai ] " ai;
        echo $ai;
        if [ -z "$ai" ]; then
            ai=$pai;
        fi;
    else
        ai=$1;
    fi;

    cwpath="/c/Users/KenOwens/Sites/NOTES/$ai";
    cwfile1="$ai.txt";
    cwfile2="$ai-files.txt";
    cwdate=$(date +"%D %T");

    command eval $(mkdir $cwpath);
    command eval $(touch $cwpath/$cwfile);

    echo "code /c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" >> $cwpath/$cwfile2;
    echo "#code /c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" >> $cwpath/$cwfile2;
    echo "#code /c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;
    echo "# only first three lines are read" >> $cwpath/$cwfile2;
    echo "# 1 - all files" >> $cwpath/$cwfile2;
    echo "# 2 - code files (cfm)" >> $cwpath/$cwfile2;
    echo "# 3 - sql files" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;
    echo $cwdate >> $cwpath/$cwfile1;
    echo "" >> $cwpath/$cwfile1;
    echo "username: $ai" >> $cwpath/$cwfile1;
    echo "password: mako\$SITH04#120" >> $cwpath/$cwfile1;
    echo "Hostname: cmproeastenc.cmprocloud.com" >> $cwpath/$cwfile1;
    echo "Port: 21521" >> $cwpath/$cwfile1;
    echo "SID: PSADB02" >> $cwpath/$cwfile1;
    echo "" >> $cwpath/$cwfile1;
    echo "= = = TESTING INSTRUCTIONS = = =" >> $cwpath/$cwfile1;
    echo "Please complete the following steps when testing this AI:"  >> $cwpath/$cwfile1;
    echo "1.) Use Data Source: <<cmpro_develop_view>> or $ai."  >> $cwpath/$cwfile1;
    echo "2.) Use this URL for testing: " >> $cwpath/$cwfile1;
    echo "-----"  >> $cwpath/$cwfile1;
    echo " https://devopscf2021.cmprocloud.com/cmpro-feature-$ai" >> $cwpath/$cwfile1;
    echo "-----"  >> $cwpath/$cwfile1;
    echo "3.) Create a test-logging document, or open an existing one, to capture the details of the testing.  ">> $cwpath/$cwfile1;
    echo "4.) Read and execute the \"TEST (QA)\" section of the attached change instructions. ">> $cwpath/$cwfile1;
    echo "5.) Act on any other annotations that may drive the active testing process." >> $cwpath/$cwfile1;
    echo "" >> $cwpath/$cwfile1;

};

function g() {
    # alias git with 4 args
    ar1=$1; ar2=$2; ar3=$3; ar4=$4; ar5=$5;
    if [ $1 == "s" ] && [ $2 == "l" ]; then
        ar1="stash";
        ar2="list";
    elif [ $1 == "s" ] && [ $2 == "p" ]; then
        ar1="stash";
        ar2="pop";
    elif [ $1 == "s" ]; then
        ar1="stash";
    elif [ $1 == "st" ]; then
        ar1="status";
    elif [ "$1" == "v" ]; then
        ar1="--version";
    elif [ "$1" == "h" ];then
        ar1="--help";
    else
        ar1=$1;
    fi;


    #echo $ar1 ":" $ar2 ":" $ar3 ":" $ar4 ":" $ar5
    #git $ar1 $ar2 $ar3 "$ar4" $ar5
    # "$ar4" works for quoted spaces, but breaks when $ar4 is ""
    git $ar1 $ar2 $ar3 $ar4 $ar5
};

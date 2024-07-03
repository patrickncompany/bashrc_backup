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
alias bsl='box server list'
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
        pai=${pai:8:11}
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
    # third line is open spec
    openSPEC="${cArray[3]}";
    # fourth line is spec 2
    openSPEC2="${cArray[4]}";
    echo;
    read -p "Open Files (1=all, 2=cfm, 3=sql, 4=spec, 5=spec2, 9=list, 0=None) : [ 0 ] " openPick;
    if [ -z "$openPick" ]; then
        openPick=0;
    fi;
    if [ $openPick -eq 1 ]; then
        eval $openAll;
    elif [ $openPick -eq 2 ]; then
        eval $openCFM;
    elif [ $openPick -eq 3 ]; then
        eval $openSQL;
    elif [ $openPick -eq 4 ]; then
        eval $openSPEC;
    elif [ $openPick -eq 5 ]; then
        eval $openSPEC2;
    elif [ $openPick -eq 9 ]; then
        # base file list on lines 2,3,4,5 not 1 (array 1,2,3)
        fpass=" --cfm--${cArray[1]} --sql--${cArray[2]} --spec--${cArray[3]} --spec2--${cArray[4]}";
        fpass=${fpass//"code"}; # remove code cmd
        fpass=${fpass//"/c/Users/KenOwens/Sites/cmpro/src/"}; # remove path to src (code pages)
        fpass=${fpass//"/c/Users/KenOwens/Sites/NOTES/$ai/"}; # remove path to notes (hyphen files in notes)
            #fpass=${fpass//"database/"}; # remove database
            #fpass=${fpass//"scripts/"}; # remove scripts
            #fpass=${fpass//"views/"}; # remove views
            #fpass=${fpass//"packages/"}; # remove packages
        echo -e ${fpass// /\\n}; # spaces to newline
        vsopen $ai; #after list call open with current ai to skip straigt to open options
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
        pai=${pai:8:11}
        #log
        devlog "$devdate, DEVSTART, derived ai : feature/$ai";
        read -p "Startup AI : [ $pai ] " ai;
        if [ -z "$ai" ]; then
            ai=$pai;
            # no need to switch
        else
            #log
            devlog "$devdate, DEVSTART, switch to feature/$ai";
            # switch to entered ai
            # git switch feature/$ai;
            gf $ai #use Talor's shortcut
        fi;
    else
        # ai passed in as arg
        ai=$1;
        # force switch
        # git switch feature/$ai;
        gf $ai #use Talor's shortcut
    fi;
    #log
    devlog "$devdate, DEVSTART, $ai";
    # parse stash list for auto wip
    # stash@{0}: On AI20220447: auto stash - AI20220447 WIP
    stpath="/c/Users/KenOwens/Sites/NOTES/$ai";
    stfile1="$ai-wip.txt";
    git stash list > $stpath/$stfile1;

    #log
    devlog "$devdate, DEVSTART, Looking for : auto stash - $ai WIP";

    # Must use this method to filter linefeed / carriage returns
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'cArray=($(cat "/c/Users/KenOwens/Sites/NOTES/$ai/$ai-wip.txt"))'
    for thisWIP in "${cArray[@]}"
    do
        # git update changed stash verbiage
        # thisAuto=${thisWIP:26:23};  # message when git created stash;
        thisAuto=${thisWIP:34:23};  # message when git created stash;
        # echo "thisAuto --> ($thisAuto)";
        thisPOP=${thisWIP:0:9};     # stash index
        thisAI=${thisWIP:14:10};    # ai when git created stash;
        # compare with $ai NOT $thisAI
        if [ "$thisAuto" == "auto stash - $ai" ]; then
            echo "Found stash.";
            git stash pop $thisPOP;
            #log
            devlog "$devdate, DEVSTART, git stash pop $thisPOP";
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
    cbs start;

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
        pai=${pai:8:11}
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
    #log
    devlog "$devdate, DEVSSTOP, $ai";
    # stash to ai wip
    echo "Stashing WIP for $ai";
    pida=$(git stash -u -m "auto stash - $ai WIP") &
    wait $!

    #log
    devlog "$devdate, DEVSSTOP, auto stash - $ai WIP";

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
    cbs stop;
};

# commandbox server (start)
function cbs(){
    defaultcba="start";
    if [ -z $1 ]; then
        read -p "Command Box Server ( start | stop | list ) : [ start ] " usercba;
        if [ -n $usercba ]; then
            cba=$usercba;
        else
            cba=$defaultcba;
        fi;
    else
        cba=$1;
    fi;

    if [ $cba != "list" ]; then
        # confirm all but list
        defaultcfa="Y";
        read -p "Confirm Server $cba (Y | N) : [ Y ]  " usercfa;
        if [ -z $usercfa ]; then
            cfa=$defaultcfa;
        else
            cfa=$usercfa;
        fi;
    fi;
    #echo "-----";
    #echo $cba;
    #echo $cfa;
    #echo "-----";

    if [ $cba == "start" ] && [ $cfa == "Y" ]; then
        echo "Stopping all servers."
        pida=$(box server stop --all) &
        wait $!
        echo "Starting server 2021."
        pidb=$(box server start 2021) &
        wait $!
    elif [ $cba == "stop" ] && [ $cfa == "Y" ];then
        echo "Stopping all servers."
        pida=$(box server stop --all) &
        wait $!
    elif [ $cba == "list" ];then
        echo "Getting server list."
        box server list
    else
        echo "Server state ignored."
    fi;

}
## ####################### ##
## Create Hyphen SQL Files ##
## ####################### ##
function stubsql() {
    ## default ai
    pai=$(git rev-parse --abbrev-ref HEAD | xargs);
    ## default stub
    cstb="N";
    ## select ai or default to current ai based on git
    if [ -z "$1" ]; then
        ## ai from git response
        pai=${pai:8:11}
        read -p "Need AI Number : [ $pai ] " ai;
        if [ -z "$ai" ]; then
            ai=$(echo $pai | tr '[:lower:]' '[:upper:]');
        fi;
    else
        echo "1=$1";
        ai=$(echo $1 | tr '[:lower:]' '[:upper:]');
    fi;
    ## sql to stub out hyphen sql files
    if [ -z "$2" ]; then
        echo "cstb = $cstb :: 2 = $2";
        read -p "Create Stub ? : [ $cstb | sql ] " sstb;
        if [ -z "$sstb" ]; then
            sstb=$cstb;
        fi;
    else
        echo "2=$2";
        ## sstb=$(echo $2 | tr '[:lower:]' '[:upper:]');
        sstb=$2;
    fi;

    ## if ai and stub sql then scaffold sql
    echo "ai=$ai :: sstb=$sstb";
    if [ -n "$ai" ] && [ "$sstb" == "sql"  ]; then
        cspath="src/database/scripts";
        csfile="$ai-pre.sql";
        csfile1="$ai-order.sql"; ## pre fill
        csfile2="$ai.sql";
        csfile3="$ai-post.sql";
        #command eval $(mkdir $cspath);
        command eval $(touch $cspath/$csfile);
        command eval $(touch $cspath/$csfile1);
        command eval $(touch $cspath/$csfile2);
        command eval $(touch $cspath/$csfile3);
        ## add ai to top of each file
        echo "-- $ai" >> $cspath/$csfile;
        echo "-- $ai" >> $cspath/$csfile1;
        echo "-- $ai" >> $cspath/$csfile2;
        echo "-- $ai" >> $cspath/$csfile3;
        ## pre fill -order with template
        echo "PROMPT *************************" >> $cspath/$csfile1;
        echo "PROMPT ***** "Pre" Scripts *****" >> $cspath/$csfile1;
        echo "PROMPT *************************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT *******************************************************" >> $cspath/$csfile1;
        echo "PROMPT ***** Create Tables / PK Indexes / PK Constraints *****" >> $cspath/$csfile1;
        echo "PROMPT *******************************************************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT *****************" >> $cspath/$csfile1;
        echo "PROMPT ***** Views *****" >> $cspath/$csfile1;
        echo "PROMPT *****************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT *******************" >> $cspath/$csfile1;
        echo "PROMPT ***** Indexes *****" >> $cspath/$csfile1;
        echo "PROMPT *******************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT ***********************" >> $cspath/$csfile1;
        echo "PROMPT ***** Constraints *****" >> $cspath/$csfile1;
        echo "PROMPT ***********************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT ********************" >> $cspath/$csfile1;
        echo "PROMPT ***** Triggers *****" >> $cspath/$csfile1;
        echo "PROMPT ********************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT *******************" >> $cspath/$csfile1;
        echo "PROMPT ***** Scripts *****" >> $cspath/$csfile1;
        echo "PROMPT *******************" >> $cspath/$csfile1;
        echo "-- @'scripts/sample.sql';" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT *****************" >> $cspath/$csfile1;
        echo "PROMPT **** Views 2 ****" >> $cspath/$csfile1;
        echo "PROMPT *****************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT ************************" >> $cspath/$csfile1;
        echo "PROMPT ***** Menu Scripts *****" >> $cspath/$csfile1;
        echo "PROMPT ************************" >> $cspath/$csfile1;
        echo "--None" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT ********************" >> $cspath/$csfile1;
        echo "PROMPT ***** Packages *****" >> $cspath/$csfile1;
        echo "PROMPT ********************" >> $cspath/$csfile1;
        echo "-- @'packages/sample.sql';" >> $cspath/$csfile1;
        echo "" >> $cspath/$csfile1;
        echo "PROMPT **************************" >> $cspath/$csfile1;
        echo "PROMPT ***** "Post" Scripts *****" >> $cspath/$csfile1;
        echo "PROMPT **************************" >> $cspath/$csfile1;
        echo "-- @'scripts/sample-post.sql';" >> $cspath/$csfile1;
    else
        echo "Could not create stub.";
    fi;

}

## ################### ##
## Create AI Workspace ##
## ################### ##
function cw() {
    ## default ai
    pai=$(git rev-parse --abbrev-ref HEAD | xargs);
    ## default stub
    cstb="N";
    ## select ai or default to current ai based on git
    if [ -z "$1" ]; then
        ## ai from git response - ONLY WORKS WITH feature/AIxxxxxxxx
        ## need to add prefix support for hotfix IE. hotfix/AIxxxxxxxx
        ## echo prefix=${pai:0:6} ## hofix
        ## would be better to find "AI" plus 8.
        ## wkai=${pai:(-10)}; Just get last 10.

        wkai=${pai:(-10)}; # AI from pai
        echo "Last 10 :: $wkai";

        # prefix=${wkai:0:6}; ## hotfix
        # if [ "$prefix" == "hotfix" ]; then
        #     pai=${pai:7:10}; ## hotfix/AIxxxxxxxx
        # fi;

        # prefix=${wkai:0:7} ## feature
        # if [ "$prefix" == "feature" ]; then
        #     pai=${pai:8:11}; ## feature/AIxxxxxxxx
        # fi;
        # pai=${pai:8:11}; ## feature/AIxxxxxxxx
        # pai=${pai:7:10}; ## hotfix/AIxxxxxxxx

        read -p "Need AI Number : [ $wkai ] " ai;
        echo $ai;
        if [ -z "$ai" ]; then
            ai=$wkai;
        fi;
    else
        ai=$1;
    fi;
    ## sql to stub out hyphen sql files
    if [ -z "$2" ]; then
        read -p "Create Stub ? : [ $cstb | sql ] " sstb;
        echo $sstb;
        if [ -z "$cstb" ]; then
            sstb=$cstb;
        fi;
    else
        sstb=$2;
    fi;

    command eval $(stubsql $ai $sstb);

    cwpath="/c/Users/KenOwens/Sites/NOTES/$ai";
    cwfile1="$ai.txt";
    cwfile2="$ai-files.txt";
    cwfile3="$ai-todo.txt";
    cwdate=$(date +"%D %T");

    command eval $(mkdir $cwpath);
    command eval $(touch $cwpath/$cwfile);

      ## this gets added to vsopen under spec files
    ## create ai-notes.txt
    echo "=================================================================================================" >> $cwpath/$cwfile3;
    echo "$cwdate" >> $cwpath/$cwfile3;
    echo "  () unfinished item" >> $cwpath/$cwfile3;
    echo "  (*) finished item" >> $cwpath/$cwfile3;
    echo "" >> $cwpath/$cwfile3;
    echo "=================================================================================================" >> $cwpath/$cwfile3;

    echo "# need to update so this file gets displayed on devstart" >> $cwpath/$cwfile3;
    ## create ai-files.txt
    echo "code /c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" >> $cwpath/$cwfile2;
    echo "code /c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" >> $cwpath/$cwfile2;
    echo "code /c/Users/KenOwens/Sites/cmpro/src/cmpro-alt.xml" >> $cwpath/$cwfile2;
    echo "code $cwpath/$cwfile3" >> $cwpath/$cwfile2;
    echo "code $cwpath/$cwfile3" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;
    echo "" >> $cwpath/$cwfile2;

    ## create ai.txt
    echo "# only first four lines are read" >> $cwpath/$cwfile2;
    echo "# 1 - all files" >> $cwpath/$cwfile2;
    echo "# 2 - code files (cfm)" >> $cwpath/$cwfile2;
    echo "# 3 - sql files" >> $cwpath/$cwfile2;
    echo "# 4 - misc files (ususally for reference)" >> $cwpath/$cwfile2;
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
    echo "4.) Read and execute the \"TEST INSTRUCTIONS\" section of the attached change instructions. ">> $cwpath/$cwfile1;
    echo "5.) Act on any other annotations that may drive the active testing process." >> $cwpath/$cwfile1;
    echo "" >> $cwpath/$cwfile1;

};
## ################### ##
##    Grep Workspace   ##
##     With Logging    ##
## ################### ##
function searchws() {
    if [ -z "$1" ]; then
        pai=$(git rev-parse --abbrev-ref HEAD | xargs);
        pai=${pai:8:11}
        read -p "Need AI Number : [ $pai ] " ai;
        echo $ai;
        if [ -z "$ai" ]; then
            ai=$pai;
        fi;
    else
        ai=$1;
    fi;

    # setup logging
    swpath="/c/Users/KenOwens/Sites/NOTES/$ai";
    swfile="$ai-search.log";
    swdate=$(date +"%D %T");
    echo "=================================================================================================" > $swpath/$swfile;
    echo "$swdate" >> $swpath/$swfile;

    #readarray -t cArray < "/c/Users/KenOwens/Sites/NOTES/$ai/$ai-search.txt";
    # Must use this method to filter linefeed / carriage returns
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'cArray=($(cat "/c/Users/KenOwens/Sites/NOTES/$ai/$ai-search.txt"))'
    # first line is open all
    searcList="${cArray[*]}";
    echo "Searching $ai" >> $swpath/$swfile;
    for word in $searcList;
        do
            echo "Searching $ai for $word";
            # -i no case, -r recursive, -m2 max 2 match, -n line number
            # match=$(grep -i -r -m1 -n "$word" /c/Users/KenOwens/Sites/cmpro/src/);
            # grep -ir --include \*.cfm "toddo" .
            # full recursive search of src (finds .git / .history)
            match=$(grep -i -n -r -m1 --include \*.cfm --include \*.cfc --include \*.js "$word" /c/Users/KenOwens/Sites/cmpro/src/);
            # search src
            # search src/javascript
            # search src/database
            # search src/database/functions
            # search src/database/packages
            # search src/database/procedures
            # search src/database/scripts
            # search src/database/triggers
            # search src/database/views
            if [ -n "$match" ]; then
                echo "$word match.";
                echo "$word" >> $swpath/$swfile;
                ##devlog "$devdate, searchws, $word match found";
            else
                echo "$word no $match";
                echo "($word)" >> $swpath/$swfile;
                ##devlog "$devdate, searchws, $word no match";
            fi;
    done
}

function devlog() {
    if [ -n "$1" ]; then
    devpath="/c/Users/KenOwens/Sites/NOTES/logs/";
    devfile1="dev.log";
    devdate=$(date +"%D %T");
    #log
    devlog="$devdate, NOFUNCTION, $1";
    echo $devlog >> $devpath/$devfile1;
    else
        echo "log string needed"
    fi;
}

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
    elif [ $1 == "l" ] && [ -z $2 ]; then
        ar1="log";
    elif [ $1 == "l" ] && [ $2 == "u" ]; then
        ar1="log";
        ar2="--author=$3";
        ar3="";
    elif [ $1 == "l" ] && [ $2 == "k" ]; then
        ar1="log";
        ar2="--author=kowens";
    elif [ $1 == "l" ] && [ $2 == "gr" ]; then
        ar1="log";
        ar2="--graph --decorate --oneline";
        #git log --graph --all --oneline --decorate
    elif [ $1 == "l" ] && [ -n $2 ]; then
        ar1="log";
        ar2="$2";
    else
        ar1=$1;
    fi;


    #echo $ar1 ":" $ar2 ":" $ar3 ":" $ar4 ":" $ar5
    #echo "git $ar1 $ar2 $ar3 $ar4 $ar5";
    # "$ar4" works for quoted spaces, but breaks when $ar4 is ""
    git $ar1 $ar2 $ar3 $ar4 $ar5
};


# testing for directory
function btest() {
    if [ ! -d logs ]; then
        echo "Parent Directory Missing";
    elif [ ! -d logs/NewFolder ];then
        echo "NewFolder NOT FOUND";
        echo "Create NewFolder";
        mkdir logs/NewFolder;
    else
        echo "Nothing to do.";
    fi;
}

# as single command
# replace \n with space
#if [ ! -d logs ]; then echo "Parent Directory Missing"; elif [ ! -d logs/NewFolder ];then echo "NewFolder NOT FOUND"; echo "Create NewFolder"; mkdir logs/NewFolder; else echo "Nothing to do."; fi;

function ctest() {
    if [ -z "$1" ]; then
        echo "zeebeeone";
    elif [ -n "$1" ];then
        echo "nnnbeeone";
    fi;
}

# used to delete old branches - list maintained in /c/Users/KenOwens/Sites/NOTES/git-clean-branches.txt
function git-clean-branch() {
    testmode="N";
    if [ -n "$1" ]; then
        if [ $1 == "-t" ]; then
            echo;
            echo "!! TEST MODE - NO CHANGES WILL BE MADE !!";
            testmode="Y";
        fi;
    fi;
    echo;
    echo "Switching to develop branch.";
    echo;
    gcod;
    #readarray -t branchARRAY < "/c/Users/KenOwens/Sites/NOTES/git-clean-branches.txt";
    # Must use this method to filter linefeed / carriage returns
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'branchARRAY=($(cat "/c/Users/KenOwens/Sites/NOTES/git-clean-branches.txt"))'
    echo;
    echo "Preparing to remove ${#branchARRAY[@]} old branches based on :";
    echo "     /c/Users/KenOwens/Sites/NOTES/git-clean-branches.txt";
    echo;
    #loop array
    echo "Old Branch List";
    for thisBranch in "${branchARRAY[@]}";
    do
        #echo $thisBranch;
        dInput="Y";
        read -p "Delete $thisBranch? Y or N: [Y]" uInput;
        if [ -z "$uInput" ]; then
            uInput=$dInput;
        fi;
        #echo $uInput;
        if [ $uInput == "Y" ]; then
            if [ $testmode == "Y" ];then
                echo;
                echo "TEST MODE >> git branch -D feature/$thisBranch";
                echo;
            else
                echo;
                git branch -D "feature/$thisBranch";
                echo;
            fi;
        else
            echo "Skipping $thisBranch";
        fi;

    done
};


#  USE CASE WITH REGEX WOULD BE BETTER?
#   read -p "Do you wish to install this program? " yn
#    case $yn in
#        [Yy]* ) make install; break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac

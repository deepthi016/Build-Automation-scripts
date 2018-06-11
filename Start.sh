#!/bin/sh

Toolname=$0
usage()
{
    echo -e "USAGE: ${Toolname} Environment "
    echo -e "Ex : ${Toolname} DEV1"
    exit 1
}

if [[ -d  $HOME ]]
then
        BASEDIR=$HOME/AutoDeploy
fi

LOGS=$BASEDIR/logs/
HOST=`hostname`
echo "Deployment started at $(date)"  >> $LOGS/DeployOut.log
echo "$2 Deployment started at $(date)"  > $BASEDIR/MailBody.txt

if [ $# -eq 0 ]
  then
    echo "No arguments supplied" >> $LOGS/DeployOut.log
    usage
elif [ $# -ne 2 ]
  then
    echo "Please check args" >> $LOGS/DeployOut.log
    usage
elif [ $# -eq 2 ]
  then
        touch $BASEDIR/Release.txt
        touch $BASEDIR/Path.txt
        scp <uid>@<server>:/opt/projects/tarfiles/TarfileDetails $BASEDIR/TarfileDetails
        if [[ -f $BASEDIR/TarfileDetails ]] && [[ -f $BASEDIR/properties.txt ]]
        then
                Path_Val=`grep -iw "$2" $BASEDIR/properties.txt`
                echo $Path_Val > $BASEDIR/Path.txt
                if [[ ! -z "$Path_Val" ]]
                then
                        Release=`grep -iw "$1" $BASEDIR/TarfileDetails`
                        echo $Release > $BASEDIR/Release.txt
                        Env=`awk -F":" '{ print $1 }' $BASEDIR/Path.txt`
                        echo "Env:"$Env >> $LOGS/DeployOut.log
                        Project=`awk -F":" '{ print $2 }' $BASEDIR/Path.txt`
                        echo "Project:"$Project >> $LOGS/DeployOut.log
                        Server=`awk -F":" '{ print $3 }' $BASEDIR/Path.txt`
                        echo "Server:"$Server >> $LOGS/DeployOut.log
                        awk -F":" '{ print "Env:"$1 "\n" "Project:" $2 "\n" "Server:" $3 "\n" "Path:" $4 }' $BASEDIR/Path.txt >> $BASEDIR/MailBody.txt
                        if [ "$Server" = "$HOST" ] && [ "$Project" != "" ] && [ "$Server" != "" ] 
                        then
                                nohup $BASEDIR/DeployEnv.sh $Project $Server > /dev/null 2>&1 >>$LOGS/DeployOut.log &
                        else
                                echo "Deployment failed- Invalid Project/server" >> $LOGS/DeployOut.log 
                                usage
                        fi
                else
                echo "Path value not existing" >> $LOGS/DeployOut.log
                usage
                fi
        else
        echo "Argument/TarfileDetails not found" >> $LOGS/DeployOut.log
        usage
        fi
fi

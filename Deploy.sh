#!/bin/sh

Toolname=$0
usage()
{
    print "USAGE: ${Toolname} Domain Version EnvName"
    print "          ${Toolname} project1 server"
    exit 1
}

echo "Env Validation complted."


if [[ -d  $HOME ]]
then
        BASEDIR=$HOME/AutoDeploy
fi

LOGS=$BASEDIR/logs

echo "Env Validated" >> $BASEDIR/MailBody.txt

if [[ $# -eq 2 ]]
then

        VERSION=`cat $BASEDIR/ActiveVersion.txt` >> $LOGS/DeployOut.log

        Server=$2 >> $LOGS/DeployOut.log

        Path=`awk -F":" '{ print $4 }' $BASEDIR/Path.txt`
        echo "Path:"$Path >> $LOGS/DeployOut.log

        Ext_Path=`awk -F":" '{ print $5 }' $BASEDIR/Path.txt`
        echo "Ext_Path:"$Ext_Path >> $LOGS/DeployOut.log

        Int_Path=`awk -F":" '{ print $6 }' $BASEDIR/Path.txt`
        echo "Int_Path:"$Int_Path >> $LOGS/DeployOut.log

        CODE_PATH=$Path
        COMP_PATH=$Path/components
        Build_Path=/home/tools/projects/tarfiles

        #Get tarfiles from Build server
        Rel_Value=`cat $BASEDIR/Release.txt`
        scp gwsbuild@rcolnx88888:$Build_Path/$Rel_Value/*.tar $BASEDIR/Tarfiles

        echo "Deploying code for" $Rel_Value >> $LOGS/DeployOut.log 

        #Deploy to Env
        if [ -d $COMP_PATH ] && [ -e $BASEDIR/Tarfiles/*.tar ]
        then
                #stop the servers
                ssh -l <uid> $Server "cd ${Path}; ./stopAll.sh " >> $LOGS/DeployOut.log
                sleep 60

                cd $COMP_PATH
                rm -rf *.tar >> $LOGS/DeployOut.log
                rm -rf *$VERSION >> $LOGS/DeployOut.log
                ssh -l uid $Server "cd ${CODE_PATH}; rm -rf abc* " >> $LOGS/DeployOut.log
                cd $COMP_PATH >> $LOGS/DeployOut.log
                cp $BASEDIR/Tarfiles/*.tar . >> $LOGS/DeployOut.log
                tar -xvf *.tar >> $LOGS/DeployOut.log
                mv abc-ear-$VERSION.tar $CODE_PATH >> $LOGS/DeployOut.log
                ./untar.sh $VERSION >> $LOGS/DeployOut.log
                cd $CODE_PATH >> $LOGS/DeployOut.log 
                tar -xvf abc-ear-$VERSION.tar >> $LOGS/DeployOut.log

                TarName=`basename $BASEDIR/Tarfiles/*.tar`
                cd $BASEDIR/Tarfiles
                rm $TarName 
                cd $COMP_PATH
                rm $TarName

                #start the servers
                ssh -l uid $Server "cd ${Ext_Path}; ./start.sh " >> $LOGS/DeployOut.log
                sleep 60
        else
                echo "Exit deployment"
                usage
        fi

        echo "Deployment completed $(date)" >> $LOGS/DeployOut.log
        
else
        echo "Invalid Arguments supplied" >> $LOGS/DeployOut.log
fi

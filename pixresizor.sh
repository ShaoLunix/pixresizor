#!/bin/bash

#==============================================================================#
# Versions
# [2019-08-19] [1.0.0.1] [Stéphane-Hervé]
#==============================================================================#
VER=1.0.0.1

# strict mode
set -o nounset

myscript="pixresizor"
mycontact="https://github.com/ShaoLunix/pixresizor/issues"



#===========#
# VARIABLES #
#===========#
# Definition of the variables
islinecounteron=""
linenumber=""
inputfile=""
isinputfile=false
outputfile=""
isoutputfile=false
quality=""
resolution=""
size=""



#========#
# IMPORT #
#========#
#. pixresizor.conf



#============#
# FUNCTIONS  #
#============#
# Abnormal exit
abnormalExit()
{
    echo "$myscript -- End -- Failed"
    exit 2
}

# Prerequisite not met
prerequisitenotmet()
{
    echo "ImageMagick is missing. Please, install it first and check you can access the command 'convert'."
    echo "Programm aborted."
    exit 1
}

# Aborting the script because of a wrong or missing parameter
usage()
{
    echo "Usage: $myscript [-h] [-i INPUTFILE] [-n NUMBER] [-o OUTPUTFILE] [-q QUALITY] [-r RESOLUTION] [-s SIZE] [-v]"
    echo "For more information on how to use the script, type : < $myscript -h >"
    echo "$myscript -- End -- failed"
    exit 1
}

# display the help of this script
displayhelp()
{
    echo "Syntax : $myscript [OPTION ...]"
    echo "WHAT THE SCRIPT DOES based on the values passed with the arguments -lnx."
    echo
    echo "With no option, the command returns ..."
    echo
    echo "$myscript [-i INPUTFILE] [-n NUMBER] [-o OUTPUTFILE] [-q QUALITY] [-r RESOLUTION] [-s SIZE]"
    echo "$myscript [-h]"
    echo "$myscript [-v]"
    echo
    echo "  -h :                display the help."
    echo "  -i INPUTFILE:       where INPUT is the file to be processed."
    echo "  -n :                counter of lines. It starts every line with its number."
    echo "  -o OUTPUTFILE:      where OUTPUTFILE is the destination file after processing."
    echo "  -q QUALITY:         where QUALITY is the quality of the picture. Then quality can be any number from 1 (lowest) to 100 (highest)."
    echo "  -r RESOLUTION:      where RESOLUTION is the resolution to apply to the picture."
    echo "  -s SIZE:            where SIZE is the dimensions of the picture. The dimensions can be fully indicated (WIDTHxHEIGHT) or partially indicated (WIDTHx , xHEIGHT). Then only the indicated dimension will be applied ; the other dimension will be calculated respecting the original scale."
    echo "  -v :                this script version."
    echo
    echo "..."
    echo
    echo "Exit status : "
    echo " 0 = success"
    echo " 1 = failure due to wrong parameters or prerequisites have not been met"
    echo " 2 = abnormal exit"
    echo
    echo "To inform about the problems : $mycontact."
    exit
}

# management of exit signals
trap 'abnormalExit' 1 2 3 4 15



#====================#
# TEST PREREQUISITES #
#====================#
if ! type "convert" > /dev/null 2>&1
    then prerequisitenotmet
fi



#=======#
# Flags #
#=======#
# -h : display the help
# -i : input file (compulsory)
# -n : counter of lines. It starts every line with its number
# -o : output file (compulsory)
# -q : quality of the picture
# -r : resolution  of the picture
# -s : size of the picture
# -v : this script version
while getopts "hi:no:q:r:s:v" option
do
    case "$option" in
        h)
            displayhelp
            exit
            ;;
        i)
            inputfile=${OPTARG}
            if [[ -z "$inputfile" ]]
                then usage
                else isinputfile=true
            fi
            ;;
        n)
            islinecounteron=true
            ;;
        o)
            outputfile=${OPTARG}
            if [[ -z "$outputfile" ]]
                then usage
                else isoutputfile=true
            fi
            ;;
        q)
            quality=${OPTARG}
            if [[ -n "$quality" ]]
                then quality="-quality $quality"
            fi
            ;;
        r)
            resolution=${OPTARG}
            if [[ -n "$resolution" ]]
                then resolution="-density $resolution"
            fi
            ;;
        s)
            size=${OPTARG}
            if [[ -n "$size" ]]
                then size="-resize $size"
            fi
            ;;
        v)
            echo "$myscript -- Version $VER -- Start"
            date
            exit
            ;;
        \? ) # For invalid option
            usage
            ;;
    esac
done

# Test that compulsory flags were valued
if [[ "$isinputfile" == false ]] || [[ "$isoutputfile" == false ]]
    then usage
fi



#======#
# MAIN #
#======#
#
convert "$inputfile" $resolution $size $quality "$outputfile"


exit

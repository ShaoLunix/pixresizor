#!/bin/bash

#==============================================================================#
# Versions
# [2019-XX-XX] [1.0] [Stéphane-Hervé] First version
#==============================================================================#
VER=1.0

# strict mode
set -o nounset
#set -x

myscript="batchpixresizor"
mycontact="https://github.com/ShaoLunix/pixresizor/issues"



#===========#
# VARIABLES #
#===========#
# Definition of the variables
# -> DIRECTORY
inputdirectory=""
isinputdirectory=false
# -> FILE
inputfile=""
isinputfile=false
outputfile=""
isoutputfile=false
filename=""
basename=""
ext="*"
isextension=false
# -> OPTIONS
configuredoptions=""
isalloptionsincluded=false
quality=""
resolution=""
size=""
# -> OTHERS
islinecounteron=""



#========#
# IMPORT #
#========#
. batchpixresizor.conf



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
    echo "ImageMagick or pixresizor.sh is missing. Please, install it first and check you can access the command 'convert'."
    echo "Programm aborted."
    exit 1
}

# Aborting the script because of a wrong or missing parameter
usage()
{
    echo "Usage: $myscript [-a] [-d DIRECTORY] [-e EXTENSION] [-h] [-i FILEINPUT] [-n NUMBER] [-o FILEOUTPUT]"
    echo "[-q QUALITY] [-r RESOLUTION] [-s SIZE] [-v]"
    echo "For more information on how to use the script, type : < $myscript -h >"
    echo "$myscript -- End -- failed"
    exit 1
}

# display the help of this script
displayhelp()
{
    echo "NAME"
    echo "      $myscript - convert a single image or a batch of images."
    echo
    echo "USAGE"
    echo "      $myscript [OPTION ...]"
    echo
    echo "SYNOPSIS"
    echo "      $myscript [-a] [[-e EXTENSION] [-n NUMBER]]"
    echo "      $myscript [-q QUALITY] [-r RESOLUTION] [-s SIZE] [[-d DIRECTORY]|[-i FILEINPUT]] [-o FILEOUTPUT]"
    echo "      $myscript [-h]"
    echo "      $myscript [-v]"
    echo
    echo "DESCRIPTION"
    echo "      Convert an image according to the operands or a batch of images according to the configuration file."
    echo "      -a :        all the options of the configuration file are included."
    echo "      -d :        directory input : all the images in this directory are processed."
    echo "      -e :        the extension of the image to be processed."
    echo "      -h :        display the help."
    echo "      -i :        file input : what image to process."
    echo "      -n :        counter of lines. It starts every line with its number."
    echo "      -o :        file output : the file to write to after processing."
    echo "      -q :        quality of the image (from 0 to 100)."
    echo "      -r :        resolution of the image (in DPI)."
    echo "      -s :        size of the image after processing."
    echo "      -v :        this script version."
    echo
    echo "Without the option [-a], then either the input directory [-d DIRECTORY] or the input file [-i FILEINPUT] is compulsory. " \
    echo "The file output option [-o FILEOUTPUT] is obviously compulsory too."
    echo "The input/output elements must be mentioned at the end of the line."
    echo
    echo "EXIT STATUS"
    echo "      0 = success"
    echo "      1 = failure due to wrong parameters or prerequisites have not been met"
    echo "      2 = abnormal exit"
    echo
    echo "AUTHOR"
    echo "      Written by Stéphane-Hervé."
    echo
    echo "REPORTING BUGS"
    echo "      Report any problems to <$mycontact>."
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
# -a : all the options of the configuration file are included.
# -d : directory input
# -e : extension
# -h : display the help
# -i : file input (compulsory)
# -n : counter of lines. It starts every line with its number
# -o : file output (compulsory)
# -q : quality of the picture
# -r : resolution  of the picture
# -s : size of the picture
# -v : this script version
while getopts "ad:e:hi:no:q:r:s:v" option
do
    case "$option" in
        a)
            isalloptionsincluded=true
            ;;
        d)
            inputdirectory=${OPTARG}
            if [[ -z "$inputdirectory" ]]
                then usage
                else isinputdirectory=true
            fi
            outputdirectory="$inputdirectory"/"processed"
            mkdir -p "$outputdirectory"
            ;;
        e)
            ext=${OPTARG}
            if [[ -z "$ext" ]]
                then usage
                else
                    isextension=true
                    # conversion to lower case
                    ext="${ext}"
            fi
            ;;
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

#======#
# MAIN #
#======#

# Include all the configured parameters
if [[ "$isalloptionsincluded" == true ]]
    then . optionsgenerator.sh
fi

# Test that compulsory flags are valued
if [[ "$isinputdirectory" == true ]]
    then
        for filename in "$inputdirectory"/*."$ext"
        do
            basename="$(basename "$filename" ."$ext")"
            ./pixresizor.sh "$inputdirectory/$basename.$ext" $resolution $size $quality "$outputdirectory/$basename.$ext"
        done
elif [[ "$isalloptionsincluded" == false ]]
    then
        if [[ "$isinputfile" == false ]] || [[ "$isoutputfile" == false ]]
            then usage
            else ./pixresizor.sh "$inputfile" $resolution $size $quality "$outputfile"
        fi
else
    # Process each file of the regarded extension
    for file in "$sourcepath"/*."$ext"
    do
        # Extracting the basename
        filename=${file##*/}
        basename=${filename%.$ext}

        for ((i=1;i<="$numberofcopies";i++))
        do
            # Converting variables for incremental substitution
            resolution="resolution_$i"
            size="size_$i"
            quality="quality_$i"
            destpath="dest_path_$i"

            # If the path doesnot exist then it is created
            if [[ ! -d ${!destpath} ]]
                then mkdir -p ${!destpath}
            fi

            # Displaying the current processing and its number
            if [[ "$islinecounteron" == true ]]
                then
                    echo "$i : resizing $basename.$ext : " \
                         "$resolutionunit ; ${!resolution} ; ${!size} ; ${!quality} ; " \
                         "$configuredoptions"
            fi

            # Executing the file processing
            convert -density "${!resolution}" \
                            -resize "${!size}" \
                            -quality "${!quality}" \
                            $configuredoptions \
                            "$sourcepath"/*".$ext" \
                            "${!destpath}/$basename.$ext"
        done
    done
fi

exit

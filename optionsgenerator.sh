 #!/bin/bash

#***********#
# VARIABLES
#***********#
configuredoptions=""
profile=""
isprofileexception=false
isexcludedchunk=false
exceptexif=""
exceptxmp=""
exceptiptc=""
excepticc=""
excludedchunk=""
interlace=""
thumbnail=""
compression=""



#******************#
# CREATING OPTIONS
#******************#

# RESOLUTION
#*************
# Creating the resolution unit option
resolutionunit="-units $resolutionunit"

# PROFILE
#**********
# Creating the profile options
if [[ "$keepcolourprofile" == "yes" ]]; then isprofileexception=true; excepticc="!ICC,"; fi
if [[ "$keepexif" == "yes" ]]; then isprofileexception=true; exceptexif="!EXIF,"; fi
if [[ "$keepiptc" == "yes" ]]; then isprofileexception=true; exceptiptc="!IPTC,"; fi
if [[ "$keepxmp" == "yes" ]]; then isprofileexception=true; exceptxmp="!XMP,"; fi

if [[ "$keepprofile" == "no" ]] && [[ "$isprofileexception" == true ]]
    then
        profile="-define +profile \"""$excepticc""$exceptexif""$exceptiptc""$exceptxmp""*\""
elif [[ "$keepprofile" == "no" ]] && [[ "$isprofileexception" == false ]]
    then profile="-define profile:skip=\"*\""
fi

# with the removal of some more elements
if [[ "$ext" == "png" ]] && [[ "$keepgamma" == "no" ]]; then isexcludedchunk=true; excludedchunk="gAMA,"; fi
if [[ "$keepcomment" == "no" ]]; then isexcludedchunk=true; excludedchunk="$excludedchunk""iTXT,"; fi
if [[ "$keepcreationtime" == "no" ]]; then isexcludedchunk=true; excludedchunk="$excludedchunk""date,"; fi
# adding to the previously created profile
# without the final comma
if [[ "$isexcludedchunk" == true ]] && [[ ! -z "$ext" ]]
    then  profile="$profile -define $ext:exclude-chunk=${excludedchunk::-1}"
fi

# ADVANCED OPTIONS
#*******************
# -> PROGRESSIVE
# -> INTERLACING
# According to the extension of the image
# And if the progressive (JPEG) or the interlacing (PNG) option is required
if [[ "$ext" == "jpg" ]] || [[ "$ext" == "jpeg" ]]
    # Create a progressive JPEG image
    then
        if [[ "$progressive" == "yes" ]]; then interlace="-interlace plane"; fi
elif [[ "$ext" == "png" ]] && [[ "$interlacing" == "yes" ]]
    # Interlacing
    then interlace="-interlace plane"
elif [[ "$progressive" == "yes" ]] || [[ "$interlacing" == "yes" ]]
    then interlace="-interlace plane"
fi
# -> THUMBNAIL
# If keepthumbnail is yes AND thumbnail geometry is valued then create the option
# Else no need to do anything
if [[ "$keepthumbnail" == "yes" ]] && [[ ! -z "$thumbnailgeometry" ]]
    then thumbnail="-thumbnail $thumbnailgeometry"
fi

#******
# PNG
if [[ "$ext" == "png" ]] && [[ ! -z "$compressionlevel" ]]
    then compression="-define png:compression-level=$compressionlevel"
fi

#*********************************#
# CREATING THE CONFIGURED OPTIONS
#*********************************#
configuredoptions="$resolutionunit $profile $compression $interlace $thumbnail"


#==========================================
# Advanced options
#optimization=yes

#******
# PNG
#keepbackgroundcolor=no
#keeplayeroffset=no
#keepcolourfromtransparent=no


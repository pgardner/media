#!/usr/bin/env zsh
# Appropriate setting are initialized in .zshenv

usage()
{
  echo "Usage: media.sh [ -f | --folder ]
                         [ -s | --stage ]
                         [ -p | --publish ] 
                         [ -a | --archive ]
                         [ -c | --clean ]"
  echo
  echo "NOTE: This process assumes the current date"
  echo "and that the overall process will be completed"
  echo "within the same calendar day."
  exit 2
}

#
# Initialize some settings
#
export STAGE_DIR_COUNT=$(ls ${STAGE_PARENT_DIR} | grep media-${CURRENT_DATE} | grep -v zip | wc -l | awk {'print $1'})

if (( ${STAGE_DIR_COUNT} > 0 )); then
  echo "Found one or more staging folders. Determining newest."
  export STAGE_DIR=${STAGE_PARENT_DIR}/$(ls ${STAGE_PARENT_DIR} | grep media-${CURRENT_DATE} | grep -v zip | tail -1)
  echo "Staging folder found as ${STAGE_DIR}"
fi

#
# Set some functions
#
folder()
{
  echo "Creating staging folder ${STAGE_DIR}"
  export STAGE_DIR=${STAGE_PARENT_DIR}/media-${CURRENT_DATE}-${CURRENT_TIME}
  mkdir -v ${STAGE_DIR}
}

stage()
{
  echo "Copying media from source folder to staging folder."
  if [[ -d ${STAGE_DIR} && -d ${SOURCE_DIR} ]] && cp -v ${SOURCE_DIR}/* ${STAGE_DIR}
}

publish()
{
  echo "Publishing to target."
  if [[ -d ${STAGE_DIR} && -d ${TARGET_DIR} ]] && cp -rv ${STAGE_DIR} ${TARGET_DIR}
}

archive()
{
  echo "Archiving and removing staging folder."
  if [[ -d ${STAGE_DIR} ]] && zip -r ${STAGE_DIR}.zip ${STAGE_DIR}/
  if [[ $? -eq 0 ]] && rm -rf ${STAGE_DIR}
}

clean()
{
  echo "Cleaning source folder."
  rm -v ${SOURCE_DIR}/*
}

PARSED_ARGUMENTS=$(getopt -a -n alphabet -o spac --long folder,stage,publish,archive,clean -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

# echo "PARSED_ARGUMENTS is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -f | --folder) folder ; shift ;;
    -s | --stage) stage ; shift ;;
    -p | --publish) publish ; shift ;;
    -a | --archive) archive ; shift ;;
    -c | --clean) clean ; shift ;;
    # -a | --alpha)   ALPHA=1      ; shift   ;;
    # -b | --beta)    BETA=1       ; shift   ;;
    # -c | --charlie) CHARLIE="$2" ; shift 2 ;;
    # -d | --delta)   DELTA="$2"   ; shift 2 ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *) echo "Unexpected option: $1 - ERROR"
       usage ;;
  esac
done

echo "Run complete"
exit 0

# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

# The class to append/remove flags to/from /etc/chrome_dev.conf
RDEPEND="chromeos-base/chromeos-login"
DEPEND="${RDEPEND}"
#the flags need be added"
#CHROME_DEV_FLAGS=""
#the flags need be removed"
#CHROME_REMOVE_FLAGS=""
CHROME_TMP_CONFIG="chrome_dev.conf"
CHROME_TMP_UI="ui.override"

S=${WORKDIR}

check_file() {
  if [ ! -f $1 ]; then
     eerror "$1 doesn't exist."
  fi
}

append_flags() {
    local chrome_dev=$CHROME_TMP_CONFIG
    for flag in $@; do
      if [ -z "`grep -e $flag $chrome_dev`" ]; then
        echo $flag >> $chrome_dev
      fi
    done
}

remove_flags() {
    local chrome_dev=$CHROME_TMP_CONFIG
    for flag in $@; do
        sed -i "/${flag}/d" $chrome_dev
    done
}

append_flags_ui() {
    flags="env CHROME_COMMAND_FLAG=\"$@\""
    echo $flags > $CHROME_TMP_UI
}

src_compile() {
    check_file ${ROOT}/etc/chrome_dev.conf
    grep -e "^#" ${ROOT}/etc/chrome_dev.conf > $CHROME_TMP_CONFIG
    local dev_flags=""
    for dev_flag in $CHROME_DEV_FLAGS; do
      dev_flag=${dev_flag#--}
        for rm_flag in $CHROME_REMOVE_FLAGS; do
          rm_flag=${rm_flag#--}
          if [ "$rm_flag" == "$dev_flag" ]; then
            continue 2
          fi
        done
      dev_flags+=" --${dev_flag}"
    done
    append_flags $dev_flags
    append_flags_ui $dev_flags
}

src_install() {
    insinto /etc
    doins $CHROME_TMP_CONFIG
    insinto /etc/init
    doins $CHROME_TMP_UI
}

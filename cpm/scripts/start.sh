#!/system/bin/sh

scripts_dir="/data/adb/cpm/scripts"
file_settings="/data/adb/cpm/settings.ini"

moddir="/data/adb/modules/clashpro_magisk"
[ -n "$(magisk -v | grep lite)" ] && moddir="/data/adb/lite_modules/clashpro_magisk"

busybox="/data/adb/magisk/busybox"
[ -f "/data/adb/ksu/bin/busybox" ] && busybox="/data/adb/ksu/bin/busybox"

refresh_cpm() {
  if [ -f "/data/adb/cpm/run/cpm.pid" ]; then
    "${scripts_dir}/cpm.service" stop >> "/dev/null" 2>&1
    "${scripts_dir}/cpm.iptables" disable >> "/dev/null" 2>&1
  fi
}

start_service() {
  if [ ! -f "${moddir}/disable" ]; then
    "${scripts_dir}/cpm.service" start >> "/dev/null" 2>&1
  fi
}

enable_iptables() {
  PIDS=("clash" "xray" "sing-box" "v2fly")
  PID=""
  i=0
  while [ -z "$PID" ] && [ "$i" -lt "${#PIDS[@]}" ]; do
    PID=$($busybox pidof "${PIDS[$i]}")
    i=$((i+1))
  done

  if [ -n "$PID" ]; then
    "${scripts_dir}/cpm.iptables" enable >> "/dev/null" 2>&1
  fi
}

start_memless() {
   "${scripts_dir}/memless" >> "/dev/null" 2>&1
}

start_inotifyd() {
  PIDs=($($busybox pidof inotifyd))
  for PID in "${PIDs[@]}"; do
    if grep -q "cpm.inotify" "/proc/$PID/cmdline"; then
      kill -9 "$PID"
    fi
  done
  inotifyd "${scripts_dir}/cpm.inotify" "${moddir}" >> "/dev/null" 2>&1 &
}

mkdir -p /data/adb/cpm/run/
if [ -f "/data/adb/cpm/manual" ]; then
  exit 1
fi

if [ -f "$file_settings" ] && [ -r "$file_settings" ] && [ -s "$file_settings" ]; then
  refresh_cpm
  start_service
  enable_iptables
  start_memless
fi

start_inotifyd

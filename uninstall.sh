#!/system/bin/sh

cpm_data_dir="/data/adb/cpm"
rm_data() {
  if [ ! -d "${cpm_data_dir}" ]; then
    exit 1
  else
    rm -rf "${cpm_data_dir}"
  fi
  
  if [ -f "/data/adb/ksu/service.d/cpm_service.sh" ]; then
    rm -rf "/data/adb/ksu/service.d/cpm_service.sh"
  fi

  if [ -f "/data/adb/service.d/cpm_service.sh" ]; then
    rm -rf "/data/adb/service.d/cpm_service.sh"
  fi

}

rm_data
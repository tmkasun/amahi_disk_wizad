class DiskServiceController < ApplicationController
  def get_all_devices
    # probe_kernal
    mounted_disks = Device.mounts
    new_disks = Device.new_disks
  end

  def check_label
    render text: "check_label"
  end
end

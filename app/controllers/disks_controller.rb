class DisksController < ApplicationController
  layout 'disk_wizard'
  require "disk_tools"
  def select_device
    @mounted_disks = DiskUtils::mounts
  end

  def select_fs

  end

  def manage_disk

  end

  def done

  end

end

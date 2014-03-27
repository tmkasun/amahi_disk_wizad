class DisksController < ApplicationController
  layout 'disk_wizard'
  
  def select_device
    @mounted_disks = Disk.mounts
    @new_disks = Disk.new_disks
    # render text: "#{@new_disks} </br></br></br></br></br> #{@mounted_disks}"
  end

  def select_fs

  end

  def manage_disk

  end

  def done

  end

end

class DisksController < ApplicationController
  layout 'disk_wizard'
  
  def select_device
    @mounted_disks = Disk.mounts
    @new_disks = Disk.new_disks
    # render text: "#{@new_disks} </br></br></br></br></br> #{@mounted_disks}"
  end

  def select_fs
    flash[:error] = "This will completely erase this new drive! Make sure the selected hard drive is the drive you'd like to erase."
    device = params[:device]
    partition = params[:partition]
    unless device or partition
      flash[:error] = "You should select a Device or a Partition to continue with the Disk-Wizard"
      redirect_to select_path
      return false
    end
    
  end

  def manage_disk

  end

  def done

  end

end

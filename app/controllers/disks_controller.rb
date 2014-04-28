class DisksController < ApplicationController
  layout 'disk_wizard'
  def select_device
    @mounted_disks = Disk.mounts
    @new_disks = Disk.new_disks
  # render text: "#{@new_disks} </br></br></br></br></br> #{@mounted_disks}"
  end

  def select_fs
    device = params[:device]
    format = params[:format]
    if not device
      redirect_to select_path, :flash => { :error => "You should select a Device or a Partition to continue with the Disk-Wizard" }
    return false
    elsif not format
      redirect_to manage_path and return
    end
    flash[:error] = "This will completely erase this new drive! Make sure the selected hard drive is the drive you'd like to erase."
    @selected_disk = Disk.find device
    # puts "DEBUG *************************************#{device}"
    self.user_selections = {kname: device,format: format}
  end

  def manage_disk

  end

  def done

  end

  def user_selections
    return JSON.parse session[:user_selections] rescue nil
  end
  helper_method :user_selections

  def user_selections=(hash)
    puts "DEBUG *********************** hash{hash}"
    session[:user_selections] = hash.to_json
    puts "DEBUG ************************** session[:user_selections] #{session[:user_selections]}"
  end

end

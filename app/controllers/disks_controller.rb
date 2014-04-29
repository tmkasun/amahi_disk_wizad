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
    self.user_selections = {kname: device,format: format} if device or format
    puts device
    if not(device or user_selections['kname'])
      redirect_to select_path, :flash => { :error => "You should select a Device or a Partition to continue with the Disk-Wizard" }
      return false
    elsif (not format and request.post?)
      redirect_to manage_path and return
    end
    flash[:error] = "This will completely erase this new drive! Make sure the selected hard drive is the drive you'd like to erase."
    @selected_disk = Disk.find(device || user_selections['kname'])
    # puts "DEBUG *************************************#{device}"

  end

  def manage_disk
    device = params[:device]
    fs_type = params[:fs_type]
    if (not(fs_type or user_selections['fs_type']) and not user_selections['kname'])
      redirect_to file_system_path, :flash => { :error => "You should select a filesystem to continue with the Disk-Wizard" }
      return false
    end
    self.user_selections = {fs_type: fs_type}
    # render text: "params = #{params} and  user_selections #{user_selections}"
  end

  def confirmation
    option = params[:option]
    self.user_selections = {option: option}
    render text: params[:option]
  end

  def done

  end

  def user_selections
    return JSON.parse session[:user_selections] rescue nil
  end
  helper_method :user_selections

  def user_selections=(hash)
    current_user_selections = user_selections
    unless current_user_selections
      session[:user_selections] = hash.to_json and return
    end
    puts "DEBUG *********************** hash{hash}"
    hash.each do |key,value|
      current_user_selections[key] = value
    end
    session[:user_selections] = current_user_selections.to_json
    puts "DEBUG ************************** session[:user_selections] #{session[:user_selections]}"
  end

end

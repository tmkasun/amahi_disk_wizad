#Since no database involvement in the model, data is fetch on the fly by parsing the result of system calls
# inheriting ActiveRecord::Base is not necessary
class Disk #< ActiveRecord::Base

  require "disk_tools"

  def initialize disk
    @model = disk['model']
    @uuid = disk['uuid']
    @size = disk['size']
    @kname = disk['kname']
    @sectors = disk['sectors']
    @partitions = disk['partitions']
  end

  def partitions device
    raise "#{__method__} method not implimented !"

  end

  def new_disk? disk
    raise "#{__method__} method not implimented !"

  end

  def removable?
    # assuming is_removable? method accepts Disk objects
    DiskUtils.is_removable? self
  end

  def self.format_job params_hash
    puts "DEBUG:********** format_job params_hash #{params_hash}"
    # self.progress = 10
    disk = params_hash[:kname]
    fs_type = params_hash[:fs_type]
    parted_object = Parted.new disk
    puts "DEBUG:********** parted_object #{parted_object}"
    partition_table = parted_object.partition_table
    # self.progress = 20
    puts "DEBUG:********** partition_table =  #{partition_table}"
    #TODO: check the disk size and pass the relevent partition table type (i.e. if device size >= 3TB create GPT table else MSDOS(MBR))
    #TODO: check returned value for errors
    parted_object.create_partition_table unless partition_table
    return parted_object.format fs_type
  end
  
  def options_job params_hash
    kname = params_hash[:kname]
    mount_point = "/media/#{kname}" # in production this path is /var/hda/files/drives/drive#
    puts "DEBUG:********** options_job.params_hash #{params_hash}"
    Command.new("mkdir #{mount_point}").run_now
    fstab_object = Fstab.new
    # fstab_object.add_fs('/dev/sde','/media/sde','auto','auto,rw,exec',0,0)
    Command.new("mount -a").run_now
  end

  def self.process_queue jobs_queue
    while(not jobs_queue.empty?)
      job =  jobs_queue.dequeue
      puts "DEBUG: ******************process_queue #{job[:job_name]} job[:para] #{job[:para]}"
      Disk.send(job[:job_name],job[:para]) rescue false
    end
  end

  def self.progress
    current_progress = Setting.find_by_kind_and_name('disk_wizard', 'operation_progress')
  end

  def self.progress_message(percent)
    case percent
    when 0 then "Preparing to partitioning ..."
    when 10 then "Looking for partition table ..."
    when 100 then "Disk operations completed."
    when 999 then "Fail (check /var/log/amahi-app-installer.log)."
    else "Unknown status at #{percent}% ."
    end
  end

  def self.progress=(percentage)
    #TODO: if user runs disk_wizard in two browsers concurrently,identifier should set to unique kname of the disk
    current_progress = Setting.find_or_create_by('disk_wizard', 'operation_progress', percentage)
    if percentage.nil?
      current_progress && current_progress.destroy
      return nil
    end
    current_progress.update_attribute(:value, percentage.to_s)
    percentage
  end

  #TODO: Impliment status reporting via AJAX
=begin
  def install_status
    App.installation_status(self.identifier)
  end

  def self.installation_status(identifier)
    status = Setting.find_by_kind_and_name(identifier, 'install_status')
    return 0 unless status
    status.value.to_i
  end

  def install_status=(value)
    # create it dynamically if it does not exist
    status = Setting.find_or_create_by(self.identifier, 'install_status', value)
    if value.nil?
      status && status.destroy
      return nil
    end
    status.update_attribute(:value, value.to_s)
    value
  end
=end

  private

  def mount disk
    raise "#{__method__} method not implimented !"

  end

  def unmount disk
    raise "#{__method__} method not implimented !"

  end

  def create_partition partition_params_hash
    raise "#{__method__} method not implimented !"

  end

  def format_to filesystem_type
    raise "#{__method__} method not implimented !"

  end

  # class methods for retrive information about the disks attached to the HDA

  def self.find disk
    if disk =~ /(\/\w+\/).+/
      path = disk
    else
      path = "/dev/%s" % disk
    end
    # Assuming disk has no more than 10 partitions
    partition = true if Integer(disk[-1]) rescue false
    if partition
      partition = DiskUtils.find path
      partition["MODEL"] = DiskUtils.find(path[0..-2])["MODEL"]
      return partition
    else
      disk = DiskUtils.find path
      return disk
    end
  end

  def self.mounts
    # re arrange the previous DiskUtils.mounts method
    # DiskUtils.mounts
    PartitionUtils.new.info
  end

  def self.all
    # return all the attached disk, including unmounted disks
    DiskUtils.get_attached_disks
  end

  def self.removables
    # return an array of removable (Disk objects) device absolute paths
    DiskUtils.removables
  end

  def self.new_disks
    attached_devices = DiskUtils.get_attached_disks
    fstab = Fstab.new

    new_disks = []
    
    for device in attached_devices
      puts "DEBUG:******************#{device}"
      device_clone = device.clone
      device_clone['partitions'] = nil # flush partitions
      unless device['partitions'].nil? 
        device['partitions'].each do |partition|
          puts "DEBUG:******************#{partition}"
          dev_path = "/dev/#{partition['KNAME']}"
          unless fstab.has_device? dev_path
            device_clone["partitions"].nil? ?  device_clone["partitions"] = [partition] : device_clone["partitions"].push(partition)
          end
        end
      end
      new_disks.push device_clone if((not device_clone['partitions'].nil?) or device['partitions'].nil?)
    end
    # returns a array of hashes wich contains information about unmounted(not included in fstab) partitions or new storage disk(device)
    return new_disks
  end

end

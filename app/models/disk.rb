#Since no database involvement in the model, data is fetch on the fly by parsing the result of system calls
# inheriting ActiveRecord::Base is not necessary
class Disk #< ActiveRecord::Base

  require "disk_tools"

  attr_reader  :path, :removable,:model, :type, :size, :free_bytes, :used_bytes,:fs_type, :mount_point
  attr_accessor :kname, :partitions

  def initialize disk
    @model = disk[:model]
    @kname = disk[:kname]
    #TODO: Composite object Partition , i.e.: Disk has_many Partitions
    @partitions = disk[:partitions]
    @removable = self.removable?

    @type = disk[:type]
    @fs_type = disk[:fs_type]

    @mount_point = disk[:mount_point]
    @path = Disk.path disk[:kname]

    @size = disk[:size]
    @free_bytes = disk[:free_bytes]
    @used_bytes = disk[:used_bytes]
  end

  def partitions device
    raise "#{__method__} method not implimented !"

  end

  def new_disk? disk
    raise "#{__method__} method not implimented !"

  end

  def removable?
    DiskUtils.is_removable? @path
  end

  def Disk.progress
    current_progress = Setting.find_by_kind_and_name('disk_wizard', 'operation_progress')
    return 0 unless current_progress
    current_progress.value.to_i
  end

  def Disk.progress_message(percent)
    case percent
    when 0 then "Preparing to partitioning ..."
    when 10 then "Looking for partition table ..."
    when 20 then "Partition table created ..."
    when 40 then "Formating the partition ..."
    when 60 then "Creating mount point ..."
    when 80 then "Mounting the partition ..."
    when 100 then "Disk operations completed."
    when -1 then "Fail (check /var/log/amahi-app-installer.log)."
    else "Unknown status at #{percent}% ."
    end
  end

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

  def Disk.progress=(percentage)
    #TODO: if user runs disk_wizard in two browsers concurrently,identifier should set to unique kname of the disk
    current_progress = Setting.find_or_create_by('disk_wizard', 'operation_progress', percentage)
    if percentage.nil?
      current_progress && current_progress.destroy
      return nil
    end
    current_progress.update_attribute(:value, percentage.to_s)
    percentage
  end

  def self.find disk
    path = Disk.path disk
    puts "DEBUG:*************** path = #{path}"
    partition = true if Integer(disk[-1]) rescue false
    if partition
      partition = DiskUtils.find path
      partition["MODEL"] = DiskUtils.find(path[0..-2])["MODEL"]
      puts "DEBUG:*************** partition = #{partition}"
      return Disk.new({model: partition["MODEL"],type: partition["TYPE"], size: partition["SIZE"],\
        kname: partition["KNAME"], mount_point: partition["MOUNTPOINT"], fs_type: partition["FSTYPE"],\
        free_bytes: partition["BYTES_FREE"], used_bytes: partition["BYTES_USED"]})
    else
      disk = DiskUtils.find path
      puts "DEBUG:**************** disk = #{disk}"
      return Disk.new({model: disk["MODEL"],type: disk["TYPE"], size: disk["SIZE"],\
        kname: disk["KNAME"], mount_point: disk["MOUNTPOINT"], fs_type: disk["FSTYPE"]})
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

  def self.path disk
    if disk =~ /(\/\w+\/).+/
      path = disk
    else
      path = "/dev/%s" % disk
    end
    path
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

  def format_job params_hash
    puts "DEBUG:********** format_job params_hash #{params_hash}"
    Disk.progress = 10
    puts "DEBUG:*********** umount @path umount #{@path}"
    Command.new("umount #{@path}").run_now
    fs_type = params_hash[:fs_type]
    parted_object = Parted.new @kname
    #TODO: check the disk size and pass the relevent partition table type (i.e. if device size >= 3TB create GPT table else MSDOS(MBR))
    #TODO: check returned value for errors
    Disk.progress = 40
    @kname = parted_object.format fs_type
  end

  def mount_job params_hash
    Disk.progress = 60
    kname = @kname
    mount_point = "/media/#{kname}" # in production this path is /var/hda/files/drives/drive#
    puts "DEBUG:********** options_job.params_hash #{params_hash}"
    Command.new("mkdir #{mount_point}").run_now
    puts "DEBUG:********** Directory created #{mount_point}"
    fstab_object = Fstab.new
    puts "DEBUG:********** fstab_object created #{fstab_object}"
    puts "DEBUG:********** fstab_object.add_fs path = /dev/#{kname}"
    fstab_object.add_fs("/dev/#{kname}",mount_point,'auto','auto,rw,exec',0,0)
    Command.new("mount -a").run_now
    Disk.progress = 80
  end

  def process_queue jobs_queue
    while(not jobs_queue.empty?)
      job =  jobs_queue.dequeue
      puts "DEBUG:******* job[:job_name] = #{job[:job_name]} job[:job_para] =  $ #{job[:job_para]}"
      begin
        self.send(job[:job_name],job[:job_para])
      rescue => exception
        puts "DEBUG:*** JOB FAILS #{exception.inspect}"
        return false
      end
    end
    return true
  end
end

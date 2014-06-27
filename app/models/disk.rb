#Since no database involvement in the model, data is fetch on the fly by parsing the result of system calls
# inheriting ActiveRecord::Base is not necessary
class Disk #< ActiveRecord::Base

  attr_reader  :model, :size, :rm
  attr_accessor :kname, :partitions

  def initialize disk
    disk.each do |key,value|
      if key.eql? 'partitions' and value
        @partitions = []
        for partition in value
          @partitions.push Partition.new partition
        end
        next
      end
      instance_variable_set("@#{key}", value) unless value.nil?
    end
  end

  def self.all
    # return array of Disk objects
    disks = []
    devices = Diskwz.all_devices
    for device in devices
      disk = Disk.new device
      disks.append disk
    end
    return disks
  end

  def partition_table
    return Diskwz.partition_table self
  end

  def removable?
    return self.rm.eql? 1
  end

  def self.mounts
    return PartitionUtils.new.info
  end

  def self.new_disks
    fstab = Fstab.new
    all_devices = Disk.all
    unmounted_devices = []
    for device in all_devices
       if device.partitions.blank?
         unmounted_devices.push device
         next
       end
       device.partitions.delete_if {|partition| (fstab.has_device? partition.path )}
       unmounted_devices.push device if not device.partitions.blank?
    end
    return unmounted_devices
  end

  def Disk.progress
    current_progress = Setting.find_by_kind_and_name('disk_wizard', 'operation_progress')
    return 0 unless current_progress
    current_progress.value.to_i
  end

  def path
    if @kname =~ /(\/\w+\/).+/
      path = @kname
    else
      path = "/dev/%s" % @kname
    end
    return path
  end

  def self.find disk
    data_hash =  Diskwz.find disk
    if data_hash['type'].eql? 'part'
      return Partition.new data_hash
    else
      return Disk.new data_hash
    end
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

  def self.removables
    # return an array of removable (Disk objects) device absolute paths
    DiskUtils.removables
  end

  def mount disk
    raise "#{__method__} method not implimented !"

  end

  def unmount
    Diskwz.umount self
  end

  # Delete all excisting partitions and create one partition from entire device/disk
  def full_format fstype, label = nil
    DebugLogger.info "class = #{self.class.name}, method = #{__method__}"
    delete_all_partitions unless partitions.blank?
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:Creating partition #{self.kname}"
    Diskwz.create_partition self, 1, -1
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:Find partition #{@kname}"
    new_partition = Disk.find @kname + "1"
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:Formating #{@kname} to #{fstype}"
    new_partition.format fstype
  end

  #TODO: extend to create new partitions on unallocated spaces
  def create_partition size = nil, type = Partition.types[:primary]
    new_partition_kname = Diskwz.create_partition self, size[:start_block], size[:end_block]
    partitions = Disk.find(self).partitions
    return partitions.last
  end

  def create_partition_table
    Diskwz.create_partition_table self
  end

  def format_to filesystem_type
    raise "#{__method__} method not implimented !"

  end

  def format_job params_hash
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:Params_hash #{params_hash}"
    new_fstype = params_hash[:fs_type]
    Disk.progress = 10
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:Create partition_table #{partition_table}"
    #TODO: check the disk size and pass the relevent partition table type (i.e. if device size >= 3TB create GPT table else MSDOS(MBR))
    create_partition_table unless partition_table
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:Full format label #{params_hash['label']}"
    full_format new_fstype, params_hash['label']
    Disk.progress = 40
  end

  def mount_job params_hash
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:Params_hash #{params_hash}"
    Disk.progress = 60
    kname = @kname
    label = params_hash['label'] || kname
    DebugLogger.info "|#{self.class.name}|>|#{__method__}|:New partition Label #{label}"
    new_partition = Disk.find kname + "1"
    new_partition.mount label
    Disk.progress = 80
  end

  def delete_all_partitions
    for partition in self.partitions
      partition.delete
    end
  end
end

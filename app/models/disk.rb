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

  def self.process_queue jobs_queue
    while(not jobs_queue.empty?)
      job =  jobs_queue.dequeue
      Disk.send(job[:name],job[:paras]) rescue false
    end

  end

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
      device_clone = device.clone
      device_clone['partitions'] = nil # flush partitions
      unless device['partitions'].nil? 
      device['partitions'].each do |partition|
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

  def self.progress_message(percent)
    case percent
    when 0 then "Preparing to partitioning ..."
    when 100 then "Disk operations completed."
    when 999 then "Fail (check /var/log/amahi-app-installer.log)."
    else "Unknown status at #{percent}% ."
    end
  end

end

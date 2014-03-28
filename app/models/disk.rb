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

  def partitions
    raise "#{__method__} method not implimented !"

  end

  def new_disk?
    raise "#{__method__} method not implimented !"

  end

  def removable?
    # assuming is_removable? method accepts Disk objects
    DiskUtils.is_removable? self
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
    raise "#{__method__} method not implimented !"

  end

  def self.mounts
    # re arrange the previous DiskUtils.mounts method
    DiskUtils.mounts
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
      device['partitions'].each do |partition|
        dev_path = "/dev/#{partition['KNAME']}"
        unless fstab.has_device? dev_path
          device_clone["partitions"].nil? ?  device_clone["partitions"] = [partition] : device_clone["partitions"].push(partition)
        end
      end
      new_disks.push device_clone unless device_clone['partitions'].nil?
    end
    # returns a array of hashes wich contains information about unmounted(not included in fstab) partitions or new storage disk(device)
    return new_disks
  end

end

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
    raise "#{__method__} method not implimented !"

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
    raise "#{__method__} method not implimented !"

  end

  def self.new_disks
    attached_devices = DiskUtils.get_attached_disks
    fstab = Fstab.new

    new_disks = []
    attached_devices.each do |device|
      dev_path = "/dev/#{device['KNAME']}"
      # TODO push Disk object rather than hash which contains information about a disk/partition
      new_disks.push device unless fstab.has_device? dev_path
    end

    # returns a array of hashes wich contains information about unmounted(not included in fstab) partitions or new storage disk(device)
    return new_disks
  end

end

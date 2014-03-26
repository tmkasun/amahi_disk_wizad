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

 
end

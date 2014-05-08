# Amahi Home Server
# Copyright (C) 2007-2013 Amahi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License v3
# (29 June 2007), as published in the COPYING file.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# file COPYING for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Amahi
# team at http://www.amahi.org/ under "Contact Us."


class Parted
  
  def initialize disk
    if disk =~ /(\/\w+\/).+/
      @path = disk
    else
      @path = "/dev/%s" % disk
    end
  end

  def self.partition_table
    command = "parted #{@path} print"
    result = disk_command command
    result.each_line do |line|
      if line.strip =~ /^Error:/
        puts "DEBUG:************no disk line#{line}"
        return false
      elsif line.strip =~ /^Partition Table:/
        #TODO: Need to test for all the types of partition tables
        table_type = line.match(/^Partition Table:(.*)/i).captures[0].strip
        puts "DEBUG:************line#{table_type}"
        return table_type
      end
    end
  end
  
  def format fs_type
    #Creating new filesystem also format the partition with new FS type
    return self.create_fs fs_type
  end
  
  def create_partition_table type = 'msdos'
    command = 'parted -script #{@path} #{type}'
    result = disk_command command
    result.each_line do |line|
      if line.strip =~ /^Error:/
        puts "DEBUG:************no disk line#{line}"
        return false
      end
    end
  end
  
  def create_fs fs_type
    command = 'mkfs.#{fs_type} #{@path}'
    blocking = true
    #TODO: Validation befor executing command , since none-blocking call returns nil result
    result = disk_command(command , !blocking) # none-blocking call ,since formatting would take quit long time
    return result
  end
  
  private

  def disk_command command, blocking = true
    #forward the result(stdio and stderror) to temp file default location for temp file is /var/hda/tmp
    if blocking # default mode is blocking call, because other commands down the line depend on the result of the previous command(i.e. format after partitioning)
      Command.new("#{command} > /tmp/disk_wizard.tmp 2>&1").run_now #.execute is kind of none-blocking call and  run_now is a blocking call
      #TODO: Close opend file,rescue on no file, clear the file after reading to prevent dirty reads
      result = File.open("/tmp/disk_wizard.tmp", "r").read
    else
      Command.new("#{command} > /tmp/disk_wizard.tmp 2>&1").execute
      result = nil
    end
    return result
  end
      
end
# Amahi Home Server
# Copyright (C) 2007-2011 Amahi
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

class DiskWizard
  class << self
    DEBUG_MODE = true #TODO: Allow dynamically set value
    # Return an array of all the attached devices, including hard disks,flash/removable/external devices etc.
    def all_devices
      device = {}
      partitions = []
      disks = []
      disk = nil
      if DEBUG_MODE || Platform.ubuntu? or Platform.fedora? 
        command = "lsblk"
        params = "-b -P -o MODEL,TYPE,SIZE,KNAME,UUID,LABEL,MOUNTPOINT,FSTYPE,RM"
      end
      lsblk = DiskCommand.new command, params
      lsblk.execute
      return false if not lsblk.success?
      
      lsblk.result.each_line do |line|
        data_hash = {}
        line_data = line.gsub!(/"(.*?)"/,'\1,').split ","
        line_data.pop
        for data in line_data
          data.strip!
          key , value = data.split "="
          data_hash[key.downcase] = value
        end
        data_hash['rm'] = data_hash['rm'].to_i
        if data_hash['type'] == "disk"
          data_hash.except!('uuid','label','mountpoint','fstype')
          unless disk.nil?
            disks.push disk
            disk = nil # cleanup the variable
          end
          disk = data_hash
          next
        end
        if data_hash['type'] == "part"
          data_hash.except!('model')
          disk["partitions"].nil? ?  disk["partitions"] = [data_hash] : disk["partitions"].push(data_hash)
        end
      end
      disks.push disk
      return disks      
    end
    

  end
end
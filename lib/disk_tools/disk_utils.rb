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
class DiskUtils
  class << self
    def mounts
      s = `df -BK`.split( /\r?\n/ )[1..-1] || ["","Incorrect data returned"]

      mount = []
      res = []
      s.each do |line|
        word = line.split(/\s+/)
        mount.push(word)
      end
      mount.each do |key|
        d = {}
        d[:filesystem] = key[0]
        d[:bytes] = key[1].to_i * 1024
        d[:used] = key[2].to_i * 1024
        d[:available] = key[3].to_i * 1024
        d[:use_percent] = key[4]
        d[:mount] = key[5]
        res.push(d) unless ['tmpfs', 'devtmpfs'].include? d[:filesystem]
      end
      res.sort { |x,y| x[:filesystem] <=> y[:filesystem] }
    end

    def get_attached_disks
      disks = []
      disk = nil

      lsblk_result = `lsblk -b -P -o MODEL,TYPE,SIZE,KNAME,MOUNTPOINT,FSTYPE`.each_line

      lsblk_result.each do |line|
        data_hash = {}
        line_data = line.gsub!(/"(.*?)"/,'\1,').split ","
        line_data.pop
        for data in line_data
          data.strip!
          key_value_pair = data.split "="
          data_hash[key_value_pair[0]] = key_value_pair[1]
        end

        blkid_result = `df -T /dev/#{data_hash['KNAME']}`.lines.pop
        blkid_result.gsub!(/"/, '')
        blkid_data =  blkid_result.split(" ") if not blkid_result.empty?
        data_hash['FSTYPE'] = blkid_data[1] unless data_hash['FSTYPE'] and blkid_data
        
        if data_hash['TYPE'] == "disk"
          unless disk.nil?
            disks.push disk
            disk = nil # cleanup the variable
          end
          disk = data_hash
          disk['removable'] = is_removable? "/dev/#{disk['KNAME']}" 
          next
        end
        if data_hash['TYPE'] == "part"
          disk["partitions"].nil? ?  disk["partitions"] = [data_hash] : disk["partitions"].push(data_hash)
        end
      end
      disks.push disk
      return disks

    end

    def removables
      removables = []
      devices_by_id = Pathname.new "/dev/disk/by-id/"       
      devices_by_id.each_child do |sym_link| 
        # TODO push disk object insted of device_abs_path string
        removables.push sym_link.realpath if sym_link.to_s =~ /\/usb-*/ 
      end
      #return array of Filename objects which contents path to removable revices
      return removables
    end

    def is_removable? device
      return removables.include? device
    end

  end
end

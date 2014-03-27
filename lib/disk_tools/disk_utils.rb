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
      lsblk_result = `lsblk -b -P -o MODEL,TYPE,SIZE,KNAME,MOUNTPOINT,FSTYPE`.each_line

      lsblk_result.each do |line|
        data_hash = {}
        line_data = line.gsub(/"/, '').split " "

        for data in line_data
          key_value_pair = data.split "="
          data_hash[key_value_pair[0]] = key_value_pair[1]
        end

        blkid_result = `df -T /dev/#{data_hash['KNAME']}`.lines.pop
        blkid_result.gsub!(/"/, '')
        blkid_data =  blkid_result.split(" ") unless blkid_result.empty?
        data_hash['FSTYPE'] = blkid_data[1] unless data_hash['FSTYPE'] and blkid_data
        disks.push data_hash if (data_hash['TYPE'] == "disk" or data_hash['TYPE'] == "part")
      end
      return disks

    end

    def removables
      result  = `ls -l /dev/disk/by-id/usb-*`
      removables = []
      result.each_line do |line|
        device_relative_path = line.split(" ")[-1]
        device_abs_path = "/dev/"+device_relative_path.split("/")[-1]
        # TODO push disk object insted of device_abs_path string
        removables.push device_abs_path
      end
      return removables
    end

    def is_removable? device
      return removables.include? device
    end

  end
end

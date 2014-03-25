#! /usr/local/bin/ruby #remove this line when converting to rails lib file

class NewDiskUtils
  class << self
result = `lsblk -b -P -o MODEL,TYPE,SIZE,KNAME,MOUNTPOINT,FSTYPE`.each_line

result.each do |line|
	data_hash = {}	
	line_data = line.gsub(/"/, '').split " "
	for data in line_data
		key_value_pairs = data.split "="
		data_hash[key_value_pairs[0]] = key_value_pairs[1]
	end
	puts data_hash
	blkid_result = `df -T /dev/#{data_hash['KNAME']}`.lines.pop
	puts blkid_result.gsub(/"/, '') unless blkid_result.empty?
end	
      def get_attached_disks
        
	puts "Not implimented!"

      end

    end
end

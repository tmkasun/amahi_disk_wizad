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
	end
end

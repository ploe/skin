#! /usr/bin/ruby

require 'curb'

# Dumb script for downloading all posted images on a thread from 4chan, 
# and sticks them in their own dir. Multiple URLs can be supplied.

if ARGV.length == 0 then
	$stderr.puts("Usage: skin [LIST OF URL's...]\nDumps images from the specified 4chan threads in to their own directory\n")
	exit
end

ARGV.each { |arg|
	http = Curl.get(arg)
	
	# get the subject of the thread and prepend with Unix timestamp
	dir = http.body_str.match(/<span class="subject">(.*?)</i).captures[0]
	dir += Time.now.to_i.to_s
	Dir.mkdir(dir, 0700)
	
	# get every image URL and dump it in to the dir
	http.body_str.scan(/<a class="fileThumb" href="\/\/(.*?)"/i) { |i|
		puts i
		i = i.join
		image = Curl.get(i)

		file = dir + "/" + i.sub(/.*\//i, "").to_s
		File.open(file, "wb") { |f|
			f.write(image.body_str)
		}
	}
}



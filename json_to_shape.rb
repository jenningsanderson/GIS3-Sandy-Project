require 'rgeo-shapefile'
require 'geo_ruby'
require 'geo_ruby/shp'
require 'json'
require 'pp'

'''
Class for handling the giant file.
'''
class Tweet_JSON_Reader
	attr_reader :json_filename, :tweets

	def initialize( in_file )
		@json_filename = in_file
		@tweets = {}
	end

	def read_lines(max=nil)
		unless max.nil?
			tweets_file = File.open(@json_filename).first(max).each
		else
			tweets_file = File.open(@json_filename).each
		end
		tweets_file.each do |line|
			tweet = JSON.parse(line.chomp)
			user_id = tweet["user"]["id_str"]
				@tweets[user_id] ||= {:name=>[],:coords=>[], :urls=>[], :hashtags=>[]}

				@tweets[user_id][:coords] 	<< tweet["geo"]["coordinates"]

				unless tweet["entities"]["urls"].nil?
					tweet["entities"]["urls"].each do |url|
						@tweets[user_id][:urls] << url["expanded_url"]
					end
				end
				unless tweet["entities"]["hashtags"].nil?
					tweet["entities"]["hashtags"].each do |hashtag|
						@tweets[user_id][:hashtags] << hashtag["text"]
					end
				end
				@tweets[user_id][:name] 		<< tweet["user"]["screen_name"]
		end
	end
end


'''
This class makes a shapefile from tweets
'''
class Tweet_Shapefile
	attr_reader :file_name
	attr_accessor :fields

	def initialize(file_name)
		unless file_name =~ /\.shp$/
			file_name << '.shp'
		end
		@file_name = file_name
		@fields = {:user_id_str=>11, :screen_name=>20, :text=>140, :hashtags=>100, :urls=>100}
	end

	def create_points_shapefile
		fields = []
		@fields.each do |k,v|
			fields << GeoRuby::Shp4r::Dbf::Field.new(k.to_s,"C",v)
		end
		@shapefile = GeoRuby::Shp4r::ShpFile.create(@file_name, GeoRuby::Shp4r::ShpType::MULTIPOINT,fields)

		@points_geometry = GeoRuby::SimpleFeatures::MultiPoint.new()
	end

	def add_point(point)
		@shapefile
	end

end

if __FILE__ == $0
	sandy = '/Users/Shared/Sandy/geo_extract.json'
	tweets = Tweet_JSON_Reader.new('test_out.json')
  tweets.read_lines(max=100)

	pp tweets.tweets
	#tweet = Tweet_Shapefile.new('sandy_tweets_sample')
	#tweet.create_points_shapefile

end

# puts "This is a test of reading a shapefile"
# shape = RGeo::Shapefile::Reader.open('../lab3/data/interestAreas.shp')
# shape.each do |record|
# 	puts record.geometry.area
#   end
# puts shape.open?
# shape.close
# puts shape.open?




## This one can read and write... but none of it is very straightforward.:

#
# GeoRuby::Shp4r::ShpFile.open('../lab3/data/interestAreas.shp') do |shp|
# 	shp.each do |shape|
# 		geom = shape.geometry #a GeoRuby SimpleFeature
# 			puts "BOUNDING BOX: #{geom.bounding_box.inspect }\n"#I can get bounding box, but I can't calculate area?
# 		att_data = shape.data #a Hash
# 		puts "Attribute data: #{att_data.inspect}"
# 		shp.fields.each do |field|
# 			puts "Field: #{field.inspect}"
# 			puts att_data[field.name]
# 		end
# 	end
# end

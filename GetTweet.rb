#!/usr/bin/ruby
# encoding: utf-8
#
# 20150729作成
# 20150806更新

require 'kconv'
require 'fileutils'
require 'rexml/document'
require 'twitter'
require 'net/http'
require 'json'

$scriptPath = "#{File.expand_path(File.dirname($0))}/"

Prefecture = "長野県"
LaL = [137.3, 35.15, 138.75, 37.05]

BASE_URL_YOLP_GEOCODER = "http://geo.search.olp.yahooapis.jp/OpenLocalPlatform/V1/geoCoder"
APP_ID_YAHOO = ""

def set_child(nodeItem0, nameStr0, textStr0, attrStr0)

	nodeChild = REXML::Element.new(nameStr0)
	nodeItem0.add_element(nodeChild)

	if textStr0 != "" then
		nodeChild.add_text(textStr0)
	end
	if attrStr0 != "" then
		tmpAry = attrStr0.split("/,/")
		for i in 0..tmpAry.length - 1 do
			tmpAry2 = tmpAry[i].split("///")
			nodeChild.add_attribute(tmpAry2[0], tmpAry2[1])
		end
	end
end

# Yahoo!ジオコーダAPI
def geocode_yolp(address)

	address = URI.encode(address)
	hash = Hash.new

	# 出力形式JSON
	reqUrl = "#{BASE_URL_YOLP_GEOCODER}?appid=#{APP_ID_YAHOO}&query=#{address}&output=json"
	response = Net::HTTP.get_response(URI.parse(reqUrl))

	hash['lat'] = 0.00
	hash['long'] = 0.00

	case response
	when Net::HTTPSuccess then
		data = JSON.parse(response.body)
		feature = data['Feature']
		for i in 0..feature.length - 1 do
			if feature[i]['Name'].include?(Prefecture) == true then
				coordinates = feature[i]['Geometry']['Coordinates'].split(/,\s?/)
				hash['lat'] = coordinates[1].to_f	# 緯度
				hash['long'] = coordinates[0].to_f	# 経度
				
				hash['index'] = i
				
				break
			end
		end
	end

	return hash
end

puts "========== Get Tweet =========="

# Consumer key, Secretの設定
CONSUMER_KEY = ""
CONSUMER_SECRET = ""
# Access Token Key, Secretの設定
ACCESS_TOKEN_KEY = ""
ACCESS_SECRET = ""
# 自治体名一覧を取得
autonomyList = File.read("#{$scriptPath}autonomy.ini").toutf8.gsub("\r", "").split("\n")

# XML準備
if File.exist?("#{$scriptPath}tweet.xml") == false then
	FileUtils.copy("#{$scriptPath}XML_template.xml", "#{$scriptPath}tweet.xml")
end

# Tweet取得		
client = Twitter::Streaming::Client.new do |config|
	config.consumer_key = CONSUMER_KEY
	config.consumer_secret = CONSUMER_SECRET
	config.access_token = ACCESS_TOKEN_KEY
	config.access_token_secret = ACCESS_SECRET
end
 
client.filter(:locations => LaL.join(",")) do |tweet|

	if tweet.is_a?(Twitter::Tweet)
	
		f_Agr = false
		if tweet.place.name != nil && tweet.place.name != "" then
			for i in 0..autonomyList.length - 1 do
				if tweet.place.name.include?(autonomyList[i]) == true then
					code = i;
					f_Agr = true
					break
				end
			end
		else
			f_Agr = true
		end
		if f_Agr == false then
			next
		end
		
		mark = ""
		if tweet.geo.lat.to_i != 0 then
			latFull = tweet.geo.lat
			longFull = tweet.geo.long
		else
			coordinates = geocode_yolp(tweet.place.name)
			latFull = coordinates['lat']
			longFull = coordinates['long']
			mark = "*#{coordinates['index']}"
		end
		
		lat = (latFull * 20).floor.to_f / 20
		long = (longFull * 20).floor.to_f / 20

		# 標準出力
		puts "#{tweet.user.screen_name}:"
		puts "#{tweet.text}"
		puts "#{tweet.created_at.strftime('%Y/%m/%d %H:%M:%S')} #{tweet.place.name} (#{'%.2f' % lat}, #{'%.2f' % long})#{mark}"
		puts "====="
		
		# テキストログ
		File.open("#{$scriptPath}tweet#{Time.now.strftime('%Y%m%d')}.dat", "a:UTF-16:UTF-8") do |f|
			f.puts "#{tweet.user.screen_name}:"
			f.puts "#{tweet.text}"
			f.puts "#{tweet.created_at.strftime('%Y/%m/%d %H:%M:%S')} #{tweet.place.name} (#{'%.2f' % lat}, #{'%.2f' % long})#{mark}"
			f.puts "====="
		end
		
		# 排他制御開始
		while File.exist?("#{$scriptPath}refreshingD.flag") == true do
			sleep 1
			puts "■wait for DelTweet■"
		end
		File.write("#{$scriptPath}refreshingG.flag", "refreshing")
		
		# XML処理
		xml = REXML::Document.new(File.read("#{$scriptPath}tweet.xml"))

		nodeXML = xml.get_elements("/xml")[0]
		nodeList = nodeXML.get_elements("list")[0]

		nodeList.attributes["num"] = nodeList.attributes["num"].to_i + 1
		
		nodeTweet = REXML::Element.new("tweet")
		nodeList.add_element(nodeTweet)
		nodeTweet.add_attribute("time", tweet.created_at.strftime('%Y/%m/%d %H:%M:%S'))
		
		for i in 0..4 do

			nameStr = ""
			textStr = ""
			attrStr = ""

			case i
			when 0 then
				nameStr = "user"
				attrStr = "name///#{tweet.user.name}/,/id///#{tweet.user.screen_name}"
			when 1 then
				nameStr = "text"
				attrStr = "body///#{tweet.text}"
			when 2 then
				nameStr = "place"
				attrStr = "latitude///#{'%.2f' % lat}/,/longitude///#{'%.2f' % long}/,/latitudeF///#{latFull}/,/longitudeF///#{longFull}/,/mark///#{mark}/,/name///#{tweet.place.name}/,/code///#{code}"
			when 3 then
				if tweet.entities? then
					nameStr = "entities"
					attrStr = ""
					if tweet.user_mentions? then
						user_mention = ""
						tweet.user_mentions.each do |e|
							user_mention << "#{e.screen_name}/-/"
						end
						user_mention = user_mention.slice(0, user_mention.length - 3)
						attrStr << "reply///#{user_mention}/,/"
					end
					if tweet.hashtags? then
						hashtag = ""
						tweet.hashtags.each do |e|
							hashtag << "#{e.text}/-/"
						end
						hashtag = hashtag.slice(0, hashtag.length - 3)
						attrStr << "hash///#{hashtag}/,/"
					end
					if tweet.uris? then
						uri = ""
						tweet.uris.each do |e|
							uri << "#{e.url}/-/"
						end
						uri = uri.slice(0, uri.length - 3)
						attrStr << "link///#{uri}/,/"
					end
					if tweet.media? then
						media = ""
						tweet.media.each do |e|
							media << "#{e.url}/-/"
						end
						media = media.slice(0, media.length - 3)
						attrStr << "media///#{media}/,/"
					end
					if attrStr != "" then
						attrStr = attrStr.slice(0, attrStr.length - 3)
					else
						next
					end
				else
					next
				end
			when 4 then
				if tweet.retweet? then
					nameStr = "source_user"
					attrStr = "rt///#{tweet.retweet_count}/,/name///#{tweet.retweeted_status.user.name}/,/id///#{tweet.retweeted_status.user.screen_name}"
				else
					next
				end
			end
			set_child(nodeTweet, nameStr, textStr, attrStr)
		end

		File.open("#{$scriptPath}tweet.xml", "w") do |f|
			xml.write(f, 0)
		end

		# 排他制御終了
		File.delete("#{$scriptPath}refreshingG.flag")
	end
end


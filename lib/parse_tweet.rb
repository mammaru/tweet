# coding: utf-8
require "natto"
require "json"
require "rexml/document"

class Tweet

  # initialization called by new
  #def initialize(tweet)
    #@tweet = tweet
  #end
  
  # json or xml format of tweet data to hash object
  def parse(tweet_filename)
    file_type = File.extname(tweet_filename)
    if file_type == ".json"
      @tweets = JSON.parse(tweet_filename)
    elsif file_type == ".xml"
      tmp = REXML::Document.new(File.new(tweet_filename))
      @tweets = Hash.from_xml(tmp.to_s)
    else
      raise "input file name is not json nor xml."
    end
  end

  def placename_to_latlong

    @tweets.each do |tweet|
      word_array = Array.new
      nm = Natto::MeCab.new
      regex = /^地名/
      #regex = /^名詞,固有名詞/
      nm.parse(tweet) do |node| # nouns to word_array
        if node.feature =~ regex #.force_encoding("UTF-8")
          word_array << node.surface #.force_encoding("UTF-8")
        end
      end

      tmp = nm.parse(tweet)
      p tmp

      # word_hash: {["word" => count],...}
      word_hash = Hash.new
      word_array.each do |key|
        word_hash[key] ||= 0
        word_hash[key] += 1
      end

      regex_white = /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[a-zA-Z]+|[ａ-ｚＡ-Ｚ]+/ # white list
      #regex_black = Regexp.new(/[!-¥:-@≠\[-`{-~\]]/) # black list
      #word_hash.delete_if{|k, v| k =~ regex_black by black list
      word_hash = word_hash.select{|k, v| k =~ regex_white}.to_h # filtering by white list

      word_hash = word_hash.sort_by {|k, v| v}.to_h # sort by word count

      words_total = word_hash.values.inject(0){|sum, i| sum+i}
      #p words_total
      word_hash_normalized = word_hash.map {|k, v| [k, v.quo(words_total).to_f]}.to_h
      #p word_hash
      #p word_hash_normalized
      #return word_hash.to_a
      return word_hash_normalized.to_a

      #nm.parse(texts) do |n|
        #puts "#{n.surface}\t#{n.feature}"
        #words.push(n.surface if n.)
      #end

    end

  end

end

# -*- coding: utf-8 -*-
require 'csv'
require 'pp'
require 'find'
require 'mp3info'
require 'taglib'
require 'audioinfo'

class File
  def self.mega_size(f)
    return (size(f)/1000/1000.0).to_s+"MB"
  end
end

class Manager
  @@dir_root = ENV["HOME"]
  COMP_ROOT = Dir.pwd

  def Manager.update_db
    db = read_files

    Dir.chdir(@@dir_root)
    CSV.open("db.csv", "w") do |csv|
      db.each { |e|
        csv << e
      }
    end
    Dir.chdir(COMP_ROOT)
  end

  def self.dir_root=(dir)
    @@dir_root = dir
  end

  private
  def Manager.read_files
    db = Array.new
    db.push(["artist", "title", "album", "track", "gene", "year", "filesize", "location"])

    Dir.chdir(@@dir_root)
    Find.find(@@dir_root) do |f|
      if f.include?("その他") || f.include?("問題有り")
        next
      elsif /.mp3|.MP3/ =~ File.extname(f)
        db.push(read_row_mp3(f))
      elsif /.m4a|.mp4/ =~ File.extname(f)
        db.push(read_row_m4a(f))
      elsif File.extname(f) == ".wma"
        db.push(read_row_wma(f))
      elsif File.directory?(f) || /.jpg|.jpeg|.JPG|.oma|.ini|.txt|.db/ =~ File.extname(f)
        next
      end
    end
    Dir.chdir(COMP_ROOT)

    return db
  end

  def Manager.read_row_mp3(f)
    Mp3Info.open(f, :encoding=>"utf-16") do |mp3|
      tag = mp3.tag
      return [tag.artist, tag.title, tag.album, tag.tracknum, tag.genre_s, tag.year, File.mega_size(f), f]
    end
  end

  def Manager.read_row_m4a(f)
    TagLib::MP4::File.open(f) do |mp4|
      list = mp4.tag.item_list_map
      artist = list["\xC2\xA9ART"].to_string_list.first
      title = list["\xC2\xA9nam"].to_string_list.first
      album = list["\xC2\xA9alb"].to_string_list.first
      track = list["trkn"].to_string_list.first
      gene = list["\xC2\xA9gen"].to_string_list.first
      if list["\xC2\xA9day"] == nil
        year = "----"
      else
        year = list["\xC2\xA9day"].to_string_list.first
      end
      return [artist, title, album, track, gene, year, File.mega_size(f), f]
    end

  end

  def Manager.read_row_wma(f)
    AudioInfo.open(f) do |tag|
      return [tag.artist, tag.title, tag.album, tag.tracknum, "----", tag.date, File.mega_size(f), f]
    end
  end
end



# if $0 == __FILE__
#   Manager.update_db
# end

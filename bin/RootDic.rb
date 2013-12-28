# -*- coding: utf-8 -*-
class RootDic

  def RootDic.load
    if File.exist?("./info.json")
      info = open("./info.json", "r") do |io|
        JSON.load(io)
      end
      root_dir = info["root_dir"]
    else
      root_dir = ENV["HOME"]
    end
  end

  def RootDic.save(dir)
    open("./info.json", "w") do |io|
      JSON.dump({"root_dir" => dir}, io)
    end
  end
end

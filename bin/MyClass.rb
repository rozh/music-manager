# -*- coding: utf-8 -*-
require 'json'

class MyClass #(change name)

  include GladeGUI

  def before_show()
    @builder["filechooserwidget1"].current_folder = RootDic.load
  end

  def button1__clicked(*args)
    RootDic.save(@builder["filechooserwidget1"].current_folder)
    Manager.dir_root = @builder["filechooserwidget1"].current_folder
    Manager.update_db
  end

  def destroy(widget, event)
    if event.state.control_mask? && event.keyval == Gdk::Keyval::GDK_q
      destroy_window
      true
    else
      false
    end
  end

  def destroy_window
    Gtk.main_quit
  end

end

module Platform

  def check_operating_system
    # The Mac check has to be proceed before the Win check!
    # Perhaps checking for /mswin/ will reduce this requirement.
    case RUBY_PLATFORM
    when /ix/i, /ux/i, /gnu/i, /sysv/i, /solaris/i, /sunos/i, /bsd/i
      require 'gtk2'
      Gtk.init
      @clip = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
      :unix
    when /darwin/i
      :mac_os_x
    when /mswin/i, /ming/i
      require 'vr/clipboard'
      @clip = Clipboard.new(2048)
      :windows
    else
      :other
    end
  end

end

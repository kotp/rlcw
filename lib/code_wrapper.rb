#!/usr/bin/env ruby
=begin rdoc

= Name: code_wrapper.rb
*Author*: Victor Goff

*Contributors*:
- Mareike Hybsier
- Carlan Calazans
---
License: Ruby License detailed at
www.ruby-lang.org/en/LICENSE.txt                     
                      Version: 0.8.45

=end

# require 'rdoc/usage'

$WRAPPER_VERSION  = '0.8.45'

class Wrapper
  
  TEMP_FILE = 'temp_file.txt'
  
  def initialize(file_name, clipboard = false, lines = false, outfile = '',
                                            begin_wrap = '', end_wrap = '')
    @os = check_operating_system  
    # Sets all instance variables in one go with some meta programming :)
    set_instance_variables(binding, *local_variables)
  end
  
  def process
    @wrapped_content = wrap
    write_to_file(@outfile) unless @outfile.empty?
    paste_to_clipboard if @clipboard
  end
  
  private
  
  def set_instance_variables(binding, *variables)
    variables.each do |var|
      instance_variable_set("@#{var}", eval(var, binding))
    end
  end
  
  def wrap
    if @begin_wrap.empty?
      @begin_wrap = ('[code ruby' + ((@lines == true) ? ' linenumbers' : '') + ']')
    end
    @end_wrap = ('[' + '/code' + ']') if @end_wrap.empty?

    @begin_wrap + read_content.gsub(/</, "&lt;").gsub(/>/,"&gt;") +
      "\n ## Wrapped with 'The Code Wrapper', Version #{$WRAPPER_VERSION}." +
      @end_wrap
  end
  
  def write_to_file(filename)
    # TODO Error handling
    File::open(filename, "w+") { |file| file << @wrapped_content }
  end
  
  def paste_to_clipboard
    # TODO Error handling
    send("paste_to_#{check_operating_system}_clipboard")
    puts "Your code block can now be pasted!"
  end
  
  def paste_to_mac_os_x_clipboard
    write_to_file(TEMP_FILE)
    system("cat " + TEMP_FILE + " | pbcopy")
    File::delete(TEMP_FILE)
  end

  def paste_to_windows_clipboard
      @clip.setText(@wrapped_content)
      @clip.close
    end
  
  def paste_to_unix_clipboard
    @clip.set_text(@wrapped_content)
    @clip.store
  end

  def read_content
    # TODO Error handling
    IO.readlines(@file_name).join unless @clipboard 
    @clip.getText if @clipboard && @os == :windows 
  end

  def check_operating_system
    # The Mac check has to be proceed before the Win check!
    case RUBY_PLATFORM
    when /ix/i, /ux/i, /gnu/i, /sysv/i, /solaris/i, /sunos/i, /bsd/i
      require 'gtk2'
      Gtk.init
      @clip = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
      :unix
    when /darwin/i
      :mac_os_x
    when /win/i, /ming/i
      require 'vr/clipboard'
      @clip = Clipboard.new(2048)
      :windows
    else
      :other
    end
  end
  
# This will let us print to string the wrapped content.
  def to_s
    @wrapped_context
  end
  
end
# Do all the option parsing here and the call the Wrapper

Wrapper.new('/tmp/reminder.rb', 'true', 'false').process unless __FILE__ != $0
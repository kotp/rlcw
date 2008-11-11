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

require '../lib/platform'
include Platform

$WRAPPER_VERSION  = '0.8.45'

# This class simply replaces < characters to &lt; symbols for Moodle Forums.
# It also wraps the copied text with [code ruby] [/code] block.

class Wrapper
  
  TEMP_FILE = 'temp_file.txt'

  # Usage: Wrapper.new('filename.rb', false, false, 'out_filename.rb', '[code ruby]', '[/code ruby]')
  # Everything is defaulted to generally acceptable values, except for 'filename.rb' for input.
  # This is actually written to be more for clipboard content at this point.
  
  def initialize(file_name, clipboard = false, lines = false, outfile = '',
                                            begin_wrap = '', end_wrap = '')
    @os = check_operating_system  
    # Sets all instance variables in one go with some meta programming.
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

  def to_s
    @wrapped
  end

end
# Do all the option parsing here and the call the Wrapper

Wrapper.new('/tmp/reminder.rb', 'true', 'false').process unless __FILE__ != $0

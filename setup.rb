#!/usr/bin/env ruby

require 'json'

def mark_installed(installed,name)
  installed[name] = true
  File.open("installed.json","w") do |file|
    file.puts installed.to_json
  end
  puts "✅ #{name} installed"
end

def shell_install(installed,setup_step, mark_installed: true)
  puts "🔸 #{setup_step["name"]} not installed."
  cmd = setup_step["command"]
  puts "🔸 Installing via '#{cmd}'"
  if system(cmd)
    mark_installed(installed,setup_step["name"]) if mark_installed
  else
    puts "⛔ There was some problem.  Stopping setup"
    exit -1
  end
end

def install(setup,installed)
  setup.each do |setup_step|
    if installed[setup_step["name"]]
      puts "✅ #{setup_step["name"]} already installed"
    else
      case setup_step["type"]
      when "manual"
        puts "⛔ You must install #{setup_step["name"]} manually."
        if setup_step["url"]
          puts "⬇ Download and install the software at the URL that will open in your browser"
          puts "↩ Hit return to open the link in your browser"
          gets
          system "open #{setup_step["url"]}"
        elsif setup_step["instructions"]
          puts "🗒 Follow the instructions:"
          puts
          setup_step["instructions"].each do |instruction|
            puts "  #{instruction}"
          end
        else
          raise "There is no URL or instructions - the step is misconfigured"
        end
        puts "↩ Hit return when done"
        gets
        mark_installed(installed,setup_step["name"])
      when "homebrew"
        shell_install(installed,setup_step.merge("command" => "brew install #{setup_step["package"]}"))
        if setup_step["after"]
          setup_step["after"].each do |after_command|
            shell_install(installed,setup_step.merge("command" => after_command, "name" => after_command), mark_installed: false)
          end
        end
      when "rbenv"
        shell_install(installed,setup_step.merge("command" => "rbenv install #{setup_step["ruby-version"]} -s"))
      when "shell"
        test = setup_step["test"]
        if !test
          puts "⛔ #{setup_step["name"]} has no test for pre-installation.  Add one and retry"
          exit -1
        end
        if test == "ASK" || system("#{test} > /dev/null 2>&1")
          if test == "ASK"
            puts "⛔ Can't tell if #{setup_step["name"]} is already installed"
          else
            puts "⛔ It looks like #{setup_step["name"]} is already installed"
          end
          puts "Type 'install' to force trying to install it anyway.  Anything else and we'll mark it installed"
          value = gets
          if value.chomp.strip == "install"
            shell_install(installed,setup_step)
          else
            mark_installed(installed,setup_step["name"])
          end
        else
          shell_install(installed,setup_step)
        end
      when "file"
        filename = setup_step["filename"]
        File.open(filename,"w") do |file|
          setup_step["contents"].each do |line|
            file.puts line
          end
        end
        if setup_step["post_install"]
          setup_step["post_install"].each do |line|
            puts line
          end
          puts "Hit return when done"
          gets
        end
        mark_installed(installed,setup_step["name"])
      when "postgres"
        IO.popen("psql -h localhost -U postgres","w") do |io|
          setup_step["commands"].each do |command|
            io.write(command)
            io.write("\n")
          end
          io.close_write
        end
        mark_installed(installed,setup_step["name"])
      else
        puts "‼ Don't know how to handle a #{setup_step["type"]} setup step…ignoring"
      end
    end
  end
end


[
  "setup",
  "additional_setup",
].each do |setup_file|
  puts "🗃 installing packages from #{setup_file}.json"
  setup = JSON.parse(File.read("#{setup_file}.json"))["setup"]
  installed = JSON.parse(File.read("installed.json")) if File.exist?("installed.json")
  installed ||= {}

  install(setup,installed)
end
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

def install(setup,installed,outdated)
  setup.each do |setup_step|
    if installed[setup_step["name"]]
      if setup_step["type"] == "homebrew" && outdated[setup_step["package"]]
        puts "⛔ #{setup_step['name']} is outdated: #{outdated[setup_step["package"]]}"
        if setup_step["after"].nil? || setup_step["ignore_after_for_upgrade"] == true
          puts "Hit return to upgrade; anything else will skip upgrading"
          value = gets
          if value.strip == ""
            shell_install(installed,setup_step.merge("command" => "brew upgrade #{setup_step["package"]}"))
            unless setup_step["after"].nil?
              puts "❗️ There were after steps you asked to ignore.  The are:"
              setup_step["after"].each do |step|
                puts "  #{step}"
              end
              puts "❗️ Make sure you don't need to do something after the upgrade.  Hit Return to continue"
              gets
            end
          else
            puts "⛔ Not upgrading #{setup_step['name']}"
          end
        else
            puts "⛔ #{setup_step['name']} has 'after' steps, so we recommend you either upgrade manually, or uninstall, then reinstall"
        end
      else
        puts "✅ #{setup_step["name"]} already installed"
      end
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
        package = setup_step["package"]
        results = `brew info #{package} 2>&1`
        if results !~ /Not installed/i && results !~ /no available formula/i
          puts "⛔ It looks like #{setup_step["name"]} is already installed"
          puts "Type 'install' to force trying to install it anyway.  Anything else and we'll mark it installed"
          value = gets
          if value.chomp.strip != "install"
            mark_installed(installed,setup_step["name"])
            break
          end
        end
        shell_install(installed,setup_step.merge("command" => "brew install #{setup_step["package"]}"))
        if setup_step["after"]
          setup_step["after"].each do |after_command|
            shell_install(installed,setup_step.merge("command" => after_command, "name" => after_command), mark_installed: false)
          end
        end
      when "rbenv"
        shell_install(installed,setup_step.merge("command" => "rbenv install #{setup_step["ruby-version"]} -s"))
      when "npm"
        shell_install(installed,setup_step.merge("command" => "npm install -g #{setup_step["package"]}"))
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

outdated = {}
to_install = {}
[
  "setup",
].each do |setup_file|
  setup = JSON.parse(File.read("#{setup_file}.json"))["setup"]
  setup.each do |install_instructions|
    to_install[install_instructions["name"]] = install_instructions
  end
end

installed = JSON.parse(File.read("installed.json")) if File.exist?("installed.json")
installed ||= {}

removed = installed.keys - to_install.keys
unless removed.empty?
  puts "🚫 Some installed software has been removed from your manifest."
  removed.each do |name|
    puts "🔥 #{name}"
    puts "Hit return once you've removed it, or type 'skip' to leave it marked as installed"
    value = gets
    if value.chomp.strip != "skip"
      installed.delete(name)
    end
  end
end

homebrew = to_install.values.detect { |software| software["name"] == "Homebrew" } != nil
if homebrew && installed["Homebrew"]
  puts "🔸 updating Homebrew..."
  if system("brew update")
    puts "✅ Homebrew updated"
    puts "🔸 Checking for outdated installs"
    outdated = Hash[`brew outdated -v`.split(/\n/).map { |package_desc|
      package,rest = package_desc.split(/\s/,2)
      [package,rest]
    }]
  else
    $stderr.puts "Problem updating homebrew"
    exit 1
  end
end

asdf = to_install.values.detect { |software| software["name"] == "asdf" } != nil
if homebrew && installed["asdf"]
  puts "🔸 updating asdf plugins..."
  if system("asdf plugin-update --all")
    puts "✅ asdf plugins updated"
    puts "🔸 Checking for outdated installs"
  else
    $stderr.puts "Problem updating asdf plugins"
    exit 1
  end
end

install(to_install.values,installed,outdated)

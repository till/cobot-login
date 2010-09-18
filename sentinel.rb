#!/usr/bin/env ruby
#
# sentinel.rb - run cobot-login script on AirPort state change
#

CobotLogin="${HOME}/bin/cobot-login"

def find_airport_interfaces()
  interfaces = []
  list = `echo list | scutil`
  list.each do |line|
    next unless (line =~ /State.*AirPort$/)
    interface = line.split(' = ')[1]
    interfaces << interface
  end
  return interfaces
end

def is_connected(interface, f)
  power_status = false
  busy_status = false
  ssid_match = false

  f.puts("get #{interface}")
  f.puts("d.show")
  while (line = f.gets()) do
    return false if line =~ /^\}$/
    # run cobot-login script if AirPort is powered up
    # and initialisation is finished
    power_status = true if line =~ /Power Status : 1/
    busy_status = true if line =~ /Busy : FALSE/
    ssid_match = true if line =~ /SSID_STR : \w+/
    if (power_status && busy_status && ssid_match) then
      return true
    end
  end
  return false
end

def run()
  interfaces = find_airport_interfaces()
  if interfaces.empty? then
    puts "No AirPort interfaces found"
    exit
  end

  IO.popen("scutil", "w+") do |f|
    # watch all AirPort interfaces
    interfaces.each do |interface|
      puts "Monitoring #{interface}"
      f.puts("n.add #{interface}")
      f.puts("n.watch")
    end

    # wait for AirPort State change
    while (line = f.gets()) do
      next unless line =~ /changed key/
      interface = line.split(' = ')[1]
      # get the changed data
      if is_connected(interface, f) then
        # sleep a little while until an ip address has been obtained via DHCP
        # monitoring the interface link is probably be more accurate
        #link = interface.gsub(/AirPort$/, 'Link')
        sleep 5
        puts "running cobot login"
        system("#{CobotLogin}/if.up/cobot")
      end
    end
  end
end


if '-f' == ARGV[0]
  # run in foreground
  run
else
  # daemonize
  pid = fork  do
    run
  end
  Process.detach(pid)
end

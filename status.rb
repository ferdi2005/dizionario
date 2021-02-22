`/usr/bin/ruby /home/pi/Script/dizionario/daemon.rb status`
if !status.include?("dizionario.rb: running")
    `/usr/bin/ruby /home/pi/Script/dizionario/daemon.rb start`
end
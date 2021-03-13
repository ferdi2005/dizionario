status = `/usr/bin/ruby /home/scripts/dizionario/daemon.rb status`
if !status.include?("dizionario.rb: running")
    `/usr/bin/ruby /home/scripts/dizionario/daemon.rb start`
end
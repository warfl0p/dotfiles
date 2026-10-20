-- Extra autostart processes.
-- o.launch_on_start("my-service")

local home = os.getenv("HOME")
o.exec_on_start("seaf-daemon -c " .. home .. "/.ccnet -d " .. home .. "/Seafile/.seafile-data -w " .. home .. "/Seafile")

# Run jupyterhub as Service

More information https://github.com/jupyterhub/jupyterhub/wiki/Run-jupyterhub-as-a-system-service
````
$ sudo chmod +x /etc/init.d/jupyterhub
# Create a default config to /etc/jupyterhub/jupyterhub_config.py
$ sudo jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py
# Start jupyterhub
$ sudo service jupyterhub start
# Stop jupyterhub
$ sudo service jupyterhub stop
# Start jupyterhub on boot
$ sudo update-rc.d jupyterhub defaults
# Or use rcconf to manage services http://manpages.ubuntu.com/manpages/natty/man8/rcconf.8.html
$ sudo rcconf
````
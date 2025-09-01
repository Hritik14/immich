## alloy

edit ``/etc/alloy/config.alloy`` and append ``alloy.config`` contents

## systemd

copy systemd files to ``/etc/systemd/system/``

## rclone

``rclone config`` -> add one config

``rclone config file`` -> get config filename  
copy and repeat similar configs (eg: all gdrive configs will be same with ``client_id`` , without ``token``)

``rclone config reconnect target:``

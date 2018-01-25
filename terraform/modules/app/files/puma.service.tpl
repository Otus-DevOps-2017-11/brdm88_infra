[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=${app_user}
WorkingDirectory=${app_workdir}/reddit
Environment="DATABASE_URL=${database_url}"
ExecStart=/bin/bash -lc 'puma -b tcp://0.0.0.0:${app_port}'
Restart=always

[Install]
WantedBy=multi-user.target

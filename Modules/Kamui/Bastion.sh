# Start Kamui Auto
# By default. the Governor is sugov_ext (Yea Yamada use custom kernel)
# So I set this to set the Governor to Schedhorizon / Schedutil (hehe)
sh /data/adb/modules/BastionBattery/Kamui/KamuiBalanced.sh 

# Notification 
su -lp 2000 -c "cmd notification post -S bigtext -t 'Kamui Bastion' -i file:///data/local/tmp/KamuiHehe.png -I file:///data/local/tmp/KamuiHehe.png TagBastion 'Haaah, Kimochi Yokatta'"

# Start Kamui Auto
KamuiAuto
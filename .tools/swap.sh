/usr/bin/setxkbmap -option "ctrl:swapcaps"
if [ $? -ne 0 ];then
    echo "Failed!"
else
    echo "Success!"
fi

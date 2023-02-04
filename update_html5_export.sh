#!/bin/bash
/home/tim/Data/local/programms/Godot_v3.5.1-stable_x11.64 --export "HTML5" game/project.godot
mkdir -p server/staticfiles/g/
cp -r exports/* server/staticfiles/g/
#!/bin/sh

DESKTOP_SIZE=2304x800

DISPLAY_SCREEN_POS=1280x0
DISPLAY_SCREEN_SIZE=1024x768

SRC_WIDTH=720
SRC_HEIGHT=576

MIDI_BCR_ID=20
MIDI_ACONNECT_I_TO_RELOADED="$MIDI_BCR_ID:0 $MIDI_BCR_ID:1 $MIDI_BCR_ID:2"
MIDI_ID_128="128:0"
MIDI_ID_129="129:0"

PIPE_NAME=/tmp/pipe
LOOPBACK_VIDEO_DEVICE=/dev/video1

VJ_INPUT_NAME=/home/alex/Videos/ANALOGRECYCLING_VJ_CLIPS/AR_ARROW_1.mov
#VJ_INPUT_NAME=-d

export VEEJAY_SCREEN_GEOMETRY=$DESKTOP_SIZE+$DISPLAY_SCREEN_POS
export VEEJAY_SCREEN_SIZE=$DISPLAY_SCREEN_SIZE
export VEEJAY_PERFORMANCE=quality


case "$1" in
server)
#Create a named pipe:
mkfifo $PIPE_NAME
#Start veejay, directing a Y4M output stream to the pipe:
/usr/bin/veejay -v $VJ_INPUT_NAME -w$SRC_WIDTH -h$SRC_HEIGHT --output 4 --output-file $PIPE_NAME
;;
client)
/usr/bin/reloaded -v
;;
radar)
cd /home/ob/install/video/veejay/veejay-1.4.5/veejay-radar/
./radar
;;
midi128)
for inp in $MIDI_ACONNECT_I_TO_RELOADED
do
aconnect $inp $MIDI_ID_128
done
aconnect -o -l
sleep 10
;;
midi129)
for inp in $MIDI_ACONNECT_I_TO_RELOADED
do
aconnect $inp $MIDI_ID_129
done
aconnect -o -l
sleep 10
;;
vims_list)
veejay -u -n | less
;;
vims_res)
cat reserved_vims
;;
load)
sayVIMS -m "056:0 $2;"
;;
load_list)
exec 0<$2
while read ligne
do
$0 load $ligne
done
;;
save_playlist)

;;
load_playlist)
;;
loopback)
#Feed the video loopback device with yuv4mpeg (Y4M) data that enters the pipe:
./Client/v4l2loopback/examples/yuv4mpeg_to_v4l2 $LOOPBACK_VIDEO_DEVICE < $PIPE_NAME
;;

lpmt)
#Start the LPMT Client
./Client/openFrameworks/apps/lpmt_full/lpmt/bin/lpmt
;;


stop_server)
killall -9 veejay
;;
stop_client)
killall -9 reloaded
;;
stop_radar)
killall -9 radar
;;
start_server)
gnome-terminal --tab -x $0 server --title veejay
;;
start_client)
gnome-terminal --tab -x $0 client --title reloaded
;;

start_radar)
gnome-terminal --tab -x $0 radar --title radar
;;
start_midi128)
gnome-terminal --tab -x $0 midi128 --title midi128
;;

start_midi129)
gnome-terminal --tab -x $0 midi129 --title midi129
;;

start_loopback)
gnome-terminal --tab -x $0 loopback --title video_pipe
;;

start_lpmt)
gnome-terminal --tab -x $0 lpmt --title projection_mapping
;;
esac
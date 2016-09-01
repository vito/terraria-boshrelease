#!/bin/bash

set -e

RUN_DIR=/var/vcap/sys/run/terraria
LOG_DIR=/var/vcap/sys/log/terraria
STORE_DIR=/var/vcap/store/terraria
BIN_DIR="$(cd $(dirname $0) && pwd)"
PIDFILE=$RUN_DIR/terraria.pid

source /var/vcap/packages/pid_utils/pid_utils.sh

kill_session_siblings_of() {
  pidfile=$1

  if [ -f "$pidfile" ]; then
    pid=$(head -1 "$pidfile")

    session=$(ps -p $pid -o sid=)
    ps -s $session -o pid:1= | xargs kill

    rm -f $pidfile
  else
    echo "Pidfile $pidfile doesn't exist!"
  fi
}

case $1 in

  start)
    pid_guard $PIDFILE "terraria"

    mkdir -p $RUN_DIR
    chown -R vcap:vcap $RUN_DIR

    mkdir -p $LOG_DIR
    chown -R vcap:vcap $LOG_DIR

    mkdir -p $STORE_DIR
    chown -R vcap:vcap $STORE_DIR

    echo $$ > $PIDFILE

    if ! [ -e $RUN_DIR/terraria.pipe ]; then
      mkfifo $RUN_DIR/terraria.pipe
    fi

    {
      while true; do
        cat $RUN_DIR/terraria.pipe
      done
    } | \
      chpst -u vcap:vcap /var/vcap/packages/terraria/TerrariaServer.bin.x86 \
        -config /var/vcap/jobs/terraria/config/serverconfig.txt \
        1>>$LOG_DIR/terraria.stdout.log \
        2>>$LOG_DIR/terraria.stderr.log

    ;;

  stop)
    kill_session_siblings_of $PIDFILE

    ;;

  *)
    echo "Usage: $0 {start|stop}"

    ;;

esac

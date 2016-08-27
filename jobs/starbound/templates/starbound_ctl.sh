#!/bin/bash

set -e

RUN_DIR=/var/vcap/sys/run/starbound
LOG_DIR=/var/vcap/sys/log/starbound
BIN_DIR="$(cd $(dirname $0) && pwd)"
PIDFILE=$RUN_DIR/starbound.pid

source /var/vcap/packages/pid_utils/pid_utils.sh

case $1 in

  start)
    pid_guard $PIDFILE "starbound"

    mkdir -p $RUN_DIR
    chown -R vcap:vcap $RUN_DIR

    mkdir -p $LOG_DIR
    chown -R vcap:vcap $LOG_DIR

    echo $$ > $PIDFILE

    exec /var/vcap/packages/starbound/linux/starbound_server \
      -bootconfig /var/vcap/jobs/starbound/config/sbinit.config \
      -logfile $LOG_DIR/starbound_server.log \
      -quiet \
      1>>$LOG_DIR/starbound.stdout.log \
      2>>$LOG_DIR/starbound.stderr.log

    ;;

  stop)
    kill_and_wait $PIDFILE

    ;;

  *)
    echo "Usage: $0 {start|stop}"

    ;;

esac

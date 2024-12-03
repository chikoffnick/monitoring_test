#!/bin/bash

PROCESS_NAME="test"
LOG_FILE="/var/log/monitoring.log"
MONITOR_URL="https://test.com/monitoring/test/api"
LAST_PID_FILE="/tmp/last_test_pid"

while true; do
	# Проверка, запущен ли процесс (поиск PID процесса test, если он запущен)
    current_pid=$(pgrep -x "$PROCESS_NAME")

    if [[ -n "$current_pid" ]]; then
        # Проверка, был ли процесс перезапущен
        last_pid=$(cat "$LAST_PID_FILE" 2>/dev/null)

        if [[ "$current_pid" != "$last_pid" ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Process $PROCESS_NAME restarted (PID: $current_pid)" >> "$LOG_FILE"
            echo "$current_pid" > "$LAST_PID_FILE"
        fi

        # Отправка запроса на указанный URL 
        http_code=$(curl -s -o /dev/null -w "%{http_code}" "$MONITOR_URL")
        if [[ "$http_code" != "200" ]]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitoring server is unreachable" >> "$LOG_FILE"
        fi
    else
        # Удаляем PID файла, если процесс не запущен
        rm -f "$LAST_PID_FILE" 2>/dev/null
    fi

    # Ожидание 60 секунд перед повторным запуском цикла
    sleep 60
done


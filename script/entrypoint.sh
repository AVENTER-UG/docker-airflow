#!/usr/bin/env bash


export AIRFLOW_HOME=/usr/local/airflow
envsubst < $AIRFLOW_HOME/airflow.ini > $AIRFLOW_HOME/airflow.cfg

# Install custom python package if requirements.txt is present
if [ -e "/requirements.txt" ]; then
    $(which pip) install --user -r /requirements.txt
fi

exec "$@"

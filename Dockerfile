FROM python:3.12 AS docker-airflow

LABEL maintainer="Andreas Peters <support@aventer.biz>"
LABEL org.opencontainers.image.title="docker-airflow"
LABEL org.opencontainers.image.description="Container image with Airflow Agent and Apache Mesos and ClusterD Support"
LABEL org.opencontainers.image.vendor="AVENTER UG (haftungsbeschränkt)"
LABEL org.opencontainers.image.source="https://github.com/AVENTER-UG/"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=linux

# Airflow
ARG AIRFLOW_HOME=/airflow

# Define en_US.
ENV LC_ALL="C.utf8"
ENV LC_CTYPE="C.utf8"

RUN groupadd -g 998 docker && \
    useradd -ms /bin/bash -G docker -d ${AIRFLOW_HOME} airflow

RUN apt -y update
RUN apt -y install xmlsec1


USER airflow

RUN python3 -m venv /airflow/venv
RUN . /airflow/venv/bin/activate

ENV PATH=/airflow/venv/bin:$PATH

RUN pip install 'apache-airflow==3.1.7' --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-3.1.7/constraints-3.12.txt"
RUN pip install boto3 avmesos waitress asyncpg xmlsec psycopg2
RUN pip install apache-airflow-providers-docker
RUN pip install apache-airflow-providers-amazon
RUN pip install apache-airflow-providers-slack
RUN pip install avmesos-airflow-provider
RUN pip install virtualenv
RUN pip install pandas

RUN mkdir -p /airflow/airflow/logs

USER root

RUN apt-get autoremove -yqq --purge && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8880 5555 8793

USER airflow

WORKDIR ${AIRFLOW_HOME}
CMD []

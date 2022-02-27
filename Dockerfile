# VERSION 1.9.0-4
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/puckel/docker-airflow

FROM python:3.8.9
LABEL maintainer="Andreas Peters"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_HOME=/home/airflow

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS true

COPY airflow /tmp/airflow

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        python3-pip \
        python3-requests \
        mariadb-client \
        mariadb-server \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        git \
        postgresql-client \
        gettext-base \
	vim \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && groupadd -g 992 docker \
    && useradd -ms /bin/bash -G docker -d ${AIRFLOW_HOME} airflow \
    && chown -R airflow:airflow /tmp/airflow

USER airflow

RUN python3 -m venv /home/airflow/venv
RUN . /home/airflow/venv/bin/activate

ENV PATH=/home/airflow/venv/bin:$PATH

RUN pip install -U pip setuptools wheel \
    && pip install Cython \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install mesoshttp \
    && pip install psycopg2 \
    && pip install docutils \
    && pip install docker \
    && pip install blinker \
    && pip install attrs==20.1.0 \
    && pip install flask-login==0.4.1 \
    && pip install avmesos \
    && pip install sentry_sdk \
    && pip install kubernetes \
    && pip install mesos.interface \
    && pip install celery[redis] \
    && pip install gitpython \
    && pip install mysql \
    && pip install boto3 \
    && pip install numpy \
    && pip install mysql.connector \
    && pip install urllib3==1.24.3

RUN cd /tmp/airflow && python3 setup.py install 

RUN pip install 'apache-airflow-providers-docker'
RUN pip install 'apache-airflow-providers-amazon'
RUN pip install 'apache-airflow-providers-slack'
RUN pip install 'avmesos-airflow-provider'
#RUN ln -s /home/airflow/venv/lib/python3.8/site-packages/airflow/providers /home/airflow/venv/lib/python3.8/site-packages/apache_airflow-2.0.1-py3.8.egg/airflow/providers

RUN mkdir /home/airflow/airflow

USER root

RUN apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY dags/ ${AIRFLOW_HOME}/airflow/dags/

RUN rm -rf /tmp/airflow

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"] # set default arg for entrypoint

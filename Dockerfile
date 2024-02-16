FROM python:3.10.13
LABEL maintainer="Andreas Peters"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_HOME=/airflow

# Define en_US.
ENV LC_ALL="C.utf8"
ENV LC_CTYPE="C.utf8"

RUN groupadd -g 992 docker && \
    useradd -ms /bin/bash -G docker -d ${AIRFLOW_HOME} airflow


USER airflow

RUN python3 -m venv /airflow/venv
RUN . /airflow/venv/bin/activate

ENV PATH=/airflow/venv/bin:$PATH

RUN pip install 'apache-airflow==2.8.2' --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.8.2/constraints-3.10.txt"
RUN pip install avmesos psycopg2 waitress 
RUN pip install apache-airflow-providers-docker
RUN pip install apache-airflow-providers-amazon
RUN pip install apache-airflow-providers-slack
RUN pip install avmesos-airflow-provider
RUN pip install virtualenv
RUN pip install pandas

RUN mkdir /airflow/airflow

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
CMD ["/airflow/venv/bin/airflow", "webserver"]

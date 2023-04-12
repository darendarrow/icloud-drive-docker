FROM python:alpine AS build
RUN apk update && apk add git gcc musl-dev python3-dev libffi-dev openssl-dev cargo
WORKDIR /app
COPY requirements.txt .
RUN python -m venv venv
ENV PATH="/app/venv/bin/:$PATH"
RUN pip install -U pip 
RUN pip install --upgrade pip 
RUN pip install -r requirements.txt
RUN pip --disable-pip-version-check list --outdated --format=json | python -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))"
FROM python:alpine
ARG APP_VERSION=dev
ARG NEW_INSTALLATION_ENDPOINT=dev
ARG NEW_HEARTBEAT_ENDPOINT=dev
WORKDIR /app
COPY --from=build /app/venv /app/venv
# Libmagic is required at runtime by python-magic
RUN apk update && apk add libmagic
ENV PATH="/app/venv/bin/:$PATH"
ENV PYTHONPATH /app
ENV NEW_INSTALLATION_ENDPOINT=$NEW_INSTALLATION_ENDPOINT
ENV NEW_HEARTBEAT_ENDPOINT=$NEW_HEARTBEAT_ENDPOINT
ENV APP_VERSION=$APP_VERSION
COPY . /app/
CMD ["python", "-u", "./src/main.py"]

# Python3 is baked in this base image
FROM python:3.8-alpine 

# Installing Gunicorn, Green Unicorn, commonly shortened to "Gunicorn", is a Web Server Gateway Interface (WSGI) server implementation that is commonly used to run Python web applications.
RUN pip install -U gunicorn

# Create a directory called "rates". copy .py files and make "rates" as WORDIR
RUN  mkdir rates
COPY ./rates /rates
WORKDIR /rates

# Install Requirements : Flask and other libraries
RUN pip install -Ur requirements.txt

# Container Port
EXPOSE 3000

# Environmental Variables

ENV DB_HOST="localhost" \
   DB_NAME="postgres" \
   DB_USER="postgres" \
   DB_PASSWORD="postgres"

# Starting Application during container instantiation,
ENTRYPOINT ["gunicorn","-b", ":3000", "wsgi"]
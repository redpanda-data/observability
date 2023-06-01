FROM python:3.9

ADD generate.py .
ADD templates /templates

RUN pip install PyYAML

CMD ["python", "./generate.py"]
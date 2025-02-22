FROM python:3.9

WORKDIR /app

COPY requirements.txt . 

RUN pip install -r requirements.txt

COPY process_queue.py .

CMD ["python", "process_queue.py"]
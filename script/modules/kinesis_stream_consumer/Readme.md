# Kinesis Stream record consumer
Kinesis stream invoke the consumer lamda function upon the arrival of records into the Kinesis Stream.

## Lambda funciton in python.
See lambda/python/kinesis_consumer.py.tpl. (Terraform processes the .tpl file to generate python file).

## Test
To run standalone.
```
python kynesis_consumer.py
```


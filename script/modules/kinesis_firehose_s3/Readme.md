# Overview
To offer the in-flight data transformation for Kinesis Firehose.

Firehose used to have no feature to run transformation on streaming data (e.g. run analysis, transformation, etc which Apache Flink has). Only way was to store to S3 and use trigger to invoke lambda.

* [Amazon Kinesis Firehose Data Transformation with AWS Lambda](https://aws.amazon.com/blogs/compute/amazon-kinesis-firehose-data-transformation-with-aws-lambda/)
> deliver data to an intermediate destination, such as a S3 bucket, and use S3 event notification to trigger a Lambda function to perform the transformation before delivering it to the final destination.
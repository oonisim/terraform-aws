# Overview
Terraform implementation of Mythical Mysfits - Build a Modern Application on AWS (Python).
* [CDK version](https://github.com/aws-samples/aws-modern-application-workshop/blob/python-cdk/module-2/app/service/mythicalMysfitsService.py).
* [CloudFormation version](https://github.com/aws-samples/aws-modern-application-workshop/tree/python)


# TODO
* Separate Security Group into a module. Configure network access control using security group. For example, limit the access to ECR VPC endpoint only from the SG attached to the ECS EC2 instances.
* Lambda in VPC + VPC endpoints for Firehose & test if the API GW AWS integration communicates with the endpoint.


# Note

## API Gateway stage
If state name is specified to API Gateway deployment, it will recreate a stage. Also there is a bug in API Gateway deployment that does not require stage name although deployment is to a stage.

* [Error creating API Gateway Stage: ConflictException: Stage already exists #2918](https://github.com/terraform-providers/terraform-provider-aws/issues/2918)
* [	Can't create a STAGE / DEPLOYMENT for API Gateway, circular reference error](https://forums.aws.amazon.com/thread.jspa?threadID=236830)
> The documentation for the CLI suggests that the --stage-name parameter is optional,



# FAQ

### Allow mixed HTTP/HTTPS

When index.html specifies the ELB URL which can be HTTP, and CloudFront is HTTPS, Chrome will reject the non secure HTTP access from the secure Cloudfront HTTPS. To allow mixed HTTP/HTTPS, follow the link below.

* [How to get Chrome to allow mixed content?](https://stackoverflow.com/questions/18321032/how-to-get-chrome-to-allow-mixed-content)

### CloudFront redirects to S3

* [Cloudfront domain redirects to S3 Origin URL](https://forums.aws.amazon.com/thread.jspa?threadID=216814)
>  (http://docs.aws.amazon.com/AmazonS3/latest/dev/Redirects.html), Due to the distributed nature of Amazon S3, requests can be temporarily routed to the wrong facility. This is most likely to occur immediately after buckets are created or deleted.
import boto3
from botocore.exceptions import NoCredentialsError, ClientError

def upload_to_s3(file_name, bucket, object_name=None):
    """
    Upload a file to an S3 bucket
    :param file_name: File to upload
    :param bucket: Bucket name
    :param object_name: S3 object name. If not specified, file_name is used
    :return: True if file was uploaded, else False
    """
    # If S3 object_name not specified, use file_name
    if object_name is None:
        object_name = file_name

    # Create S3 client
    s3 = boto3.client(
    "s3",
    aws_access_key_id="..",
    aws_secret_access_key="...",
    region_name="us-west-2"
    )

    try:
        s3_client.upload_file(file_name, bucket, object_name)
        print(f"✅ Upload Successful: {file_name} → s3://{bucket}/{object_name}")
        return True
    except FileNotFoundError:
        print("❌ The file was not found.")
        return False
    except NoCredentialsError:
        print("❌ Credentials not available.")
        return False
    except ClientError as e:
        print(f"❌ Client Error: {e}")
        return False


if __name__ == "__main__":
    # Example usage
    local_file = "abc.log"              # File you want to upload
    bucket_name = "s3://c1t00/"  # Replace with your bucket
    s3_key = "/abc.log"          # Path in bucket

    upload_to_s3(local_file, bucket_name, s3_key)

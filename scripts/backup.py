import boto3
import io
import tarfile

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    source_bucket_name = "jellybelly"
    source_bucket = s3.Bucket(source_bucket_name)
    
    backup_bucket_name = "jellybellybackup"
    backup_bucket = s3.Bucket(backup_bucket_name)

    # Create an in-memory tar archive of the data
    archive = io.BytesIO()
    with tarfile.open(fileobj=archive, mode='w:gz') as tar:
        for obj in source_bucket.objects.filter(Prefix='data/'):
            data = obj.get()['Body'].read()
            tarinfo = tarfile.TarInfo(name=obj.key)
            tarinfo.size = len(data)
            tar.addfile(tarinfo, io.BytesIO(data))
            print("added file")
        print("completed archive")
    
    # Flush and reset the stream position to the beginning
    archive.flush()
    archive.seek(0)

    # Upload the tar archive to the backup bucket
    backup_bucket.upload_fileobj(archive, 'jellyfinbackup.tar.gz')
    print("succesful upload")
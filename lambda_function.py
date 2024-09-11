import boto3
import os
import time
from botocore.exceptions import ClientError
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)                 # logger設定

s3 = boto3.resource('s3')
bucket_name = 'subsite-dev-feed-s3-01'        # S3バケット名を指定
directory_name = os.environ['DIRECTORY_NAME'] # S3バケット内ディレクトリ
trigger_file_1 = '*'            # トリガーファイル名を指定
trigger_file_2 = '*'        # トリガーファイル名を指定
sleep_time = int(os.environ['SLEEP_TIME'])    # SLEEP時間 (環境変数より取得)
retry_count = int(os.environ['RETRY_COUNT'])  # リトライカウント (環境変数より取得) 

def lambda_handler(event, context):
    bucket = s3.Bucket(bucket_name)
    trigger_file_1_exists = False
    trigger_file_2_exists = False

    # トリガーファイル存在チェック
    for obj in bucket.objects.filter(Prefix=directory_name):
        print(f'obj: {obj}')
        if obj.key == os.path.join(directory_name, trigger_file_1):
            trigger_file_1_exists = True
        elif obj.key == os.path.join(directory_name, trigger_file_2):
            trigger_file_2_exists = True

    # トリガーファイルが存在する場合、全ファイルをEFSにコピーしS3から削除
    if trigger_file_1_exists and trigger_file_2_exists:
        for obj in bucket.objects.filter(Prefix=directory_name):
            # ディレクトリのみ除外
            if obj.key.endswith('/'):
               continue
            try:
                bucket.Object(obj.key).load()  
            except ClientError as e:
                if e.response['Error']['Code'] == "404":
                   print(f'Object {obj.key} not found in S3, skipping download')
                   continue
                else:
                   raise
            # オブジェクトダウンロード(S3→EFS)
            for i in range(retry_count):
                try:
                  file_path = os.path.join(os.environ['EFS_MOUNT_POINT'], obj.key)
                  time.sleep(sleep_time)
                  bucket.download_file(obj.key, file_path)
                  print(f'Copied {obj.key} to {file_path}')
                  break
                except ClientError as error:
                  print(f'Failed to download {obj.key} on attempt {i+1}: {error}')
                  logger.error(f'Failed to download {obj.key} on attempt {i+1}: {error}')  # ログにエラー出力
            else:
                print(f'Failed to download {obj.key} after {retry_count} attempts')
                logger.error(f'Failed to download {obj.key} after {retry_count} attempts')  # ログにエラー出力
                continue
            # オブジェクトダウンロード正常終了後S3削除
            obj.delete()
            print(f'Deleted {obj.key} from S3')
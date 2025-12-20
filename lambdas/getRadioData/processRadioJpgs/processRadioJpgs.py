import shutil
import tempfile
import boto3
import os
import glob
from analyse_detection import createImages


# SpecLab is creating files called interesting_X.jpg. I want the most recent two 
# to display on the website. 
def updateInterestingJpgs(srcbucket, srckey):
    destbucket = 'mjmm-data'
    extraargs = {'ContentType': 'image/png'}
    s3 = boto3.client('s3')
    tmploc = tempfile.mkdtemp()
    filname = os.path.split(srckey)[1]
    locname = os.path.join(tmploc, filname)
    print(f'processing {srckey}')
    try:
        s3.download_file(srcbucket, srckey, locname)
    except Exception:
        print(f'unable to get the file {srckey}')
        return 

    createImages(locname)

    img2d = glob.glob(os.path.join(tmploc, 'PSD*.png'))[0]
    sc1key = 'Radio/screenshot1.png'
    try:
        s3.upload_file(img2d, destbucket, sc1key, ExtraArgs=extraargs) 
    except Exception:
        print(f'unable to put the image {img2d}')

    img3d = glob.glob(os.path.join(tmploc, 'SPG*.png'))[0]
    sc2key = 'Radio/screenshot2.png'
    try:
        s3.upload_file(img3d, destbucket, sc2key, ExtraArgs=extraargs) 
    except Exception:
        print(f'unable to put the image {img3d}')
    s3.delete_object(Bucket=srcbucket, Key=srckey)
    shutil.rmtree(tmploc)


if __name__ == '__main__':
    s3bucket='mjmm-rawradiodata'
    s3key = 'tmp/SMP_143050000_20251219_224406_655069.npz'
    updateInterestingJpgs(s3bucket, s3key)


def lambda_handler(event, context):
    record = event['Records'][0]
    s3bucket = record['s3']['bucket']['name']
    s3object = record['s3']['object']['key']
    updateInterestingJpgs(s3bucket, s3object)
    return

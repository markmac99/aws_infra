import shutil
import tempfile
import boto3
import os
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

    min_snr = int(os.getenv('MIN_SNR', default=30))
    img2d, img3d, wavfile = createImages(locname, min_snr=min_snr)
    if img2d is not None:
        # 2d waterfall
        try:
            s3.upload_file(img2d, destbucket, 'Radio/screenshot1.png', ExtraArgs=extraargs) 
        except Exception:
            print(f'unable to put the image {img2d} as screenshot1')
        bn = os.path.basename(img2d)
        spls = bn.split('_')
        dtstr = spls[2]
        key = f'Radio/{dtstr[:4]}/spec2d/{dtstr[:6]}/{dtstr}/{bn}'
        try:
            s3.upload_file(img2d, destbucket, key, ExtraArgs=extraargs) 
        except Exception:
            print(f'unable to save {bn} to S3')

        # 3d spectrogram
        try:
            s3.upload_file(img3d, destbucket, 'Radio/screenshot2.png', ExtraArgs=extraargs) 
        except Exception:
            print(f'unable to put the image {img3d} as screenshot2')
        
        bn = os.path.basename(img3d)
        key = f'Radio/{dtstr[:4]}/spec3d/{dtstr[:6]}/{dtstr}/{bn}'
        try:
            s3.upload_file(img3d, destbucket, key, ExtraArgs=extraargs) 
        except Exception:
            print(f'unable to save {bn} to S3')
        # audio 
        try:
            s3.upload_file(wavfile, destbucket, 'Radio/meteor_sound.wav', ExtraArgs={'ContentType': 'audio/wav'}) 
        except Exception:
            print(f'unable to put the image {wavfile}')
        bn = os.path.basename(wavfile)
        key = f'Radio/{dtstr[:4]}/audio/{dtstr[:6]}/{dtstr}/{bn}'
        try:
            s3.upload_file(wavfile, destbucket, key, ExtraArgs={'ContentType': 'audio/wav'})
        except Exception:
            print(f'unable to save {bn} to S3')

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

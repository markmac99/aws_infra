import email
import os
import sys
from email import policy
import boto3
from datetime import datetime
import pyheif
from PIL import Image

targetBucket = 'tv-freecycle'
attbucket = "tvf-att"


def getLastUniqueid(table='toycycle', ddb=None):
    if not ddb:
        ddb = boto3.resource('dynamodb', region_name='eu-west-1')
    table = ddb.Table(table)
    res = table.scan()
    values = res.get('Items', [])
    lastuniqueid = 0
    for v in values:
        uid = int(v['uniqueid'])
        if uid > lastuniqueid:
            lastuniqueid = uid    
    return lastuniqueid


def addRow(tblname='toycycle', ddb=None, newdata=None):
    if not newdata:
        return 
    if not ddb:
        ddb = boto3.resource('dynamodb', region_name='eu-west-1')
    table = ddb.Table(tblname)
    response = table.put_item(Item=newdata)
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print('error writing to table')
    return 


def convertHEIC(srcfile):
    img=pyheif.read(srcfile)
    image = Image.frombytes(img.mode, img.size, img.data, "raw", img.mode, img.stride)
    fn, _ = os.path.splitext(srcfile)
    newn = fn + '.jpg'
    image.save(newn)
    return newn


def createLine(fname, tblname, attnames):
    f = open(fname, 'r')
    lines = [line.rstrip('\n') for line in f]
    lines = [x for x in lines if x.strip()]
    f.close()
    numlines = len(lines)
    print(lines)

    created = datetime.now().strftime('%Y%m%d%H%M%S')
    typ = lines[0].rstrip('\n')[7:]
    ite = lines[1].rstrip('\n')[6:]
    ite = ite.replace('&', '&amp;').replace(',', '&#44;').replace('"', '&rdquo;')
    ite = ite.replace('£', '&#163;').replace('“', '&ldquo;').replace('”', '&rdquo;')
    ite = ite.replace("'", '&#39;').replace('<', '&lt;').replace('>', '&gt;')
    ite = ite.replace('‘', '&lsquo;').replace('’', '&rsquo;')

    des = lines[2].rstrip('\n')[13:]
    i = 3
    nxl = lines[i].rstrip('\n')
    while nxl[:5] != 'Price':
        des = des + ' ' + nxl
        i += 1
        numlines -= 1
        nxl = lines[i].rstrip('\n')
    des = des.replace('&', '&amp;').replace(',', '&#44;').replace('"', '&rdquo;')
    des = des.replace('£', '&#163;').replace('“', '&ldquo;').replace('”', '&rdquo;')
    des = des.replace("'", '&#39;').replace('<', '&lt;').replace('>', '&gt;')
    des = des.replace('‘', '&lsquo;').replace('’', '&rsquo;')
    pri = nxl[7:]
    if len(pri) == 0:
        pri = '0'
    else:
        pri = pri.replace('£', '')

    nam = lines[i + 1].rstrip('\n')[6:]
    pho = lines[i + 2].rstrip('\n')[7:]
    ema = lines[i + 3].rstrip('\n')[7:]

    url1 = ''
    url2 = ''
    url3 = ''
    if numlines == 8:
        url1 = attnames[0]
    elif numlines == 9:
        url1 = attnames[0]
        url2 = attnames[1]
    else:
        url1 = attnames[0]
        url2 = attnames[1]
        url3 = attnames[2]

    uniqueid = getLastUniqueid(table=tblname) + 1
    dtval = datetime.datetime.strptime(str(created), '%Y%m%d%H%M%S')
    expdate = int((dtval + datetime.timedelta(days=50)).timestamp())
    newdata = {'uniqueid': f'{uniqueid:09d}', 'recType': typ, 
            'Item': ite, 'description':des, 'price': str(pri), 
            'contact_n': nam, 'contact_p': pho, 'contact_e': ema,
            'url1': url1, 'url2': url2, 'url3': url3, 
            'isdeleted': '0', 'created': str(created), 'expirydate': expdate}
    print(newdata)
    addRow(newdata=newdata, tblname=tblname)
    return


def lambda_handler(event, context):
    print('starting')
    s3 = boto3.client('s3')

    if 'Records' not in event:
        print('no record')
        return 
    record = event['Records'][0]
    if 'eventSource' not in record:
        print('no eventSource')
        return 

    try:
        fsobj = s3.get_object(Bucket=targetBucket, Key='toycycle/' + record['ses']['mail']['messageId'])
    except:
        print('email object not found')
        return
    try:
        raw_mail = fsobj['Body'].read()
        msg = email.message_from_bytes(raw_mail, policy=policy.default)
        bdy = msg.get_body('plain')
    except:
        print('unable to find message body')
        return
    
    msgbdy = bdy.get_content()

    fileName = record['ses']['mail']['messageId'] + '.txt'
    filePath = os.path.join('/tmp', fileName)
    with open(filePath, 'w') as fp:
        fp.write(msgbdy.replace('\r', ''))

        attnames = []
        for part in msg.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue
            imgName = part.get_filename()
            imgPath = os.path.join('/tmp', imgName)
            keyName = imgName
            with open(imgPath, 'wb') as ifp:
                data = part.get_payload(decode=True)
                ifp.write(data)
            if b'ftypheic' in data:
                imgPath = convertHEIC(imgPath)
                keyName = os.path.split(imgPath)[1]
            print(f'attachment {keyName}')
            attnames.append(keyName)
            s3.upload_file(Bucket=attbucket, Key=keyName, Filename=imgPath,
                    ExtraArgs={'ContentType': "image/jpg", 'ACL': "public-read"})

            lin = 'url: ' + imgName + '\n'
            fp.write(lin)
            print('saved attachment')

    print('adding line to database')
    createLine(filePath, 'toycycle', attnames)

    tmpf = 'bodies/' + fileName
    s3.upload_file(Bucket=targetBucket, Key=tmpf, Filename=filePath,
        ExtraArgs={'ContentType': "text/html"})
    print('done')


if __name__ == '__main__':
    if len(sys.argv) > 1:
        msg = {'messageId': sys.argv[1]}
    else:
        msg = {'messageId': 'dlhngt12p9qd0li6kgnm78fte683gukua3om2no1'}
    ml = {'mail': msg}
    ses = {'ses': ml, 'eventSource': 'aws:ses'}
    recs = []
    recs.append(ses)
    a = {'Records': recs}
    b = 0
    print(a)
    lambda_handler(a, b)

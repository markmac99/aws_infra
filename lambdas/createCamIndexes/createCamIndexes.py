# Copyright (C) Mark McIntyre

import boto3
import os
import tempfile
import datetime


def createHtmlIdx(vid_or_img, ym, cam, fldr, buck, s3):
    dt = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    fd, tmpf = tempfile.mkstemp(text=True)
    with os.fdopen(fd, 'w') as outf:
        if vid_or_img == 'videos':
            ym = 'videos'
        outf.write(f'<html><head><title>Index of {ym} for {cam}</title>\n')
        outf.write('<link href="/data/mjmm-data/css/bootstrap.min.css" rel="stylesheet">\n')
        outf.write('<link href="/data/mjmm-data/css/plugins/metisMenu/metisMenu.min.css" rel=stylesheet>\n')
        outf.write('<link href="/data/mjmm-data/css/plugins/timeline.css" rel=stylesheet>\n')
        outf.write('<link href="/data/mjmm-data/css/plugins/morris.css" rel=stylesheet>\n')
        outf.write('<link href="/data/mjmm-data/css/magnific-popup.css" rel=stylesheet>\n')
        outf.write('<style>h2{margin-left: 80px;}</style>\n')
        outf.write('<style>p{margin-left: 80px;}</style>\n')
        outf.write('<style>div{margin-left: 80px;margin-right: 80px;}</style>\n')
        outf.write('<link href="/data/mjmm-data/css/dragontail.css" rel="stylesheet">\n')
        outf.write('</head><body>\n')
        outf.write('<script src="/js/jquery.js"></script>\n')
        outf.write('<script src="/js/bootstrap.min.js"></script>\n')
        outf.write('<script src="/js/plugins/morris/raphael.min.js"></script>\n')
        outf.write('<script src="/js/plugins/morris/morris.min.js"></script>\n')
        outf.write('<script src="./cameraindex.js"></script>\n')
        if 'stacks' in vid_or_img:
            outf.write(f'<h2>List of {vid_or_img} available for {cam}</h2>\n')
        elif ('startrails' in vid_or_img or 'keogram' in vid_or_img):
            outf.write(f'<h2>List of {vid_or_img} available for {ym}</h2>\n')
        else:
            outf.write(f'<h2>List of videos available for {cam} for this month</h2>\n')
        outf.write('<p><a href="https://markmcintyreastro.co.uk/cameradata-archive/">Back to index</a></p><hr>\n')
        outf.write(f'<div>Last Updated at {dt}</div>\n')
        outf.write('<div id="mthindex"></div>\n')
        if cam == 'UK9999':
            outf.write('<div>To mark a dataset for saving, right click and copy the link, then paste below and click the button ')
            outf.write('<form name="myForm" action="" method="GET">')
            outf.write('<br>\n')
            outf.write('<input type="text" name="inputbox" value="">\n')
            outf.write('<input type="button" name="button" value="Click" onClick="testResults(this.form)">\n')
            outf.write('</form>\n')
            outf.write('<script>\n')
            outf.write('function testResults(form) {\n')
            outf.write('var inputValue = form.inputbox.value;\n')
            outf.write('let position = inputValue.search("UK9999_");\n')
            outf.write('position = position + 7;\n')
            outf.write('endpos = position + 15;\n')
            outf.write('let result = inputValue.substring(position, endpos);\n')
            # outf.write('alert("You typed: " + result);\n')
            outf.write('fetch("https://bbz0mkr6i5.execute-api.eu-west-2.amazonaws.com/Prod?dt=" + result, {\n')
            outf.write('    method: "GET"\n')
            outf.write('}).then((response) => {\n')
            outf.write('    console.log(response.json())\n')
            outf.write('}).then((data) => {\n')
            outf.write('    console.log(data);\n')
            outf.write('})\n')
            outf.write('.catch((error) => {\n')
            outf.write('    console.log("error: " + error)\n')
            outf.write('})}\n')
            outf.write('</script>\n')

        outf.write('</body></html>\n')

    key = fldr + '/' + 'index.html'
    extraargs = {'ContentType': 'text/html'}
    print(tmpf, key)
    s3.meta.client.upload_file(tmpf, buck, key, ExtraArgs=extraargs) 
    os.remove(tmpf)

    return


def createNewIndex(buck, obj):
    s3 = boto3.resource('s3')
    contents=[]
    fldr, fname = os.path.split(obj)
    if fname[:6]=='startr':
        copysrc={'Bucket': buck, 'Key':obj}
        s3.meta.client.copy_object(CopySource=copysrc, Bucket=buck, Key='allsky/images/startrails-latest.jpg')
    objlist = s3.meta.client.list_objects_v2(Bucket=buck,Prefix=fldr)
    if objlist['KeyCount'] > 0:
        keys = objlist['Contents']
        for k in keys:
            fname = k['Key']
            _, ext = os.path.splitext(fname)
            if ext == '.mp4' or ext == '.jpg':
                contents.append(fname)

    while objlist['IsTruncated'] is True:
        contToken = objlist['NextContinuationToken'] 
        objlist = s3.meta.client.list_objects_v2(Bucket=buck,Prefix=fldr, ContinuationToken=contToken)
        if objlist['KeyCount'] > 0:
            keys = objlist['Contents']
            for k in keys:
                fname = k['Key']
                _, ext = os.path.splitext(fname)
                if ext == '.mp4' or ext == '.jpg':
                    contents.append(fname)

    contents.sort(reverse=True)
    spls = contents[0].split('/')
    cam = spls[0]
    if cam == 'allsky':
        ym = spls[2]
    else:
        ym = spls[1]
    _, ext = os.path.splitext(contents[0])
    if ext == '.mp4':
        vid_or_img = 'videos'
    else:
        vid_or_img = spls[1]
    createHtmlIdx(vid_or_img, ym, cam, fldr, buck, s3)
    if vid_or_img == 'dailystacks':
        contents = contents[:60]

    fd, tmpf = tempfile.mkstemp(text=True)
    with os.fdopen(fd, 'w') as outf:
        outf.write('$(function() {\n')        
        outf.write('var table = document.createElement("table");\n')
        outf.write('table.className = "table table-striped table-bordered table-hover table-condensed";\n')
        outf.write('var header = table.createTHead();\nheader.className = "h4";\n')
        colc=3
        for cn in contents:
            _, shorname = os.path.split(cn)
            if colc == 3:
                outf.write('var row = table.insertRow(-1);\n')
                colc=0
            outf.write('var cell = row.insertCell(-1);\n')
            if 'startrails' not in cn and 'stacks' not in cn and 'keogra' not in cn:
                outf.write(f'cell.innerHTML = "\\<a href=\\"https://d3jdcxriig76vh.cloudfront.net/{cn}\\"\\>{shorname}\\</a\\>";\n')
            else:
                outf.write(f'cell.innerHTML = "\\<a href=\\"https://d3jdcxriig76vh.cloudfront.net/{cn}\\"\\>\\<img src=https://d3jdcxriig76vh.cloudfront.net/{cn} width=100\\%\\>\\</a\\>";\n')
            colc = colc + 1
        outf.write('var outer_div = document.getElementById("mthindex");\n')
        outf.write('outer_div.appendChild(table);\n')
        outf.write('})\n')

    key = fldr + '/' + 'cameraindex.js'
    extraargs = {'ContentType': 'text/javascript'}
    s3.meta.client.upload_file(tmpf, buck, key, ExtraArgs=extraargs) 
    os.remove(tmpf)
    return 


def lambda_handler(event, context):
    record = event['Records'][0]
    s3bucket = record['s3']['bucket']['name']
    s3object = record['s3']['object']['key']
    print(s3object, s3bucket)
    _, ext = os.path.splitext(s3object)
    if ext.upper() not in ['.MP4','.JPG', '.PNG']:
        return
    createNewIndex(s3bucket, s3object)
    return


if __name__ == '__main__':
    # createNewIndex('mjmm-data','UK9999/202204/UK9999_20220414_193555_627612.mp4')
    #createNewIndex('mjmm-data','UK000F/stacks/UK000F_202102.jpg')
    #createNewIndex('mjmm-data','UK000F/trackstacks/UK000F_20220414.jpg')
    createNewIndex('mjmm-data', 'allsky/startrails/202209/startrails-20220924.jpg')    

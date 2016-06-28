# -*- coding: utf-8 -*-

import os
import fnmatch
import shutil
import errno

sourceDir = "/home/nero/source"
destinationImages = "/home/nero/destination/images"
destinationCss = "/home/nero/destination/css"
destinationJs = "/home/nero/destination/js"
srcImagesPath = []
srcCssPath = []
srcJsPath = []
destCssPath = []
destImagesPath = []
destJsPath = []

css_dict = {}
images_dict = {}
js_dict = {}

def MakeUniqDirs(path):
    output = []
    for x in path:
        if x not in output:
            output.append(x)
            try:
                os.makedirs(x)
            except OSError as exc:
                if exc.errno == errno.EEXIST:
                    pass
                else:
                    raise

for root, dirnames, filenames in os.walk(sourceDir):
    for filename in fnmatch.filter(filenames, '*.jpg') or fnmatch.filter(filenames, '*.png') or fnmatch.filter(filenames, '*.gif'):
        destImagesPath.append(root.replace(sourceDir, destinationImages))
        srcImagesPath.append(os.path.join(root, filename))
    for filename in fnmatch.filter(filenames, '*.css'):
        destCssPath.append(root.replace(sourceDir, destinationCss))
        srcCssPath.append(os.path.join(root, filename))
    for filename in fnmatch.filter(filenames, '*.js'):
        destJsPath.append(root.replace(sourceDir, destinationJs))
        srcJsPath.append(os.path.join(root, filename))

for i in range(len(srcCssPath)):
    css_dict[srcCssPath[i]] = destCssPath[i]
for i in range(len(srcImagesPath)):
    css_dict[srcImagesPath[i]] = destImagesPath[i]
for i in range(len(srcJsPath)):
    css_dict[srcJsPath[i]] = destJsPath[i]

MakeUniqDirs(destCssPath)
MakeUniqDirs(destImagesPath)
MakeUniqDirs(destJsPath)

for src, dst in css_dict.iteritems():
    shutil.copy(src, dst)
for src, dst in images_dict.iteritems():
    shutil.copy(src, dst)
for src, dst in js_dict.iteritems():
    shutil.copy(src, dst)
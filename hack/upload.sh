# Copyright 2022 Ben Woodward. All rights reserved.
# Use of this source code is governed by a GPL style
# license that can be found in the LICENSE file.
#
#!/usr/bin/env bash
#
# Uploads an image to the len.to s3 bucket. Depends on exiftool
set -e

S3BUCKET=zensurgery
CDN_BASE="d1aq3cviajvep4.cloudfront.net"

if [[ "$#" -ne 2 ]] ; then
  cat << EOF

Uploads a file to the len.to s3 bucket.

Usage: $0 <path_to_image> <date e.g. 2019-03-23>
EOF
  exit 1
fi

if ! [[ -x "$(command -v exiftool)" ]] ; then
  echo 'Error: must install exiftool first.' >&2
  exit 1
fi

filepath=$1
ts=$2
filename=$(basename "$1")
extension="${filename##*.}"

id=$(uuidgen | tr [:upper:] [:lower:] | cut -d'-' -f 1)
new_filename="${id}.${extension}"
url="https://${CDN_BASE}/${new_filename}"

# Strip all metadata from the image
exiftool -all= $1

# Upload the image
aws s3 cp --acl public-read "${filepath}" "s3://${S3BUCKET}/${new_filename}"

echo "Enter location"
read loc



# Create the content/img file
img="/Users/shanthanchalla/Documents/blog/zensurgery/content/img/${id}.md"
touch "${img}"
echo "---" > "${img}"
echo "title: ${id}" >> "${img}"
echo "date: ${ts}" >> "${img}"
echo "location: ${loc}" >> "${img}"
echo "img_url: ${url}" >> "${img}"
echo "original_fn: ${filename}" >> "${img}"
echo "tags:" >> "${img}"
echo "- ${loc}" >> "${img}"
echo "" >> "${img}"
echo "---" >> "${img}"

#nano "${img}"

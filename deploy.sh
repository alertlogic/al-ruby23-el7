set -ex

# if local build, exit
if [ -z "${CODEBUILD_BUILD_IMAGE}" ]; then
  exit 0
fi

# download latest external dependancies
mkdir -p RPMS/{x86_64,noarch}/
yumdownloader --destdir=RPMS/x86_64/ \
  rh-ruby23-rubygem-psych \
  rh-ruby23-ruby-libs \
  rh-ruby23-rubygem-did_you_mean \
  rh-ruby23-rubygem-io-console \
  rh-ruby23-ruby \
  rh-ruby23-runtime \
  rh-ruby23-rubygem-json \
  rh-ruby23-rubygem-bigdecimal

yumdownloader --destdir=RPMS/noarch/ \
  rh-ruby23-ruby-irb \
  rh-ruby23-rubygem-rdoc \
  rh-ruby23-rubygems \
  rh-ruby23-rubygems-devel

# upload files
DISTRIBUTION="el7"
RELEASE_DIRS="dev"
# if production release, add prod
if [ ! -z "${PROD_RELEASE}" ]; then
  RELEASE_DIRS="${RELEASE_DIRS} prod"
fi
for RELEASE_DIR in $RELEASE_DIRS; do
  for DIR in RPMS SRPMS SPECS SOURCES; do
    aws s3 cp --recursive ./${DIR}/ s3://${S3REPOBUCKET}/${RELEASE_DIR}/${DISTRIBUTION}/${DIR}/
  done
done

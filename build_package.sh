DEPLOY_DIR="/deploy"
VERSION=`date "+%Y%m%d-%H%M"`
echo "Building with build version: ${VERSION}"

sed s@"%BUILD_TIMESTAMP%"@"${VERSION}"@g DESCRIPTION > DESCRIPTION.new
cp -v DESCRIPTION DESCRIPTION.orig
mv -v DESCRIPTION.new DESCRIPTION

#R CMD check . || { echo 'R CMD check failed' ; exit 1; }
R CMD build . || { echo 'R CMD build failed' ; exit 1; }
#R -e "library(devtools); document()" || { echo 'R devtools::document()' ; exit 1; }
mv -v DESCRIPTION.orig DESCRIPTION

MANUAL_NAME=`ls -tr ..Rcheck/*pdf | tail -1`
NEW_MANUAL_NAME=`echo $MANUAL_NAME | sed s@"\.pdf"@".${VERSION}.pdf"@ | sed s@".*/"@@`
echo "Renaming ${MANUAL_NAME} to ${NEW_MANUAL_NAME}"
cp -v  ${MANUAL_NAME} ${NEW_MANUAL_NAME}

PACKAGE_NAME=`ls -tr *tar.gz | tail -1`
R CMD INSTALL ${PACKAGE_NAME} || { echo 'R CMD INSTALL ${PACKAGE_NAME} failed' ; exit 1; }
R -e "drat::insertPackage('${PACKAGE_NAME}', '/deploy', action='prune')" || { echo 'drat::insertPackage('${PACKAGE_NAME}', '/deploy', action='prune') failed' ; exit 1; }

echo "Produced ${NEW_MANUAL_NAME} and ${PACKAGE_NAME}"
BASE_PACKAGE_NAME=`echo ${NEW_MANUAL_NAME} | sed s@"-manual.*"@@`
echo ${BASE_PACKAGE_NAME}
mkdir -p "${DEPLOY_DIR}/${BASE_PACKAGE_NAME}"
cp -v ${NEW_MANUAL_NAME} ${PACKAGE_NAME} "${DEPLOY_DIR}/${BASE_PACKAGE_NAME}"
rm ${NEW_MANUAL_NAME} ${PACKAGE_NAME}

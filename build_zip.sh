if ! command -v rsync > /dev/null 2>&1; then
    echo "rsync not found!"
    exit 1
fi

rm -rf tmp/ && \
    mkdir -p tmp/

rsync -a --exclude='tmp' --exclude='.git*' --exclude='*.zip' . tmp/

cd tmp/ && \
    zip -r ../adb-root-enabler.zip . && \
    cd .. && \
    rm -rf tmp/

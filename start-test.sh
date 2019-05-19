#clear screen
clear;

echo -e "\033[35m********************************\033[m"
echo -e "\033[35m[Node.js performance benchmark]\033[m"
echo -e "\033[35m********************************\033[m"
echo ""

echo -e "\033[0mChecking dependencies...\033[m"

## check if node is installed
if which node > /dev/null
then
    echo -e "\033[32mInstalled Node.js version: $(node -v)\033[m";
else
    echo -e "\033[1mInstalling Node.js 12.x ...\033[m";
    sudo apt-get -qq install curl &> /dev/null;
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - &> /dev/null;
    sudo apt install -qq -y nodejs  &> /dev/null;
    echo -e "\033[32mInstalled Node.js version: $(node -v)\033[m";
fi

##check if pm2 is installed
pm2Installed=$(npm list -g --depth=0 | grep pm2);
pm2Ilen=$(printf "%s" pm2Installed | wc -m);
if [ ${#pm2Installed} -lt 8 ]; then
    npm install -g pm2 &> /dev/null;
    echo -e "\033[32mPM2 is now installed\033[m";
fi

## check if wrk is installed
if which wrk > /dev/null
then
    echo -e "\033[32mwrk is installed\033[m";
else
    echo -e "\033[1mInstalling wrk ...\033[m";
    sudo apt-get install build-essential libssl-dev git -y
    git clone https://github.com/wg/wrk.git wrk
    cd wrk
    make
    sudo cp wrk /usr/local/bin
    cd ..
    echo -e "\033[32mwrk is installed\033[m";
fi

## clone git project
echo -e "\033[1mCloning git project ...\033[m";
git clone https://github.com/jbenguira/node-perf-test.git node-perf-test &> /dev/null;
cd node-perf-test
echo -e "\033[1mnpm install ...\033[m";
npm install &> /dev/null;

nbcores=$(grep -c ^processor /proc/cpuinfo);

## start test server
pm2 start perf-fastify.js > /dev/null
sleep 2s
echo "Starting Node.js + fastify (single thread) benchmark with wrk";
echo "...................................................";

wrk -t$nbcores -c256 -d5s http://localhost:9057/;

## test with turo-http (single thread)
pm2 start perf-turbohttp.js > /dev/null
sleep 2s
echo "...................................................";
echo "Starting Node.js + turbo-http (single thread) benchmark with wrk";
echo "...................................................";
wrk -t1 -c256 -d5s http://localhost:9057/;

## stop test server
pm2 delete perf-turbohttp &> /dev/null


## Scale the server to run on each core
pm2 delete perf-fastify &> /dev/null
pm2 start perf-fastify.js -i $nbcores &> /dev/null
sleep 2s

echo "...................................................";
echo "Starting Node.js + fastify ($nbcores threads) benchmark with wrk";
echo "...................................................";
wrk -t$nbcores -c256 -d5s http://localhost:9057/;

## stop test server
pm2 delete perf-fastify > /dev/null


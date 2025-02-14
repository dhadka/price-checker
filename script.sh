#!/bin/bash

set -e

check() {
    productPage="$1"
    expectedPrice="$2"

    curl "$productPage" -v -s -S -X 'GET' \
        -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15' \
        -H 'Referer: https://www.costco.com/bicycles.html' \
        -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
        -H 'Accept-Language: en-US,en;q=0.9' \
        -H 'Sec-Fetch-Dest: document' \
        -H 'Sec-Fetch-Mode: navigate' \
        -H 'Sec-Fetch-Site: same-origin' \
        > product.html

    priceTotal=$(cat "product.html" | grep "priceTotal:" | grep -oE "[0-9]+\.[0-9]+")
    priceMin=$(cat "product.html" | grep "priceMin :" | grep -oE "[0-9]+\.[0-9]+" || echo "$priceTotal") # can be 'na'

    echo "Checking $productPage"
    echo "Expected Price: $expectedPrice, Current Price: $priceTotal, Min Price: $priceMin"
    
    # If price different, fail the action so it sends a notification
    if [ $(echo "$priceMin < $expectedPrice" | bc) -ne "0" ] || [ $(echo "$priceTotal < $expectedPrice" | bc) -ne "0" ]; then
        echo "::error::Product on sale!"
        exit -1
    fi

    echo ""
}

check "https://www.costco.com/intense-951-gravel-bike-1x-sram.product.4000230137.html" "2499.99"
check "https://www.costco.com/intense-951-trail-bike.product.4000136517.html" "2999.99"
